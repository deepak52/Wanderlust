import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../helper/core/theme/color_helper.dart';

/// Reusable Wanderlust-themed date separator badge for chat history.
class ChatDateSeparator extends StatelessWidget {
  final DateTime date;

  const ChatDateSeparator({
    super.key,
    required this.date,
  });

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(dt.year, dt.month, dt.day);

    if (checkDate == today) {
      return 'TODAY';
    } else if (checkDate == yesterday) {
      return 'YESTERDAY';
    } else if (checkDate.year == today.year) {
      return DateFormat('EEEE, MMMM d').format(dt).toUpperCase();
    } else {
      return DateFormat('MMMM d, yyyy').format(dt).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF232A2C).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2E3739).withValues(alpha: 0.6),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          _formatDate(date),
          style: GoogleFonts.inter(
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColorHelper.chatTextSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
