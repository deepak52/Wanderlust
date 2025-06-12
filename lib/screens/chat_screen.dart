import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/missed_message_service.dart';
import '../shared/active_chat_tracker.dart';
import '../helpers/chat_sound_player.dart';
import '../helpers/notification_helper.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final bool isAdmin;
  static const routeName = '/chat'; // If you defined named routes

  const ChatScreen({Key? key, required this.chatId, required this.isAdmin})
    : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime? _lastNotifiedTimestamp;

  StreamSubscription? _reconnectSub;
  StreamSubscription? _messageListener;
  String? _currentUserId;
  String? _selectedMessageId;
  bool _shouldScrollToBottom = true;
  Timer? _debounce;

  bool _lockEnabled = false;

  @override
  void initState() {
    super.initState();

    _loadLockStatus();
    _markDeliveredMessages();
    ActiveChatTracker.instance.setActiveChat(widget.chatId);
    NotificationHelper.clearAllNotifications();

    _currentUserId = _auth.currentUser?.uid;

    _messageListener = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .snapshots()
        .listen((_) => _onMessagesSnapshotUpdate());

    _reconnectSub = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .snapshots()
        .listen((_) => _markDeliveredMessages());

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // handle foreground messages
    });
  }

  Future<void> _loadLockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lockEnabled = prefs.getBool('lock_enabled') ?? false;
    });
  }

  Future<void> _toggleLock(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !_lockEnabled;

    await prefs.setBool('lock_enabled', newValue);

    setState(() {
      _lockEnabled = newValue;
    });

    // Show snackbar after popup menu closes
    Future.delayed(Duration(milliseconds: 200), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newValue ? 'Lock Enabled' : 'Lock Disabled')),
      );
    });

    if (newValue) {
      _authenticateIfLocked();
    }
  }

  Future<bool> _authenticateIfLocked() async {
    if (!_lockEnabled) return true;

    final LocalAuthentication auth = LocalAuthentication();
    try {
      final isAvailable =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!isAvailable) {
        debugPrint("Biometric/Device auth not available.");
        return true; // Allow access if no biometric available?
      }

      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access the chat',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (!didAuthenticate) {
        // Authentication failed: navigate out
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        }
        return false;
      }
      return true;
    } on PlatformException catch (e) {
      debugPrint('Authentication failed: $e');
      return false;
    } catch (e) {
      debugPrint('Unexpected error during auth: $e');
      return false;
    }
  }

  void _onMessagesSnapshotUpdate() {
    // if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ActiveChatTracker.instance.clearActiveChat();
    _reconnectSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _messageListener?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _markDeliveredMessages() async {
    if (_currentUserId == null) return;
    final query =
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .where('receiverId', isEqualTo: _currentUserId)
            .where('delivered', isEqualTo: false)
            .get();
    if (query.docs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in query.docs)
      batch.update(doc.reference, {'delivered': true});
    await batch.commit();
  }

  void _handleMessageSeen(QuerySnapshot snapshot) async {
    final unseen = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['receiverId'] == _currentUserId && data['seen'] != true;
    });
    for (var doc in unseen) await doc.reference.update({'seen': true});
  }

  void _sendMessage() async {
    final user = _auth.currentUser;
    if (user == null || _messageController.text.trim().isEmpty) return;
    setState(() => _shouldScrollToBottom = true);

    final text = _messageController.text.trim();
    _messageController.clear();

    final parts = widget.chatId.split('_');
    if (parts.length != 2) return;
    final senderId = user.uid;
    final receiverId = parts.firstWhere(
      (id) => id != senderId,
      orElse: () => '',
    );
    if (receiverId.isEmpty) return;

    final ref = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          'text': text,
          'senderId': senderId,
          'receiverId': receiverId,
          'timestamp': FieldValue.serverTimestamp(),
          'delivered': false,
          'seen': false,
          'deleted': false,
          'notified': false,
        });
    await ChatSoundPlayer.playSendSound();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _shouldScrollToBottom) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      _shouldScrollToBottom = false;
    });

    final tokenDoc =
        await FirebaseFirestore.instance
            .collection('tokens')
            .doc(receiverId)
            .get();
    final fcmToken = tokenDoc.data()?['token'];
    if (fcmToken != null) {
      const url = 'https://fcm-server-9wga.onrender.com/send-chat';
      final resp = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': fcmToken,
          'senderName': user.displayName ?? 'Someone',
          'messageText': text,
        }),
      );
      if (resp.statusCode == 200) {
        await ref.update({'notified': true, 'delivered': true});
      }
    }
  }

  void _logout() async {
    await _auth.signOut();
    MissedMessageService().dispose();
    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
  }

  Future<bool> _onWillPop() async {
    if (!widget.isAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
      return false;
    }
    return true;
  }

  void _deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId)
          .update({'deleted': true});
      setState(() => _selectedMessageId = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete message.')),
      );
    }
  }

  Widget _buildStatusIcon(Map<String, dynamic> data) {
    if (data['senderId'] != _currentUserId) return const SizedBox.shrink();
    final delivered = data['delivered'] ?? false;
    final seen = data['seen'] ?? false;
    if (seen) return const Icon(Icons.done_all, size: 16, color: Colors.blue);
    if (delivered)
      return const Icon(Icons.done_all, size: 16, color: Colors.grey);
    return const Icon(Icons.done, size: 16, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .where('deleted', isEqualTo: false);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isAdmin ? 'Admin Chat' : 'Chat'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'toggle_lock') {
                  _toggleLock(context);
                } else if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'toggle_lock',
                      child: Text(
                        _lockEnabled ? 'Disable Lock' : 'Enable Lock',
                      ),
                    ),
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
            ),
          ],
        ),

        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: messagesRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return const Center(child: Text('Error loading messages.'));
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data?.docs ?? [];
                  if (messages.isNotEmpty) {
                    _handleMessageSeen(snapshot.data!);
                    final incoming =
                        messages.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final senderId = data['senderId'] ?? '';
                          final ts =
                              (data['timestamp'] as Timestamp?)?.toDate();
                          return senderId != _currentUserId && ts != null;
                        }).toList();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || incoming.isEmpty) return;

                      final newestTs =
                          (incoming.last.data()
                                  as Map<String, dynamic>)['timestamp']
                              ?.toDate();
                      if (_lastNotifiedTimestamp == null) {
                        _lastNotifiedTimestamp = newestTs;
                      } else if (newestTs != null &&
                          newestTs.isAfter(_lastNotifiedTimestamp!)) {
                        ChatSoundPlayer.playReceiveSound();
                        _lastNotifiedTimestamp = newestTs;
                      }

                      if (_scrollController.hasClients &&
                          _shouldScrollToBottom) {
                        _scrollController.animateTo(
                          _scrollController.position.minScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                        _shouldScrollToBottom = false;
                      }
                    });
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients && _shouldScrollToBottom) {
                      _scrollController.animateTo(
                        _scrollController.position.minScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                    _shouldScrollToBottom = false;
                  });
                  return ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (ctx, idx) {
                      final doc = messages[messages.length - 1 - idx];
                      final data = doc.data() as Map<String, dynamic>;
                      final messageId = doc.id;
                      if (data['deleted'] == true)
                        return const SizedBox.shrink();
                      final text = data['text'] ?? '';
                      final senderId = data['senderId'] ?? '';
                      final ts = (data['timestamp'] as Timestamp?)?.toDate();
                      final isMe = senderId == _currentUserId;
                      final isSelected = messageId == _selectedMessageId;
                      return GestureDetector(
                        onTap: () {
                          final pos = _scrollController.position.pixels;
                          if (mounted && _selectedMessageId != messageId) {
                            setState(() {
                              _selectedMessageId = messageId;
                            });
                          } else if (mounted) {
                            setState(() {
                              _selectedMessageId = null;
                            });
                          }

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_scrollController.hasClients) {
                              _scrollController.jumpTo(pos);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Align(
                            alignment:
                                isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (!isMe && isSelected && ts != null) ...[
                                  Text(
                                    '${ts.hour}:${ts.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          isMe
                                              ? Colors.blue[100]
                                              : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            text,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 8),
                                          _buildStatusIcon(data),
                                        ],
                                        if (isMe &&
                                            isSelected &&
                                            ts != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            '${ts.hour}:${ts.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                if (isMe && isSelected)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteMessage(messageId),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
