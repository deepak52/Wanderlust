import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/missed_message_service.dart';
import '../shared/active_chat_tracker.dart';
import '../helpers/chat_sound_player.dart';
import '../helpers/notification_helper.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../widgets/chat/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final bool isAdmin;
  static const routeName = '/chat';

  const ChatScreen({super.key, required this.chatId, required this.isAdmin});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime? _lastNotifiedTimestamp;
  String? _replyToText;
  String? _replyToSenderId;
  StreamSubscription? _reconnectSub;
  StreamSubscription? _messageListener;
  String? _currentUserId;
  String? _selectedMessageId;
  bool _shouldScrollToBottom = true;
  Timer? _debounce;
  bool _lockEnabled = false;
  String? _editingMessageId;
  String? _originalEditingText;
  List<DocumentSnapshot> _messages = [];

  // Helper to get selected message document from the message list
  DocumentSnapshot? get _selectedMessageDoc {
    try {
      return _messages.firstWhere((doc) => doc.id == _selectedMessageId);
    } catch (_) {
      return null;
    }
  }

  // Helper to check if the selected message was sent by current user
  bool get _isSelectedMessageMine {
    final doc = _selectedMessageDoc;
    if (doc == null) return false;

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return false;

    return data['senderId'] == _currentUserId;
  }

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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
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
    setState(() => _lockEnabled = newValue);
    Future.delayed(const Duration(milliseconds: 200), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newValue ? 'Lock Enabled' : 'Lock Disabled')),
      );
    });
    if (newValue) _authenticateIfLocked();
  }

  Future<bool> _authenticateIfLocked() async {
    if (!_lockEnabled) return true;
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final isAvailable =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!isAvailable) return true;
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access the chat',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (!didAuthenticate && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
        return false;
      }
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Authentication failed: $e');
      return false;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return false;
    }
  }

  void _onMessagesSnapshotUpdate() {}

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
    for (var doc in query.docs) {
      batch.update(doc.reference, {'delivered': true});
    }
    await batch.commit();
  }

  void _handleMessageSeen(QuerySnapshot snapshot) async {
    final unseen = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['receiverId'] == _currentUserId && data['seen'] != true;
    });
    for (var doc in unseen) {
      await doc.reference.update({'seen': true});
    }
  }

  void _sendMessage() async {
    final user = _auth.currentUser;
    if (user == null || _messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();
    setState(() => _shouldScrollToBottom = true);

    final senderId = user.uid;
    final parts = widget.chatId.split('_');
    final receiverId = parts.firstWhere(
      (id) => id != senderId,
      orElse: () => '',
    );
    if (receiverId.isEmpty) return;

    // ✅ If editing an existing message
    if (_editingMessageId != null) {
      final docRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(_editingMessageId);

      await docRef.update({
        'text': text,
        'edited': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _editingMessageId = null;
      });

      return;
    }

    // ✅ Else, send a new message
    final messageData = {
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': FieldValue.serverTimestamp(),
      'delivered': false,
      'seen': false,
      'deleted': false,
      'notified': false,
    };

    if (_replyToText != null && _replyToSenderId != null) {
      messageData['replyTo'] = {
        'text': _replyToText,
        'senderId': _replyToSenderId,
      };
    }

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add(messageData);

    await ChatSoundPlayer.playSendSound();

    setState(() {
      _replyToText = null;
      _replyToSenderId = null;
    });

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
  }

  Future<void> _updateMessage() async {
    final newText = _messageController.text.trim();
    if (_editingMessageId == null ||
        newText.isEmpty ||
        newText == _originalEditingText) {
      setState(() {
        _editingMessageId = null;
        _originalEditingText = null;
      });
      _messageController.clear();
      return;
    }

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(_editingMessageId)
        .update({'text': newText, 'edited': true});

    setState(() {
      _editingMessageId = null;
      _originalEditingText = null;
    });

    _messageController.clear();
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
          title:
              _selectedMessageId != null
                  ? const Text("1 selected")
                  : Text(widget.isAdmin ? 'Admin Chat' : 'Chat'),
          leading:
              _selectedMessageId != null
                  ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedMessageId = null;
                      });
                    },
                  )
                  : null,
          actions:
              _selectedMessageId != null
                  ? [
                    if (_isSelectedMessageMine) ...[
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          final doc = _selectedMessageDoc;
                          final data = doc?.data() as Map<String, dynamic>?;

                          if (data == null) return;

                          _messageController.text = data['text'] ?? '';
                          _messageController
                              .selection = TextSelection.fromPosition(
                            TextPosition(
                              offset: _messageController.text.length,
                            ),
                          );

                          setState(() {
                            _editingMessageId = doc?.id ?? '';
                            _originalEditingText = data['text'];
                            _selectedMessageId = null;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteMessage(_selectedMessageId!);
                          setState(() {
                            _selectedMessageId = null;
                          });
                        },
                      ),
                    ],
                  ]
                  : [
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
                            const PopupMenuItem(
                              value: 'logout',
                              child: Text('Logout'),
                            ),
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
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading messages.'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data?.docs ?? [];
                  _messages = messages;
                  if (messages.isNotEmpty) _handleMessageSeen(snapshot.data!);

                  if (messages.isNotEmpty) {
                    final incoming =
                        messages.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final senderId = data['senderId'] ?? '';
                          final ts =
                              (data['timestamp'] as Timestamp?)?.toDate();
                          return senderId != _currentUserId && ts != null;
                        }).toList();

                    if (incoming.isNotEmpty) {
                      final newestTs =
                          (incoming.last.data()
                                  as Map<String, dynamic>)['timestamp']
                              ?.toDate();
                      if (_lastNotifiedTimestamp == null ||
                          (newestTs != null &&
                              newestTs.isAfter(_lastNotifiedTimestamp!))) {
                        print(
                          '🔔 New message received. Playing receive sound...',
                        );
                        ChatSoundPlayer.playReceiveSound();
                        _lastNotifiedTimestamp = newestTs;
                      }
                    }
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients && _shouldScrollToBottom) {
                      _scrollController.animateTo(
                        _scrollController.position.minScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                      _shouldScrollToBottom = false;
                    }
                  });

                  return ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (ctx, idx) {
                      final doc = messages[messages.length - 1 - idx];
                      final data = doc.data() as Map<String, dynamic>;
                      final messageId = doc.id;

                      final isDeleted = data['deleted'] == true;
                      final isMe = data['senderId'] == _currentUserId;
                      final isSelected = messageId == _selectedMessageId;
                      final ts = (data['timestamp'] as Timestamp?)?.toDate();

                      final reply = data['replyTo'] as Map<String, dynamic>?;
                      final replyToText = reply?['text'] as String?;
                      final replyToSenderId = reply?['senderId'] as String?;
                      final isReplyFromMe = replyToSenderId == _currentUserId;

                      return GestureDetector(
                        onTap: () {
                          final pos = _scrollController.position.pixels;
                          setState(() {
                            _selectedMessageId =
                                _selectedMessageId != messageId
                                    ? messageId
                                    : null;
                          });
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_scrollController.hasClients) {
                              _scrollController.jumpTo(pos);
                            }
                          });
                        },
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity != null &&
                              details.primaryVelocity! > 0 &&
                              !isMe &&
                              !isDeleted) {
                            // Only reply if not deleted
                            setState(() {
                              _replyToText = data['text'];
                              _replyToSenderId = data['senderId'];
                            });
                          }
                        },
                        child: MessageBubble(
                          text:
                              data['text'] ?? '', // ✅ Always pass the real text
                          isMe: isMe,
                          timestamp: ts,
                          isSelected: isSelected,
                          onDelete:
                              isDeleted
                                  ? null
                                  : () => _deleteMessage(messageId),
                          onTap: () {
                            final pos = _scrollController.position.pixels;
                            setState(() {
                              _selectedMessageId =
                                  _selectedMessageId != messageId
                                      ? messageId
                                      : null;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.jumpTo(pos);
                              }
                            });
                          },
                          statusIcon: _buildStatusIcon(data),
                          replyToText: replyToText,
                          isReplyFromMe: isReplyFromMe,
                          deleted: isDeleted,
                          onEdit:
                              isMe && !isDeleted
                                  ? () {
                                    setState(() {
                                      _editingMessageId = messageId;
                                      _originalEditingText = data['text'];
                                    });
                                    _messageController.text = data['text'];
                                    _messageController
                                        .selection = TextSelection.fromPosition(
                                      TextPosition(
                                        offset: _messageController.text.length,
                                      ),
                                    );
                                  }
                                  : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            if (_editingMessageId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  border: const Border(
                    left: BorderSide(color: Colors.orange, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Editing message...',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _editingMessageId = null;
                          _messageController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),

            if (_replyToText != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: const Border(
                    left: BorderSide(color: Colors.blue, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Replying to: $_replyToText',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _replyToText = null;
                          _replyToSenderId = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        if (_editingMessageId != null) {
                          _updateMessage();
                        } else {
                          _sendMessage();
                        }
                      },
                      decoration: InputDecoration(
                        hintText:
                            _editingMessageId != null
                                ? 'Edit your message...'
                                : 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _editingMessageId != null ? Icons.check : Icons.send,
                    ),
                    onPressed: () {
                      if (_editingMessageId != null) {
                        _updateMessage();
                      } else {
                        _sendMessage();
                      }
                    },
                  ),
                  if (_editingMessageId != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _editingMessageId = null;
                          _originalEditingText = null;
                          _messageController.clear();
                        });
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(Map<String, dynamic> data) {
    if (data['senderId'] != _currentUserId) return const SizedBox.shrink();
    final delivered = data['delivered'] ?? false;
    final seen = data['seen'] ?? false;
    if (seen) return const Icon(Icons.done_all, size: 16, color: Colors.blue);
    if (delivered) {
      return const Icon(Icons.done_all, size: 16, color: Colors.grey);
    }
    return const Icon(Icons.done, size: 16, color: Colors.grey);
  }
}
