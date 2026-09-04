import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../helper/core/theme/color_helper.dart';

/// Reusable Wanderlust-themed message bubble widget for chat screens.
class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? timestamp;
  final bool isSelected;
  final Widget? statusIcon;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final String? replyToText;
  final bool isReplyFromMe;
  final bool deleted;
  final bool edited;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.timestamp,
    this.isSelected = false,
    this.statusIcon,
    this.onDelete,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.replyToText,
    this.isReplyFromMe = false,
    required this.deleted,
    this.edited = false,
  });

  bool get _isAdventureOpeningMessage {
    return !isMe &&
        (text.contains("we're going") ||
            text.contains("adventure hasn't started yet"));
  }

  @override
  Widget build(BuildContext context) {
    // Wanderlust Redesign Visual Palette
    final bubbleColor = isSelected
        ? AppColorHelper.chatSelectedHighlight
        : (isMe
            ? AppColorHelper.chatPrimaryTeal // #0C6B63
            : AppColorHelper.chatIncomingBubble); // #FFFFFF

    final textColor = isSelected
        ? AppColorHelper.chatTextPrimary
        : (isMe
            ? Colors.white
            : AppColorHelper.chatIncomingText); // #1C2323

    final timeColor = isSelected
        ? AppColorHelper.chatTextSecondary
        : (isMe
            ? Colors.white.withValues(alpha: 0.7)
            : const Color(0xFF8A9999));

    final replyBgColor = isMe
        ? const Color(0xFF084B45)
        : const Color(0xFFF2F6F6);

    final replyBorderColor =
        isMe ? const Color(0xFF26C6DA) : AppColorHelper.chatPrimaryTeal;

    const borderRadius = BorderRadius.all(Radius.circular(16));

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.76,
      ),
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: borderRadius,
        border: isSelected
            ? Border.all(color: AppColorHelper.chatPrimaryTeal, width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Special Adventure Opening Header Tag
          if (_isAdventureOpeningMessage) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColorHelper.chatDeepTeal.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColorHelper.chatPrimaryTeal,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.explore,
                    size: 10,
                    color: AppColorHelper.chatSeenTick,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'THE ADVENTURE CONTINUES',
                    style: GoogleFonts.cinzel(
                      textStyle: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColorHelper.chatSeenTick,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Reply Preview Block
          if (replyToText != null && !deleted)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: replyBgColor,
                borderRadius: BorderRadius.circular(6),
                border: Border(
                  left: BorderSide(color: replyBorderColor, width: 3),
                ),
              ),
              child: Text(
                '${isReplyFromMe ? "You" : "Companion"}: $replyToText',
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppColorHelper.chatIncomingText.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    height: 1.25,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Message text content + timestamp/status row
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: deleted
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.block_rounded,
                            size: 13,
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.6)
                                : AppColorHelper.chatTextSecondary,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'This message was deleted',
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  fontSize: 13.5,
                                  color: isMe
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : AppColorHelper.chatTextSecondary,
                                  fontStyle: FontStyle.italic,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        text,
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: isMe ? FontWeight.w500 : FontWeight.w400,
                            height: 1.32,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              if (!deleted && (timestamp != null || statusIcon != null))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (edited) ...[
                      Text(
                        'edited',
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 9.5,
                            fontStyle: FontStyle.italic,
                            color: timeColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (timestamp != null)
                      Text(
                        DateFormat('hh:mm a').format(timestamp!),
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 11,
                            color: timeColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    if (statusIcon != null) ...[
                      const SizedBox(width: 4),
                      statusIcon!,
                    ],
                    if (isSelected) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: AppColorHelper.chatPrimaryTeal,
                      ),
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
      onLongPress: onLongPress ?? onTap,
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [bubble],
      ),
    );
  }
}
