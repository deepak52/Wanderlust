// chat_service.dart
// Chat Foundation Service following Agro-Prod patterns

import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../helper/core/base/app_base_service.dart';
import '../model/chat_model.dart';

/// Chat Foundation Service - Centralizes all Firestore access for chat functionality
/// Follows Agro-Prod AppBaseService pattern with singleton via GetX
class ChatService extends AppBaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Collection references
  CollectionReference get _chatsCollection => _firestore.collection('chats');
  CollectionReference get _usersCollection => _firestore.collection('users');

  void initialize() {
    // Initialize ChatService-specific resources
    developer.log('ChatService initialize called');
  }

  void dispose() {
    // Clean up ChatService-specific resources
    developer.log('ChatService dispose called');
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // ==================== CHAT ROOM OPERATIONS ====================

  /// Creates or retrieves a chat room between two users
  /// Returns the chatId
  Future<String> getOrCreateChatRoom(String otherUserId) async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    if (currentUserId == otherUserId) {
      throw Exception('Cannot create chat with yourself');
    }

    final chatId = ChatUtils.generateChatId(currentUserId!, otherUserId);
    final chatRef = _chatsCollection.doc(chatId);

    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      final now = DateTime.now();
      final chatRoom = ChatRoom(
        chatId: chatId,
        participantIds: [currentUserId!, otherUserId]..sort(),
        createdAt: now,
        updatedAt: now,
      );

      await chatRef.set(chatRoom.toJson());
    } else {
      // Update last activity timestamp
      await chatRef.update({'UpdatedAt': Timestamp.fromDate(DateTime.now())});
    }

    return chatId;
  }

  /// Gets chat room metadata by ID
  Future<ChatRoom?> getChatRoom(String chatId) async {
    final doc = await _chatsCollection.doc(chatId).get();
    if (!doc.exists) return null;
    return ChatRoom.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Stream of chat room metadata (for chat list)
  Stream<ChatRoom?> watchChatRoom(String chatId) {
    return _chatsCollection.doc(chatId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChatRoom.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  /// Stream of all chat rooms for current user (for chat list screen)
  Stream<List<ChatRoom>> watchUserChatRooms() {
    if (!isAuthenticated) return Stream.value([]);

    return _chatsCollection
        .where('ParticipantIds', arrayContains: currentUserId)
        .orderBy('UpdatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        ChatRoom.fromJson(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }

  // ==================== MESSAGE OPERATIONS ====================

  /// Sends a new message to a chat
  /// Returns the message ID
  Future<String> sendMessage({
    required String chatId,
    required String text,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSenderId,
  }) async {
    developer.log('🔵 ChatService.sendMessage: START chatId=$chatId, text=$text');
    if (!isAuthenticated) throw Exception('User not authenticated');
    if (text.trim().isEmpty) throw Exception('Message cannot be empty');

    final currentUser = currentUserId!;
    final messageId =
        _firestore.collection('temp').doc().id; // Generate unique ID
    final now = DateTime.now();

    // Get other participant ID
    final otherUserId = ChatUtils.getOtherParticipantId(chatId, currentUser);
    if (otherUserId == null) throw Exception('Invalid chat ID');

    developer.log('🔵 ChatService.sendMessage: currentUser=$currentUser, otherUserId=$otherUserId, messageId=$messageId');

    // STAGE 2: Before sendMessage - print currentUserId, receiverId, chatId, messageId
    developer.log('🟠 STAGE2 ChatService.sendMessage: currentUserId=$currentUser, receiverId=$otherUserId, chatId=$chatId, messageId=$messageId');
    
    // CHAT_ID_DEBUG: Print chatId used in sendMessage
    developer.log('🔍 CHAT_ID_DEBUG sendMessage: chatId=$chatId');

    // Create message
    final message = ChatMessage(
      messageId: messageId,
      chatId: chatId,
      senderId: currentUser,
      receiverId: otherUserId,
      text: text.trim(),
      timestamp: now,
      delivered: false,
      seen: false,
      deleted: false,
      notified: false,
      edited: false,
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
      replyToSenderId: replyToSenderId,
    );

    // Use batch for atomic write
    final batch = _firestore.batch();

    // Add message to subcollection
    final messageRef = _chatsCollection
        .doc(chatId)
        .collection('messages')
        .doc(messageId);
    developer.log('🔵 ChatService.sendMessage: Writing to path=chats/$chatId/messages/$messageId');
    batch.set(messageRef, message.toJson());

    // Update chat room metadata
    final chatRef = _chatsCollection.doc(chatId);
    batch.update(chatRef, {
      'LastMessage': text.trim(),
      'LastMessageTime': Timestamp.fromDate(now),
      'LastMessageSenderId': currentUser,
      'UpdatedAt': Timestamp.fromDate(now),
    });

    developer.log('🔵 ChatService.sendMessage: Committing batch...');
    await batch.commit();
    developer.log('✅ ChatService.sendMessage: Batch committed successfully, messageId=$messageId');

    // STAGE 3: Immediately after batch.commit - read the same document back
    developer.log('🟠 STAGE3 ChatService.sendMessage: Reading back document...');
    final docSnap = await messageRef.get();
    developer.log('🟠 STAGE3 ChatService.sendMessage: Document exists=${docSnap.exists}, path=${docSnap.reference.path}');
    if (docSnap.exists) {
      developer.log('🟠 STAGE3 ChatService.sendMessage: Document data=${docSnap.data()}');
    }

    return messageId;
  }

  /// Streams messages for a chat (real-time)
  /// Ordered by timestamp ascending (oldest first)
  Stream<List<ChatMessage>> listenToMessages(String chatId) {
    developer.log('🟢 ChatService.listenToMessages: START chatId=$chatId');
    developer.log('🟢 ChatService.listenToMessages: Query path=chats/$chatId/messages, orderBy(Timestamp asc)');
    
    // CHAT_ID_DEBUG: Print chatId used in listenToMessages
    developer.log('🔍 CHAT_ID_DEBUG listenToMessages: chatId=$chatId');
    return _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('Timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) {
            developer.log('🟢 ChatService.listenToMessages: Snapshot received - docs count=${snapshot.docs.length}');
            for (final doc in snapshot.docs) {
              developer.log('🟢 ChatService.listenToMessages: Doc id=${doc.id}, data=${doc.data()}');
            }
            final messages = snapshot.docs
                  .map((doc) => ChatMessage.fromJson(doc.data()))
                  .toList();
            developer.log('🟢 ChatService.listenToMessages: Parsed ${messages.length} messages');
            return messages;
          },
        );
  }

  /// Gets messages with pagination (for initial load)
  Future<List<ChatMessage>> getMessages({
    required String chatId,
    int limit = 50,
    DocumentSnapshot? startAfter,
    DateTime? startAfterTimestamp,
  }) async {
    Query query = _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('Timestamp', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    } else if (startAfterTimestamp != null) {
      query = query.startAfter([Timestamp.fromDate(startAfterTimestamp)]);
    }

    final snapshot = await query.get();
    final messages =
        snapshot.docs
            .map(
              (doc) => ChatMessage.fromJson(doc.data() as Map<String, dynamic>),
            )
            .toList();

    // Reverse to get chronological order
    return messages.reversed.toList();
  }

  /// Edits an existing message
  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String newText,
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');
    if (newText.trim().isEmpty) throw Exception('Message cannot be empty');

    final messageRef = _chatsCollection
        .doc(chatId)
        .collection('messages')
        .doc(messageId);
    final messageDoc = await messageRef.get();

    if (!messageDoc.exists) throw Exception('Message not found');

    final messageData = messageDoc.data() as Map<String, dynamic>;
    if (messageData['SenderId'] != currentUserId) {
      throw Exception('Cannot edit messages from other users');
    }

    await messageRef.update({'Text': newText.trim(), 'Edited': true});
  }

  /// Soft deletes a message (marks as deleted)
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final messageRef = _chatsCollection
        .doc(chatId)
        .collection('messages')
        .doc(messageId);
    final messageDoc = await messageRef.get();

    if (!messageDoc.exists) throw Exception('Message not found');

    final messageData = messageDoc.data() as Map<String, dynamic>;
    if (messageData['SenderId'] != currentUserId) {
      throw Exception('Cannot delete messages from other users');
    }

    await messageRef.update({
      'Deleted': true,
      'Text': 'This message was deleted',
    });
  }

  // ==================== DELIVERY & READ RECEIPTS ====================

  /// Marks a specific message as delivered
  Future<void> markDelivered({
    required String chatId,
    required String messageId,
  }) async {
    final messageRef = _chatsCollection
        .doc(chatId)
        .collection('messages')
        .doc(messageId);
    await messageRef.update({
      'Delivered': true,
      'DeliveredAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Marks all undelivered messages in a chat as delivered (batch)
  Future<void> markAllDelivered(String chatId) async {
    if (!isAuthenticated) return;

    final batch = _firestore.batch();
    final snapshot =
        await _chatsCollection
            .doc(chatId)
            .collection('messages')
            .where('ReceiverId', isEqualTo: currentUserId)
            .where('Delivered', isEqualTo: false)
            .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'Delivered': true,
        'DeliveredAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  /// Marks a specific message as seen
  Future<void> markSeen({
    required String chatId,
    required String messageId,
  }) async {
    final messageRef = _chatsCollection
        .doc(chatId)
        .collection('messages')
        .doc(messageId);
    await messageRef.update({
      'Seen': true,
      'SeenAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Marks all unseen messages in a chat as seen (batch)
  Future<void> markAllSeen(String chatId) async {
    if (!isAuthenticated) return;

    final batch = _firestore.batch();
    final snapshot =
        await _chatsCollection
            .doc(chatId)
            .collection('messages')
            .where('ReceiverId', isEqualTo: currentUserId)
            .where('Seen', isEqualTo: false)
            .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'Seen': true,
        'SeenAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Gets the other participant's user data
  Future<Map<String, dynamic>?> getOtherParticipantData(String chatId) async {
    final otherUserId = ChatUtils.getOtherParticipantId(
      chatId,
      currentUserId ?? '',
    );
    if (otherUserId == null) return null;

    final doc = await _usersCollection.doc(otherUserId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  /// Updates chat room last message (called from message send)
  Future<void> updateChatRoomLastMessage({
    required String chatId,
    required String lastMessage,
    required String senderId,
  }) async {
    final now = DateTime.now();
    await _chatsCollection.doc(chatId).update({
      'LastMessage': lastMessage,
      'LastMessageTime': Timestamp.fromDate(now),
      'LastMessageSenderId': senderId,
      'UpdatedAt': Timestamp.fromDate(now),
    });
  }

  /// Increments unread count for the other participant
  Future<void> incrementUnreadCount(String chatId, String senderId) async {
    final otherUserId = ChatUtils.getOtherParticipantId(chatId, senderId);
    if (otherUserId == null) return;

    final chatRef = _chatsCollection.doc(chatId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(chatRef);
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final unreadCounts = Map<String, int>.from(data['UnreadCounts'] ?? {});
      unreadCounts[otherUserId] = (unreadCounts[otherUserId] ?? 0) + 1;

      transaction.update(chatRef, {'UnreadCounts': unreadCounts});
    });
  }

  /// Resets unread count for current user in a chat
  Future<void> resetUnreadCount(String chatId) async {
    if (!isAuthenticated) return;

    final chatRef = _chatsCollection.doc(chatId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(chatRef);
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final unreadCounts = Map<String, int>.from(data['UnreadCounts'] ?? {});
      unreadCounts[currentUserId!] = 0;

      transaction.update(chatRef, {'UnreadCounts': unreadCounts});
    });
  }

  /// Gets unread count for current user in a specific chat
  Future<int> getUnreadCount(String chatId) async {
    if (!isAuthenticated) return 0;

    final doc = await _chatsCollection.doc(chatId).get();
    if (!doc.exists) return 0;

    final data = doc.data() as Map<String, dynamic>;
    return (data['UnreadCounts']?[currentUserId] as int?) ?? 0;
  }

  /// Gets total unread count across all chats for current user
  Future<int> getTotalUnreadCount() async {
    if (!isAuthenticated) return 0;

    final snapshot =
        await _chatsCollection
            .where('ParticipantIds', arrayContains: currentUserId)
            .get();

    int total = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['UnreadCounts']?[currentUserId] as int?) ?? 0;
    }

    return total;
  }

  /// Deletes a chat room (soft delete - marks all messages deleted)
  Future<void> deleteChatRoom(String chatId) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final messagesSnapshot =
        await _chatsCollection.doc(chatId).collection('messages').get();

    for (final doc in messagesSnapshot.docs) {
      batch.update(doc.reference, {'Deleted': true});
    }

    // Mark chat room as deleted
    batch.update(_chatsCollection.doc(chatId), {
      'Deleted': true,
      'DeletedAt': Timestamp.fromDate(DateTime.now()),
      'DeletedBy': currentUserId,
    });

    await batch.commit();
  }
}
