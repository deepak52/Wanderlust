import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../helper/core/theme/color_helper.dart';

/// Reusable Wanderlust-themed message input field widget for chat screens.
class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String? hintText;
  final bool enabled;
  final bool isEditing;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type a message...',
    this.enabled = true,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColorHelper.chatSurfaceDark, // #161C1D
        border: Border(
          top: BorderSide(
            color: AppColorHelper.chatDivider, // #2E3739
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                decoration: BoxDecoration(
                  color: AppColorHelper.chatSurface, // #202628
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isEditing
                        ? AppColorHelper.warmGold
                        : AppColorHelper.chatDivider, // #2E3739
                    width: isEditing ? 1.4 : 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Attachment Icon
                    IconButton(
                      icon: const Icon(
                        Icons.attach_file_rounded,
                        color: AppColorHelper.chatTextSecondary,
                        size: 21,
                      ),
                      onPressed: enabled ? () {} : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      splashRadius: 18,
                      tooltip: 'Attach',
                    ),
                    const SizedBox(width: 4),

                    // Text Field
                    Expanded(
                      child: TextField(
                        controller: controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => onSend(),
                        maxLines: 5,
                        minLines: 1,
                        enabled: enabled,
                        cursorColor: isEditing
                            ? AppColorHelper.warmGold
                            : AppColorHelper.chatPrimaryTeal,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 14.5,
                            color: AppColorHelper.chatTextPrimary,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 14,
                              color: AppColorHelper.chatTextSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 4,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),

                    // Emoji Icon
                    IconButton(
                      icon: const Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        color: AppColorHelper.chatTextSecondary,
                        size: 21,
                      ),
                      onPressed: enabled ? () {} : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      splashRadius: 18,
                      tooltip: 'Emoji',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send / Confirm Edit Button
            GestureDetector(
              onTap: enabled ? onSend : null,
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: enabled
                      ? (isEditing
                          ? AppColorHelper.warmGold
                          : AppColorHelper.chatPrimaryTeal) // #0C6B63
                      : (isEditing
                          ? AppColorHelper.warmGold.withValues(alpha: 0.4)
                          : AppColorHelper.chatPrimaryTeal.withValues(alpha: 0.4)),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isEditing
                          ? AppColorHelper.warmGold.withValues(alpha: 0.3)
                          : AppColorHelper.chatPrimaryTeal.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isEditing ? Icons.check_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
