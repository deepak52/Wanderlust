import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class for chat ID generation (centralized)
class ChatUtils {
  /// Generates a consistent chat ID from two user IDs (sorted alphabetically)
  static String generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  /// Extracts the other participant's ID from a chat ID given current user ID
  static String? getOtherParticipantId(String chatId, String currentUserId) {
    final parts = chatId.split('_');
    if (parts.length != 2) return null;
    return parts[0] == currentUserId ? parts[1] : parts[0];
  }
}

/// Represents a chat room between two users
class ChatRoom {
  final String chatId;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, int>? unreadCounts;
  final bool? deleted;
  final DateTime? deletedAt;
  final String? deletedBy;

  ChatRoom({
    required this.chatId,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.createdAt,
    required this.updatedAt,
    this.unreadCounts,
    this.deleted,
    this.deletedAt,
    this.deletedBy,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      chatId: json['ChatId'] as String? ?? '',
      participantIds: List<String>.from(json['ParticipantIds'] ?? []),
      lastMessage: json['LastMessage'] as String?,
      lastMessageTime: (json['LastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageSenderId: json['LastMessageSenderId'] as String?,
      createdAt: (json['CreatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['UpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCounts: json['UnreadCounts'] != null
          ? Map<String, int>.from(json['UnreadCounts'])
          : null,
      deleted: json['Deleted'] as bool?,
      deletedAt: (json['DeletedAt'] as Timestamp?)?.toDate(),
      deletedBy: json['DeletedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ChatId': chatId,
      'ParticipantIds': participantIds,
      'LastMessage': lastMessage,
      'LastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'LastMessageSenderId': lastMessageSenderId,
      'CreatedAt': Timestamp.fromDate(createdAt),
      'UpdatedAt': Timestamp.fromDate(updatedAt),
      'UnreadCounts': unreadCounts,
      'Deleted': deleted,
      'DeletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'DeletedBy': deletedBy,
    };
  }

  /// Gets unread count for a specific user
  int getUnreadCount(String userId) {
    return unreadCounts?[userId] ?? 0;
  }

  /// Checks if the chat room is deleted
  bool get isDeleted => deleted == true;

  /// Gets the other participant ID
  String? getOtherParticipantId(String currentUserId) {
    return ChatUtils.getOtherParticipantId(chatId, currentUserId);
  }
}

/// Message status enum
enum MessageStatus { sending, sent, seen, failed }

/// Represents a single chat message
class ChatMessage {
  final String messageId;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool delivered;
  final DateTime? deliveredAt;
  final bool seen;
  final DateTime? seenAt;
  final bool deleted;
  final bool notified;
  final bool edited;
  final String? replyToMessageId;
  final String? replyToText;
  final String? replyToSenderId;

  ChatMessage({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    required this.delivered,
    this.deliveredAt,
    required this.seen,
    this.seenAt,
    required this.deleted,
    required this.notified,
    required this.edited,
    this.replyToMessageId,
    this.replyToText,
    this.replyToSenderId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['MessageId'] as String? ?? '',
      chatId: json['ChatId'] as String? ?? '',
      senderId: json['SenderId'] as String? ?? '',
      receiverId: json['ReceiverId'] as String? ?? '',
      text: json['Text'] as String? ?? '',
      timestamp: (json['Timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      delivered: json['Delivered'] as bool? ?? false,
      deliveredAt: (json['DeliveredAt'] as Timestamp?)?.toDate(),
      seen: json['Seen'] as bool? ?? false,
      seenAt: (json['SeenAt'] as Timestamp?)?.toDate(),
      deleted: json['Deleted'] as bool? ?? false,
      notified: json['Notified'] as bool? ?? false,
      edited: json['Edited'] as bool? ?? false,
      replyToMessageId: json['ReplyToMessageId'] as String?,
      replyToText: json['ReplyToText'] as String?,
      replyToSenderId: json['ReplyToSenderId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MessageId': messageId,
      'ChatId': chatId,
      'SenderId': senderId,
      'ReceiverId': receiverId,
      'Text': text,
      'Timestamp': Timestamp.fromDate(timestamp),
      'Delivered': delivered,
      'DeliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'Seen': seen,
      'SeenAt': seenAt != null ? Timestamp.fromDate(seenAt!) : null,
      'Deleted': deleted,
      'Notified': notified,
      'Edited': edited,
      'ReplyToMessageId': replyToMessageId,
      'ReplyToText': replyToText,
      'ReplyToSenderId': replyToSenderId,
    };
  }

  /// Creates a copy with updated fields
  ChatMessage copyWith({
    String? messageId,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    bool? delivered,
    DateTime? deliveredAt,
    bool? seen,
    DateTime? seenAt,
    bool? deleted,
    bool? notified,
    bool? edited,
    String? replyToMessageId,
    String? replyToText,
    String? replyToSenderId,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      delivered: delivered ?? this.delivered,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      seen: seen ?? this.seen,
      seenAt: seenAt ?? this.seenAt,
      deleted: deleted ?? this.deleted,
      notified: notified ?? this.notified,
      edited: edited ?? this.edited,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToText: replyToText ?? this.replyToText,
      replyToSenderId: replyToSenderId ?? this.replyToSenderId,
    );
  }

  bool get isOwnMessage => false; // Will be set by controller

  bool get hasReply => replyToMessageId != null && replyToMessageId!.isNotEmpty;

  /// Getter for id (alias for messageId)
  String get id => messageId;

  /// Computed message status based on delivered/seen flags
  MessageStatus get status {
    if (!delivered) return MessageStatus.sending;
    if (seen) return MessageStatus.seen;
    return MessageStatus.sent;
  }
}

/// Navigation arguments for chat screen
class ChatArguments {
  final String chatId;
  final bool isAdmin;

  ChatArguments({required this.chatId, required this.isAdmin});
}
