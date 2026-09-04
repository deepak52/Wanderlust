import 'package:flutter/material.dart';
import '../../../model/adventure_state_model.dart';

class AdventureMapPainter extends CustomPainter {
  final List<MapRouteSegment> segments;
  final double progress;
  final Color primaryPathColor;
  final Color primaryGlowColor;
  final Color secondaryPathColor;
  final Color secondaryGlowColor;
  final bool isRevealing;
  final RevealStage revealStage;
  final double trailOpacity;
  final double compassNormalizedY;
  final bool showUnifiedPath;
  final double unifiedPathProgress;

  AdventureMapPainter({
    required this.segments,
    required this.progress,
    this.primaryPathColor = const Color(0xFF67B66A),
    this.primaryGlowColor = const Color(0x668BCB67),
    this.secondaryPathColor = const Color(0xFFF3C65B),
    this.secondaryGlowColor = const Color(0x66F3C65B),
    this.isRevealing = false,
    this.revealStage = RevealStage.none,
    this.trailOpacity = 1.0,
    this.compassNormalizedY = 0.82,
    this.showUnifiedPath = false,
    this.unifiedPathProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Draw ambient topographic guide contours ONLY during normal map gameplay
    if (!isRevealing) {
      _drawTopographicContours(canvas, size);
    }

    // 2. Draw unified golden curving path extending downward from the compass
    if (isRevealing && showUnifiedPath && unifiedPathProgress > 0.0) {
      final double compassX = size.width * 0.50;
      final double compassY = size.height * compassNormalizedY;

      final double startY = compassY + 28;
      final double totalH = size.height - startY;

      final unifiedPath = Path()..moveTo(compassX, startY);

      // Wave 1: Dynamic curve sweeping left through the upper valley
      unifiedPath.cubicTo(
        size.width * 0.40,
        startY + totalH * 0.12,
        size.width * 0.37,
        startY + totalH * 0.28,
        size.width * 0.49,
        startY + totalH * 0.46,
      );

      // Wave 2: Sweeping wide right along the river meander
      unifiedPath.cubicTo(
        size.width * 0.62,
        startY + totalH * 0.60,
        size.width * 0.63,
        startY + totalH * 0.78,
        size.width * 0.46,
        startY + totalH * 0.92,
      );

      // Wave 3: Finishing sweep down to the bottom
      unifiedPath.quadraticBezierTo(
        size.width * 0.40,
        startY + totalH * 0.97,
        size.width * 0.48,
        size.height * 1.0,
      );

      Path pathToDraw = unifiedPath;
      if (unifiedPathProgress < 1.0) {
        pathToDraw = Path();
        for (final metric in unifiedPath.computeMetrics()) {
          pathToDraw.addPath(
            metric.extractPath(
                0.0, metric.length * unifiedPathProgress.clamp(0.0, 1.0)),
            Offset.zero,
          );
        }
      }

      final outerGlow = Paint()
        ..color = const Color(0x66FFE082)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      final innerGlow = Paint()
        ..color = const Color(0xEEF3C65B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      final corePaint = Paint()
        ..color = const Color(0xFFFFF7D6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.8
        ..strokeCap = StrokeCap.round;

      _drawDashedPath(
        canvas,
        pathToDraw,
        outerGlow,
        dashLength: 9.0,
        gapLength: 6.0,
      );
      _drawDashedPath(
        canvas,
        pathToDraw,
        innerGlow,
        dashLength: 9.0,
        gapLength: 6.0,
      );
      _drawDashedPath(
        canvas,
        pathToDraw,
        corePaint,
        dashLength: 7.0,
        gapLength: 6.0,
      );
    }

    if (segments.isEmpty) return;
    if (isRevealing && trailOpacity <= 0.0) return;

    // During cinematic reveal, keep both the green and gold journey trails in their authentic geometry.
    final List<MapRouteSegment> activeSegments;
    if (isRevealing) {
      activeSegments = segments.where((s) => s.step <= 10).toList();
    } else {
      activeSegments = segments;
    }

    if (activeSegments.isEmpty) return;

    final double effectiveOpacity =
        isRevealing ? trailOpacity.clamp(0.0, 1.0) : 1.0;

    final primaryGlowPaint = Paint()
      ..color = primaryGlowColor.withValues(alpha: 0.70 * effectiveOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isRevealing ? 7.5 : 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final primaryPathPaint = Paint()
      ..color = primaryPathColor.withValues(alpha: effectiveOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isRevealing ? 3.6 : 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final secondaryGlowPaint = Paint()
      ..color = secondaryGlowColor.withValues(alpha: 0.70 * effectiveOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isRevealing ? 8.0 : 6.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final secondaryPathPaint = Paint()
      ..color = secondaryPathColor.withValues(alpha: effectiveOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isRevealing ? 3.8 : 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotFillPaint = Paint()
      ..color = const Color(0xFFEDE8DB).withValues(alpha: effectiveOpacity)
      ..style = PaintingStyle.fill;

    // Find the latest step number to animate newly added segments
    final int latestStep = activeSegments.isEmpty
        ? 0
        : activeSegments
            .map((s) => s.step)
            .fold<int>(0, (max, s) => s > max ? s : max);

    for (int i = 0; i < activeSegments.length; i++) {
      final segment = activeSegments[i];
      final bool isFinalPortion = (segment.step == 10);
      final double segmentProgress = isRevealing
          ? (isFinalPortion ? progress.clamp(0.0, 1.0) : 1.0)
          : ((segment.step == latestStep && latestStep > 0)
              ? progress.clamp(0.0, 1.0)
              : 1.0);

      final p0 = Offset(
          segment.start.dx * size.width, segment.start.dy * size.height);
      final p1 = Offset(
          segment.control1.dx * size.width, segment.control1.dy * size.height);
      final p2 = Offset(
          segment.control2.dx * size.width, segment.control2.dy * size.height);
      final p3 =
          Offset(segment.end.dx * size.width, segment.end.dy * size.height);

      final fullPath = Path()
        ..moveTo(p0.dx, p0.dy)
        ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

      Path pathSegmentToDraw;
      if (segmentProgress < 1.0) {
        final pathMetrics = fullPath.computeMetrics();
        pathSegmentToDraw = Path();
        for (final metric in pathMetrics) {
          final extractLength = metric.length * segmentProgress;
          pathSegmentToDraw.addPath(
            metric.extractPath(0.0, extractLength),
            Offset.zero,
          );
        }
      } else {
        pathSegmentToDraw = fullPath;
      }

      final glow = segment.isSecondaryPath
          ? secondaryGlowPaint
          : primaryGlowPaint;
      final path = segment.isSecondaryPath
          ? secondaryPathPaint
          : primaryPathPaint;
      final ringColor = segment.isSecondaryPath
          ? secondaryPathColor
          : primaryPathColor;

      final dotRingPaint = Paint()
        ..color = ringColor.withValues(alpha: effectiveOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw dashed glow & trail
      _drawDashedPath(
        canvas,
        pathSegmentToDraw,
        glow,
        dashLength: segment.isSecondaryPath ? 10.0 : 9.0,
        gapLength: 5.0,
      );
      _drawDashedPath(
        canvas,
        pathSegmentToDraw,
        path,
        dashLength: segment.isSecondaryPath ? 8.0 : 8.0,
        gapLength: 5.0,
      );

      // Draw junction node circle
      canvas.drawCircle(p0, 3.5, dotFillPaint);
      canvas.drawCircle(p0, 5.0, dotRingPaint);

      if (segmentProgress >= 0.98) {
        canvas.drawCircle(p3, 3.5, dotFillPaint);
        canvas.drawCircle(p3, 5.0, dotRingPaint);
      }
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path source,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final metrics = source.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = (distance + dashLength < metric.length)
            ? distance + dashLength
            : metric.length;
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  void _drawTopographicContours(Canvas canvas, Size size) {
    final contourPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..cubicTo(size.width * 0.3, size.height * 0.25, size.width * 0.7,
          size.height * 0.35, size.width, size.height * 0.28);
    canvas.drawPath(path1, contourPaint);

    final path2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..cubicTo(size.width * 0.4, size.height * 0.65, size.width * 0.6,
          size.height * 0.55, size.width, size.height * 0.62);
    canvas.drawPath(path2, contourPaint);
  }

  @override
  bool shouldRepaint(covariant AdventureMapPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.segments.length != segments.length ||
        oldDelegate.primaryPathColor != primaryPathColor ||
        oldDelegate.secondaryPathColor != secondaryPathColor ||
        oldDelegate.isRevealing != isRevealing ||
        oldDelegate.revealStage != revealStage ||
        oldDelegate.trailOpacity != trailOpacity ||
        oldDelegate.compassNormalizedY != compassNormalizedY ||
        oldDelegate.showUnifiedPath != showUnifiedPath ||
        oldDelegate.unifiedPathProgress != unifiedPathProgress;
  }
}
