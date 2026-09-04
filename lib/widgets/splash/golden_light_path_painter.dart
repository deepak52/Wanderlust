import 'dart:ui';
import 'package:flutter/material.dart';

/// Paints the cinematic glowing golden light path (Storyboard Stage 4 & 5).
/// Ignites at the bottom and draws upwards through the valley towards the horizon.
class GoldenLightPathPainter extends CustomPainter {
  /// Progress of drawing the path: 0.0 -> 1.0
  final double progress;
  /// Glow intensity: 0.0 -> 1.0
  final double glow;

  GoldenLightPathPainter({
    required this.progress,
    this.glow = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.005) return;

    final double w = size.width;
    final double h = size.height;

    // Serpentine path winding from bottom center (x: 0.52w, y: 0.96h)
    // upwards through the valley to the horizon near (x: 0.50w, y: 0.46h)
    final Path fullPath = Path();
    fullPath.moveTo(w * 0.52, h * 0.96);

    fullPath.cubicTo(
      w * 0.44, h * 0.88,
      w * 0.62, h * 0.80,
      w * 0.55, h * 0.72,
    );
    fullPath.cubicTo(
      w * 0.48, h * 0.65,
      w * 0.42, h * 0.58,
      w * 0.50, h * 0.52,
    );
    fullPath.cubicTo(
      w * 0.54, h * 0.49,
      w * 0.48, h * 0.47,
      w * 0.50, h * 0.45,
    );

    // Extract path up to progress
    final metrics = fullPath.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final double currentLen = metric.length * progress.clamp(0.0, 1.0);
    final Path currentPath = metric.extractPath(0.0, currentLen);

    // 1. Wide diffuse golden aura
    final Paint auraPaint = Paint()
      ..color = const Color(0xFFF3C65B).withValues(alpha: 0.30 * glow)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    canvas.drawPath(currentPath, auraPaint);

    // 2. Medium luminous amber stroke
    final Paint mediumGlowPaint = Paint()
      ..color = const Color(0xFFF7D57F).withValues(alpha: 0.65 * glow)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(currentPath, mediumGlowPaint);

    // 3. Crisp radiant golden/ivory core
    final Paint corePaint = Paint()
      ..color = const Color(0xFFFFF9E6).withValues(alpha: 0.95 * glow)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(currentPath, corePaint);

    // 4. Sparkle head at the leading edge of the ignited light path
    if (currentLen > 4.0 && progress < 0.99) {
      final Tangent? tangent = metric.getTangentForOffset(currentLen);
      if (tangent != null) {
        final Offset headPos = tangent.position;
        final Paint headGlow = Paint()
          ..color = const Color(0xFFFFF2C2).withValues(alpha: 0.9 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
        canvas.drawCircle(headPos, 6.0, headGlow);

        final Paint headCore = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(headPos, 2.5, headCore);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GoldenLightPathPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.glow != glow;
  }
}
