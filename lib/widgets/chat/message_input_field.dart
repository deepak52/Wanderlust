import 'package:flutter/material.dart';

import '../../helper/widget/text/app_text.dart';
import '../../helper/core/theme/color_helper.dart';

/// Reusable message input field widget for chat screens.
/// Adapts Wanderlust MessageInputField to Agro-Prod theme and shared widget patterns.
/// Uses native TextField with Agro-Prod text styles for consistency.
class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String? hintText;
  final bool enabled;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type a message...',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColorHelper.backgroundColor,
        border: Border(
          top: BorderSide(
            color: AppColorHelper.borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              maxLines: 5,
              minLines: 1,
              enabled: enabled,
              style: textStyle(
                15,
                AppColorHelper.primaryTextColor,
                FontWeight.w500,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: textStyle(
                  15,
                  AppColorHelper.hintTextColor,
                  FontWeight.w500,
                ),
                filled: true,
                fillColor: AppColorHelper.cardColor,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColorHelper.primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button using Agro-Prod buttonContainer pattern
          GestureDetector(
            onTap: enabled ? onSend : null,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                    enabled
                        ? AppColorHelper.primaryColor
                        : AppColorHelper.primaryColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(21),
              ),
              child: Icon(
                Icons.send_rounded,
                color: AppColorHelper.whiteTextColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
