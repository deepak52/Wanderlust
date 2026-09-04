// chat_controller.dart
// Chat Controller - All business logic extracted from Wanderlust ChatScreen
// Follows Agro-Prod patterns: extends AppBaseController, uses ChatService for all Firebase access

import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/core/base/app_base_controller.dart';
import '../helper/core/theme/color_helper.dart';
import '../helper/route.dart';
import '../model/chat_model.dart';
import '../service/chat_service.dart';
import '../service/chat_sound_player.dart';
import '../service/active_chat_tracker.dart';
import '../service/lock_service.dart';
import 'lock_controller.dart';

class ChatController extends AppBaseController {
  // ==================== DEPENDENCIES ====================
  final ChatService _chatService = Get.find<ChatService>();
  final ChatSoundPlayer _soundPlayer = Get.find<ChatSoundPlayer>();
  final ActiveChatTracker _chatTracker = Get.find<ActiveChatTracker>();

  // ==================== NAVIGATION ARGUMENTS ====================
  late final String chatId;
  late final bool isAdmin;
  String? _currentUserId;
  String? _otherUserId;

  // ==================== REACTIVE LOCK & SOUND STATE ====================
  final RxBool lockEnabled = false.obs;

  // ==================== REACTIVE STATE (GetX Observables) ====================

  /// All messages in the current chat
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  /// Currently selected message ID for long-press actions
  final RxString selectedMessageId = ''.obs;

  /// Message being replied to (ID, text, and sender ID)
  final RxString replyToMessageId = ''.obs;
  final RxString replyToText = ''.obs;
  final RxString replyToSenderId = ''.obs;

  /// Message being edited
  final RxString editingMessageId = ''.obs;
  final RxString originalEditingText = ''.obs;

  /// Loading states
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;

  /// Error state
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  /// Scroll state
  final RxBool shouldScrollToBottom = true.obs;
  final RxBool atBottom = true.obs;

  /// Message input state
  final TextEditingController messageController = TextEditingController();
  final RxBool hasUnsentChanges = false.obs;

  /// Firestore stream subscription
  Stream<List<ChatMessage>>? _messagesStream;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  /// Chat room metadata
  final Rx<ChatRoom?> chatRoom = Rx<ChatRoom?>(null);
  final RxBool isChatRoomLoading = false.obs;

  // ==================== COMPUTED PROPERTIES ====================

  /// Whether current user is the sender of the selected message
  bool get isSelectedMessageMine {
    if (selectedMessageId.value.isEmpty) return false;
    try {
      final message = messages.firstWhere(
        (m) => m.messageId == selectedMessageId.value,
      );
      return message.senderId == _currentUserId;
    } catch (_) {
      return false;
    }
  }

  /// Whether a message is currently selected
  bool get hasSelectedMessage => selectedMessageId.value.isNotEmpty;

  /// Whether we're in reply mode
  bool get isReplying => replyToText.value.isNotEmpty;

  /// Whether we're in edit mode
  bool get isEditing => editingMessageId.value.isNotEmpty;

  /// The currently selected message
  ChatMessage? get selectedMessage {
    try {
      return messages.firstWhere((m) => m.messageId == selectedMessageId.value);
    } catch (_) {
      return null;
    }
  }

  /// The message being edited
  ChatMessage? get editingMessage {
    if (editingMessageId.value.isEmpty) return null;
    try {
      return messages.firstWhere((m) => m.messageId == editingMessageId.value);
    } catch (_) {
      return null;
    }
  }

  /// Current user ID (exposed for UI)
  String get currentUserId => _currentUserId ?? '';

  /// Other participant display name (for admin view)
  final RxString otherUserName = ''.obs;

