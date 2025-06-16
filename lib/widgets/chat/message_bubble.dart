import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? timestamp;
  final bool isSelected;
  final Widget? statusIcon;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  // ✅ New
  final VoidCallback? onEdit;

  final String? replyToText;
  final bool isReplyFromMe;
  final bool deleted;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.timestamp,
    this.isSelected = false,
    this.statusIcon,
    this.onDelete,
    this.onTap,
    this.onEdit,
    this.replyToText,
    this.isReplyFromMe = false,
    required this.deleted,
  });

  @override
  Widget build(BuildContext context) {

    print('Rendering bubble: deleted=$deleted, text="$text"');

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
          if (replyToText != null && !deleted)
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
              Flexible(
                child:
                    deleted
                        ? Text(
                          'This message was deleted',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.red.shade400,
                            fontSize: 14,
                          ),
                        )
                        : Text(text, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 6),
              if (!deleted && (timestamp != null || statusIcon != null))
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
        children: [bubble],
      ),
    );
  }
}
