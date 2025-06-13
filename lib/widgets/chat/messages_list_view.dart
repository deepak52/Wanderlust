import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_bubble.dart';

class MessagesListView extends StatelessWidget {
  final List<QueryDocumentSnapshot> messages;
  final String currentUserId;
  final String? selectedMessageId;
  final Function(String) onMessageTap;
  final Function(String) onDelete;
  final Widget Function(Map<String, dynamic>) buildStatusIcon;

  const MessagesListView({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.selectedMessageId,
    required this.onMessageTap,
    required this.onDelete,
    required this.buildStatusIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (ctx, idx) {
        final doc = messages[messages.length - 1 - idx];
        final data = doc.data() as Map<String, dynamic>;
        final messageId = doc.id;
        final text = data['text'] ?? '';
        final senderId = data['senderId'] ?? '';
        final ts = (data['timestamp'] as Timestamp?)?.toDate();
        final isMe = senderId == currentUserId;
        final isSelected = messageId == selectedMessageId;

        return MessageBubble(
          text: text,
          isMe: isMe,
          timestamp: ts,
          isSelected: isSelected,
          statusIcon: isMe ? buildStatusIcon(data) : null,
          onDelete: isMe ? () => onDelete(messageId) : null,
          onTap: () => onMessageTap(messageId),
        );
      },
    );
  }
}
