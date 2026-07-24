import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../helper/widget/text/app_text.dart';
import '../../helper/core/theme/color_helper.dart';

/// Reusable message bubble widget for chat screens.
/// Adapts Wanderlust MessageBubble to Agro-Prod theme and patterns.
class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? timestamp;
  final bool isSelected;
  final Widget? statusIcon;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
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
    // Bubble colors based on theme
    final bubbleColor =
        isMe
            ? AppColorHelper.primaryColor.withValues(alpha: 0.15)
            : AppColorHelper.cardColor;
    final textColor =
        isMe
            ? AppColorHelper.primaryTextColor
            : AppColorHelper.primaryTextColor;
    final secondaryTextColor = AppColorHelper.secondaryTextColor;
    final replyBorderColor =
        isReplyFromMe
            ? AppColorHelper.primaryColor
            : AppColorHelper.secondaryTextColor;

    // The inner bubble content
    final bubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(12),
        border:
            isSelected
                ? Border.all(color: AppColorHelper.primaryColor, width: 2)
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply preview
          if (replyToText != null && !deleted)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColorHelper.backgroundColor,
                border: Border(
                  left: BorderSide(color: replyBorderColor, width: 4),
                ),
              ),
              child: Text(
                '${isReplyFromMe ? "You" : "They"}: $replyToText',
                style: textStyle(
                  12,
                  secondaryTextColor,
                  FontWeight.w500,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Message content + timestamp/status row
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child:
                    deleted
                        ? Text(
                          'This message was deleted',
                          style: textStyle(
                            14,
                            AppColorHelper.warningRedColor,
                            FontWeight.w400,
                            height: 1.3,
                          ).copyWith(fontStyle: FontStyle.italic),
                        )
                        : Text(
                          text,
                          style: textStyle(
                            15,
                            textColor,
                            FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
              ),
              const SizedBox(width: 6),
              if (!deleted && (timestamp != null || statusIcon != null))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (timestamp != null)
                      Text(
                        DateFormat('hh:mm a').format(timestamp!),
                        style: textStyle(
                          10,
                          secondaryTextColor.withValues(alpha: 0.8),
                          FontWeight.w400,
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

    // Wrap with GestureDetector for tap handling
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
