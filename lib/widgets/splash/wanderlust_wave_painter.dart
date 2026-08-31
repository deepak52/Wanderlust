import 'package:flutter/material.dart';

/// Organic wave painter for Wanderlust splash-to-login transition.
/// Draws a smooth curved boundary in deep forest green (#0F2E1E)
/// starting at `baseWaveY` (below top logo header) down to bottom of screen.
class WanderlustWavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double baseWaveY;

  const WanderlustWavePainter({
    required this.progress,
    this.color = const Color(0xFF0F2E1E),
    this.baseWaveY = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Default base wave position: ~22% of screen height (below top logo header)
    final double targetBaseY = baseWaveY > 0 ? baseWaveY : size.height * 0.22;
    // Animate wave rising up from screen bottom to targetBaseY
    final double topY = size.height - ((size.height - targetBaseY) * progress);

    final path = Path();

    // Start at bottom-left
    path.moveTo(0, size.height);
    path.lineTo(0, topY + (14.0 * progress));

    // Smooth organic S-curve wave boundary
    path.cubicTo(
      size.width * 0.28,
      topY - (22.0 * progress),
      size.width * 0.68,
      topY + (26.0 * progress),
      size.width,
      topY - (10.0 * progress),
    );

    // Connect to bottom-right and close fill
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WanderlustWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.baseWaveY != baseWaveY;
  }
}
