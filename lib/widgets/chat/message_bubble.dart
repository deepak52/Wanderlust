import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? timestamp;
  final bool isSelected;
  final Widget? statusIcon;
  final VoidCallback? onDelete;
  final VoidCallback onTap;

  // ✅ Add these two:
  final String? replyToText;
  final bool isReplyFromMe;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.timestamp,
    this.isSelected = false,
    this.statusIcon,
    this.onDelete,
    required this.onTap,
    this.replyToText,
    this.isReplyFromMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue[200] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (replyToText != null)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  left: BorderSide(
                    color: isReplyFromMe ? Colors.blue : Colors.grey.shade500,
                    width: 4,
                  ),
                ),
              ),
              child: Text(
                '${isReplyFromMe ? "You" : "They"}: $replyToText',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(child: Text(text, style: const TextStyle(fontSize: 16))),
              const SizedBox(width: 6),
              if (timestamp != null || statusIcon != null)
                Row(
                  children: [
                    if (timestamp != null)
                      Text(
                        DateFormat('hh:mm a').format(timestamp!),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    if (statusIcon != null) ...[
                      const SizedBox(width: 4),
                      statusIcon!,
                    ],
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSelected && !isMe && onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: onDelete,
              padding: const EdgeInsets.only(top: 12),
            ),
          bubble,
          if (isSelected && isMe && onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: onDelete,
              padding: const EdgeInsets.only(top: 12),
            ),
        ],
      ),
    );
  }
}