  /// Header title: other user's name for admin, "Partner" for regular users
  String get displayTitle {
    if (isAdmin) {
      return otherUserName.value.isNotEmpty ? otherUserName.value : 'User';
    }
    return 'Partner';
  }

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();
    // CONTROLLER_IDENTITY_DEBUG: Log identityHashCode to verify single instance
    developer.log('🔍 CONTROLLER_IDENTITY ChatController.onInit: identityHashCode=${identityHashCode(this)}');
    _parseArguments();
    _currentUserId = _chatService.currentUserId;
    if (chatId.isNotEmpty) {
      _chatTracker.setActiveChat(chatId);
    }
    _loadLockStatus();
    _initializeChat();
  }

  @override
  void onClose() {
    _chatTracker.clearActiveChat();
    _dispose();
    messageController.dispose();
    super.onClose();
  }

  // ==================== INITIALIZATION ====================

  void _parseArguments() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      chatId = args['chatId'] as String? ?? '';
      isAdmin = args['isAdmin'] as bool? ?? false;
      final passedName = args['userName'] as String? ?? args['name'] as String?;
      if (passedName != null && passedName.trim().isNotEmpty) {
        otherUserName.value = passedName.trim();
      }
    }
    
    // STAGE 1: Print exact chatId received by ChatController from navigation
    developer.log('🟣 STAGE1 ChatController: chatId=$chatId, isAdmin=$isAdmin, currentUserId=$_currentUserId');
    developer.log('🟣 STAGE1 ChatController: chatId=$chatId, isAdmin=$isAdmin, currentUserId=$_currentUserId, otherUserName=${otherUserName.value}');
  }

  void _initializeChat() {
    if (chatId.isEmpty || _currentUserId == null) {
      _setError('Invalid chat or user');
      return;
    }

    _setLoading(true);

    try {
      // Get other participant ID from chatId
      _otherUserId = ChatUtils.getOtherParticipantId(chatId, _currentUserId!);

      // Ensure chat room exists (creates if missing)
      _ensureChatRoomExists().then((_) {
        // Load chat room metadata
        _loadChatRoom();

        // If admin and name not passed, fetch from participant data
        if (isAdmin && otherUserName.value.isEmpty) {
          _loadOtherUserName();
        }

        // Start listening to messages
        _listenToMessages();

        // Mark messages as delivered
        _markMessagesDelivered();
      }).catchError((e) {
        _setError('Failed to initialize chat: $e');
      }).whenComplete(() {
        _setLoading(false);
      });
    } catch (e) {
      _setError('Failed to initialize chat: $e');
      _setLoading(false);
    }
  }

  Future<void> _loadOtherUserName() async {
    try {
      final data = await _chatService.getOtherParticipantData(chatId);
      if (data != null) {
        final rawName = data['name'];
        final rawEmail = data['email'];
        final name = rawName != null ? rawName.toString().trim() : '';
        final email = rawEmail != null ? rawEmail.toString().trim() : '';
        if (name.isNotEmpty) {
          otherUserName.value = name;
        } else if (email.isNotEmpty) {
          final handle = email.split('@').first;
          otherUserName.value = handle[0].toUpperCase() + handle.substring(1);
        }
      }
    } catch (e) {
      developer.log('ChatController: Error loading other user data: $e');
    }
  }

  Future<void> _ensureChatRoomExists() async {
    developer.log('🔵 ChatController._ensureChatRoomExists: START chatId=$chatId');
    final chatDoc = await _chatService.getChatRoom(chatId);
    if (chatDoc == null) {
      developer.log('🔵 ChatController._ensureChatRoomExists: Chat room not found, creating...');
      await _chatService.getOrCreateChatRoom(_otherUserId!);
      developer.log('✅ ChatController._ensureChatRoomExists: Chat room created');
    } else {
      developer.log('🔵 ChatController._ensureChatRoomExists: Chat room already exists');
    }
  }

  void _loadChatRoom() {
    isChatRoomLoading.value = true;
    _chatService
        .watchChatRoom(chatId)
        .listen(
          (room) {
            chatRoom.value = room;
            isChatRoomLoading.value = false;
          },
          onError: (e) {
            isChatRoomLoading.value = false;
            debugPrint('Chat room stream error: $e');
          },
        );
  }

  void _listenToMessages() {
    developer.log('🟢 ChatController._listenToMessages: START chatId=$chatId');
    _messagesStream = _chatService.listenToMessages(chatId);
    _messagesSubscription = _messagesStream!.listen(
      (newMessages) {
        developer.log('🟢 ChatController._listenToMessages: Listener fired - received ${newMessages.length} messages');
        _handleMessagesSnapshot(newMessages);
      },
      onError: (error) {
        developer.log('❌ ChatController._listenToMessages: ERROR = $error');
        _setError('Error loading messages: $error');
        _setLoading(false);
      },
    );
  }

  Future<void> _loadLockStatus() async {
    if (Get.isRegistered<LockService>()) {
      lockEnabled.value = Get.find<LockService>().isLockEnabled();
    } else {
      final prefs = await SharedPreferences.getInstance();
      lockEnabled.value = prefs.getBool('lock_enabled') ?? false;
    }
  }

  Future<void> toggleLock(BuildContext context) async {
    final newValue = !lockEnabled.value;
    if (Get.isRegistered<LockController>()) {
      await Get.find<LockController>().setLockEnabled(newValue);
    } else if (Get.isRegistered<LockService>()) {
      await Get.find<LockService>().setLockEnabled(newValue);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('lock_enabled', newValue);
    }
    lockEnabled.value = newValue;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(newValue ? 'Lock Enabled' : 'Lock Disabled')),
    );
    if (newValue) {
      _authenticateIfLocked(context);
    }
  }

  Future<bool> _authenticateIfLocked(BuildContext context) async {
    if (!lockEnabled.value) return true;
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final isAvailable =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!isAvailable) return true;
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to access the chat',
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Authentication failed: $e');
      return false;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return false;
    }
  }

  void _handleMessagesSnapshot(List<ChatMessage> newMessages) {
    developer.log('🟢 ChatController._handleMessagesSnapshot: Received ${newMessages.length} messages');
    
    // Check if new incoming message from other user
    final isNewIncomingMessage = newMessages.isNotEmpty &&
        messages.isNotEmpty &&
        newMessages.length > messages.length &&
        newMessages.last.senderId != _currentUserId;

    for (final msg in newMessages) {
      developer.log('🟢 ChatController._handleMessagesSnapshot: msgId=${msg.messageId}, senderId=${msg.senderId}, text=${msg.text}, deleted=${msg.deleted}');
    }
    // Update reactive list
    messages.assignAll(newMessages);
    // Force reactivity - assignAll may not notify if list reference doesn't change
    messages.refresh();

    if (isNewIncomingMessage) {
      _soundPlayer.playReceiveSound();
    }

    // MESSAGES_LENGTH_DEBUG: Log messages.length after assignAll
    developer.log('🔍 MESSAGES_LENGTH_DEBUG _handleMessagesSnapshot: messages.length=${messages.length}');
    // RXLIST_IDENTITY_DEBUG: Log identityHashCode of messages RxList
    developer.log('🔍 RXLIST_IDENTITY ChatController: messages identityHashCode=${identityHashCode(messages)}');
    developer.log('🟢 ChatController._handleMessagesSnapshot: messages.assignAll() done, rxMessages.length=${messages.length}');

    // Handle seen status for incoming messages
    _markMessagesSeen(newMessages);

    // Auto-scroll to bottom if needed
    if (shouldScrollToBottom.value && atBottom.value) {
      shouldScrollToBottom.value = false;
      // UI will handle actual scroll via callback
    }

    _setLoading(false);
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Send a new message or update an edited message
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    developer.log('📤 ChatController.sendMessage: chatId=$chatId, senderId=$_currentUserId, receiverId=$_otherUserId, text=$text, isEditing=$isEditing');
    
    if (text.isEmpty || _currentUserId == null || _otherUserId == null) {
      developer.log('❌ ChatController.sendMessage: EARLY RETURN - empty text or null user IDs');
      return;
    }

    if (isEditing) {
      await _updateMessage(text);
      return;
    }

    _setSending(true);
    hasUnsentChanges.value = false;

    try {
      await _chatService.sendMessage(
        chatId: chatId,
        text: text,
        replyToMessageId: isReplying ? replyToMessageId.value : null,
        replyToText: isReplying ? replyToText.value : null,
        replyToSenderId: isReplying ? replyToSenderId.value : null,
      );

      // Play send sound
      _soundPlayer.playSendSound();

      // Clear reply state after sending
      clearReply();
    } catch (e) {
      developer.log('❌ ChatController.sendMessage: ERROR = $e');
      _setError('Failed to send message: $e');
    } finally {
      _setSending(false);
      messageController.clear();
      _requestScrollToBottom();
    }
  }

  /// Update an existing message
  Future<void> _updateMessage(String newText) async {
    if (editingMessageId.value.isEmpty ||
        newText.isEmpty ||
        newText == originalEditingText.value) {
      cancelEdit();
      return;
    }

    _setSending(true);

    try {
      await _chatService.editMessage(
        chatId: chatId,
        messageId: editingMessageId.value,
        newText: newText,
      );
    } catch (e) {
      _setError('Failed to update message: $e');
    } finally {
      _setSending(false);
      cancelEdit();
      _requestScrollToBottom();
    }
  }

  /// Confirm and soft-delete a message with a dialog
  Future<void> confirmDeleteMessage(BuildContext context, String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColorHelper.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColorHelper.borderTeal, width: 1.2),
        ),
        title: Text(
          'Delete Message?',
          style: GoogleFonts.cinzel(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorHelper.darkText,
            ),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this message? This message will be marked as deleted.',
          style: TextStyle(
            fontSize: 13.5,
            color: AppColorHelper.subduedText,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColorHelper.subduedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteMessage(messageId);
    }
  }

  /// Delete a message (soft delete)
  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(chatId: chatId, messageId: messageId);
      clearSelection();
    } catch (e) {
      _setError('Failed to delete message: $e');
    }
  }

  /// Mark undelivered messages as delivered
  Future<void> _markMessagesDelivered() async {
    if (_currentUserId == null) return;
    try {
      await _chatService.markAllDelivered(chatId);
    } catch (e) {
      debugPrint('Error marking messages delivered: $e');
    }
  }

  /// Mark unseen messages as seen
  void _markMessagesSeen(List<ChatMessage> messages) {
    if (_currentUserId == null) return;

    final unseenMessages =
        messages
            .where((m) => m.receiverId == _currentUserId && m.seen == false)
            .toList();

    if (unseenMessages.isEmpty) return;

    for (final message in unseenMessages) {
      _chatService.markSeen(chatId: chatId, messageId: message.messageId);
    }
  }

  // ==================== REPLY STATE ====================

  /// Start replying to a message
  void startReply(String messageId) {
    final message = messages.firstWhereOrNull((m) => m.messageId == messageId);
    if (message != null && !message.deleted) {
      cancelEdit(); // Cancel edit if active
      replyToMessageId.value = messageId;
      replyToText.value = message.text;
      replyToSenderId.value = message.senderId;
      clearSelection();
    }
  }

  /// Clear reply state
  void clearReply() {
    replyToMessageId.value = '';
    replyToText.value = '';
    replyToSenderId.value = '';
  }

  // ==================== EDIT STATE ====================

  /// Start editing a message
  void startEdit(String messageId) {
    final message = messages.firstWhereOrNull((m) => m.messageId == messageId);
    if (message != null && message.senderId == _currentUserId && !message.deleted) {
      clearReply(); // Cancel reply if active
      editingMessageId.value = messageId;
      originalEditingText.value = message.text;
      messageController.text = message.text;
      messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: message.text.length),
      );
      hasUnsentChanges.value = true;
      clearSelection();
    }
  }

  /// Cancel editing
  void cancelEdit() {
    editingMessageId.value = '';
    originalEditingText.value = '';
    messageController.clear();
    hasUnsentChanges.value = false;
  }

  // ==================== SELECTION STATE ====================

  /// Toggle message selection for long-press actions
  void toggleSelection(String messageId) {
    if (selectedMessageId.value == messageId) {
      clearSelection();
    } else {
      selectedMessageId.value = messageId;
      clearReply();
      cancelEdit();
    }
  }

  /// Clear message selection
  void clearSelection() {
    selectedMessageId.value = '';
  }

  // ==================== SCROLL STATE ====================

  /// Notify controller that user scrolled to bottom
  void onScrolledToBottom() {
    atBottom.value = true;
  }

  /// Notify controller that user scrolled away from bottom
  void onScrolledFromBottom() {
    atBottom.value = false;
  }

  /// Request scroll to bottom (UI handles actual animation)
  void _requestScrollToBottom() {
    shouldScrollToBottom.value = true;
  }

  // ==================== INPUT STATE ====================

  /// Called when message input changes
  void onMessageChanged(String text) {
    hasUnsentChanges.value = text.isNotEmpty;
  }

  /// Clear all input state
  void clearInput() {
    messageController.clear();
    clearReply();
    cancelEdit();
    hasUnsentChanges.value = false;
  }

  // ==================== STATUS ICON BUILDER ====================

  /// Builds status icon for a message (sent/delivered/seen)
  Widget buildStatusIcon(ChatMessage message) {
    if (message.senderId != _currentUserId) {
      return const SizedBox.shrink();
    }

    if (message.seen) {
      return const Icon(
        Icons.done_all,
        size: 16,
        color: AppColorHelper.chatSeenTick,
      );
    }
    if (message.delivered) {
      return const Icon(
        Icons.done_all,
        size: 16,
        color: AppColorHelper.chatDeliveredTick,
      );
    }
    return const Icon(
      Icons.done,
      size: 15,
      color: AppColorHelper.chatDeliveredTick,
    );
  }

  // ==================== NAVIGATION ====================

  /// Logout current user
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(loginPageRoute);
  }

  /// Handle back navigation
  Future<bool> onWillPop() async {
    if (!isAdmin) {
      Get.offAllNamed('/welcome');
      return false;
    }
    return true;
  }

  // ==================== PRIVATE HELPERS ====================

  void _setLoading(bool loading) {
    isLoading.value = loading;
  }

  void _setSending(bool sending) {
    isSending.value = sending;
  }

  void _setError(String error) {
    errorMessage.value = error;
    hasError.value = true;
  }

  void _dispose() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }
}
