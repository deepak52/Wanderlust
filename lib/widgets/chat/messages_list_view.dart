import 'package:flutter/material.dart';

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
    this.reverse = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: reverse,
      itemCount: messages.length,
      itemBuilder: (ctx, idx) {
        final index = reverse ? messages.length - 1 - idx : idx;
        final message = messages[index];
        final isMe = message.senderId == currentUserId;
        final isSelected = message.messageId == selectedMessageId;

        return MessageBubble(
          text: message.text,
          isMe: isMe,
          timestamp: message.timestamp,
          isSelected: isSelected,
          statusIcon: isMe ? buildStatusIcon(message) : null,
          onDelete: isMe ? () => onDelete(message.messageId) : null,
          onEdit: isMe ? () => onEdit(message.messageId) : null,
          onTap: () => onMessageTap(message.messageId),
          replyToText: message.replyToText,
          isReplyFromMe: message.replyToSenderId == currentUserId,
          deleted: message.deleted,
        );
      },
    );
  }
}
