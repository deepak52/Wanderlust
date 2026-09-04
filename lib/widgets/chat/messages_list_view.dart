import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'chat_date_separator.dart';
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    developer.log('🖥️ MessagesListView.build: messages.length=${messages.length}, currentUserId=$currentUserId, reverse=$reverse');
    developer.log('🔍 MESSAGES_LENGTH_DEBUG MessagesListView.build: messages.length=${messages.length}');
    if (messages.isNotEmpty) {
      developer.log('🖥️ MessagesListView.build: first msgId=${messages.first.messageId}, last msgId=${messages.last.messageId}');
    }
    return ListView.builder(
      reverse: reverse,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (ctx, idx) {
        final index = reverse ? messages.length - 1 - idx : idx;
        final message = messages[index];
        final isMe = message.senderId == currentUserId;
        final isSelected = message.messageId == selectedMessageId;

        // Show date header if this is the first message of its calendar day
        final bool showDateSeparator = index == 0 ||
            !_isSameDay(message.timestamp, messages[index - 1].timestamp);

        final bubbleWidget = GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 100 &&
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
            edited: message.edited,
          ),
        );

        if (showDateSeparator) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ChatDateSeparator(date: message.timestamp),
              bubbleWidget,
            ],
          );
        }

        return bubbleWidget;
      },
    );
  }
}
