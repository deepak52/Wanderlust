import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'message_bubble.dart';
import '../../model/chat_model.dart';

/// Reusable messages list view widget for chat screens.
/// Follows Agro-Prod shared widget patterns.
/// Works with ChatMessage model and receives all data through parameters.
class MessagesListView extends StatelessWidget {
  final List<ChatMessage> messages;
  final String currentUserId;
  final String? selectedMessageId;
  final Function(String) onMessageTap;
  final Function(String) onDelete;
  final Function(String) onEdit;
  final Widget Function(ChatMessage) buildStatusIcon;
  final Function(String messageId)? onReply;
  final bool reverse;

  const MessagesListView({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.selectedMessageId,
    required this.onMessageTap,
    required this.onDelete,
    required this.onEdit,
    required this.buildStatusIcon,
    this.onReply,
    this.reverse = true,
  });

  @override
  Widget build(BuildContext context) {
    developer.log('🖥️ MessagesListView.build: messages.length=${messages.length}, currentUserId=$currentUserId, reverse=$reverse');
    developer.log('🔍 MESSAGES_LENGTH_DEBUG MessagesListView.build: messages.length=${messages.length}');
    if (messages.isNotEmpty) {
      developer.log('🖥️ MessagesListView.build: first msgId=${messages.first.messageId}, last msgId=${messages.last.messageId}');
    }
    return ListView.builder(
      reverse: reverse,
      itemCount: messages.length,
      itemBuilder: (ctx, idx) {
        final index = reverse ? messages.length - 1 - idx : idx;
        final message = messages[index];
        final isMe = message.senderId == currentUserId;
        final isSelected = message.messageId == selectedMessageId;

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 0 &&
                !message.deleted &&
                onReply != null) {
              onReply!(message.messageId);
            }
          },
          child: MessageBubble(
            text: message.text,
            isMe: isMe,
            timestamp: message.timestamp,
            isSelected: isSelected,
            statusIcon: isMe ? buildStatusIcon(message) : null,
            onDelete: isMe ? () => onDelete(message.messageId) : null,
            onEdit: isMe ? () => onEdit(message.messageId) : null,
            onTap: () => onMessageTap(message.messageId),
            onLongPress: () => onMessageTap(message.messageId),
            replyToText: message.replyToText,
            isReplyFromMe: message.replyToSenderId == currentUserId,
            deleted: message.deleted,
          ),
        );
      },
    );
  }
}
