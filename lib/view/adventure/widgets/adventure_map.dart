import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/adventure_controller.dart';
import '../../../helper/adventure_assets.dart';
import '../../../helper/core/theme/color_helper.dart';
import '../../../model/adventure_state_model.dart';
import 'adventure_map_painter.dart';

class AdventureMap extends StatelessWidget {
  final bool readOnly;
  final List<MapLandmarkNode>? customNodes;
  final List<MapRouteSegment>? customSegments;
  final bool isRevealing;

  const AdventureMap({
    super.key,
    this.readOnly = false,
    this.customNodes,
    this.customSegments,
    this.isRevealing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (readOnly) {
      final nodes = customNodes ?? [];
      final segments = customSegments ?? [];

      return LayoutBuilder(
        builder: (context, constraints) {
          final mapWidth = constraints.maxWidth;
          final mapHeight = constraints.maxHeight;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColorHelper.borderTeal,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColorHelper.darkNavy.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.5),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Natural Illustrated Map Texture Layer
                  Positioned.fill(
                    child: Image.asset(
                      AdventureAssets.revealMapTexture,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 2. Gentle Ambient Vignette for Depth
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.95,
                          colors: [
                            Colors.transparent,
                            AppColorHelper.darkNavy.withValues(alpha: 0.12),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Vector Path Canvas
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: AdventureMapPainter(
                          segments: segments,
                          progress: 1.0,
                        ),
                        size: Size(mapWidth, mapHeight),
                      ),
                    ),
                  ),

                  // 4. Smart Landmark & Collision-Free Label Engine
                  ..._buildSmartMapElements(
                    nodes: nodes,
                    mapWidth: mapWidth,
                    mapHeight: mapHeight,
                    highestStep: 0,
                    animProgress: 1.0,
                  ),

                  // 5. Minimal Map Compass Badge
                  Positioned(
                    top: 14,
                    left: 16,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColorHelper.cardSurface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColorHelper.borderTeal,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorHelper.darkNavy.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AdventureAssets.mapCompass,
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'EXPEDITION MAP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColorHelper.darkTeal,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    final AdventureController controller = Get.find<AdventureController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        final mapHeight = constraints.maxHeight;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isRevealing ? 0 : 24),
            border: isRevealing
                ? null
                : Border.all(
                    color: AppColorHelper.borderTeal,
                    width: 1.5,
                  ),
            boxShadow: isRevealing
                ? []
                : [
                    BoxShadow(
                      color: AppColorHelper.darkNavy.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isRevealing ? 0 : 22.5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Natural Illustrated Map Texture Layer
                Positioned.fill(
                  child: Image.asset(
                    AdventureAssets.revealMapTexture,
                    fit: BoxFit.cover,
                  ),
                ),

                // 2. Gentle Ambient Vignette for Depth
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.95,
                        colors: [
                          Colors.transparent,
                          AppColorHelper.darkNavy.withValues(alpha: 0.12),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Programmatic Vector Path Canvas (THE HERO)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: Obx(
                      () => CustomPaint(
                        painter: AdventureMapPainter(
                          segments: controller.rxPathSegments.toList(),
                          progress: isRevealing
                              ? controller.rxPathMergeProgress.value
                              : controller.rxPathAnimationProgress.value,
                          isRevealing: isRevealing,
                          revealStage: controller.rxRevealStage.value,
                          trailOpacity: controller.rxTrailOpacity.value,
                          compassNormalizedY: isRevealing
                              ? controller.rxCompassNormalizedY.value
                              : 0.82,
                          showUnifiedPath:
                              isRevealing && controller.rxShowUnifiedPath.value,
                          unifiedPathProgress: isRevealing
                              ? controller.rxUnifiedPathProgress.value
                              : 0.0,
                        ),
                        size: Size(mapWidth, mapHeight),
                      ),
                    ),
                  ),
                ),

                // 4. Illustrated Map Landmark Symbols & Smart Collision-Free Labels
                Obx(
                  () {
                    final nodes = controller.rxMapNodes.toList();
                    final animProgress = isRevealing
                        ? 1.0
                        : controller.rxPathAnimationProgress.value;
                    final int highestStep = nodes.isEmpty
                        ? 0
                        : nodes
                            .map((n) => n.stepRevealed)
                            .fold<int>(0, (max, v) => v > max ? v : max);

                    // Explicitly listen to reactive coordinates and reveal stage
                    final _ = controller.rxCompassNormalizedY.value;
                    final _ = controller.rxRevealStage.value;

                    return Stack(
                      children: _buildSmartMapElements(
                        nodes: nodes,
                        mapWidth: mapWidth,
                        mapHeight: mapHeight,
                        highestStep: highestStep,
                        animProgress: animProgress,
                        isRevealing: isRevealing,
                      ),
                    );
                  },
                ),

                // 5. Minimal Map Compass / Title Badge (Fades out cleanly during cinematic reveal)
                Positioned(
                  top: 14,
                  left: 16,
                  child: AnimatedOpacity(
                    opacity: isRevealing ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            AppColorHelper.cardSurface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColorHelper.borderTeal,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorHelper.darkNavy
                                .withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AdventureAssets.mapCompass,
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'EXPEDITION MAP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColorHelper.darkTeal,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds landmark icons and resolves boundary-safe, non-overlapping labels
  List<Widget> _buildSmartMapElements({
    required List<MapLandmarkNode> nodes,
    required double mapWidth,
    required double mapHeight,
    required int highestStep,
    required double animProgress,
    bool isRevealing = false,
  }) {
    if (mapWidth <= 0 || mapHeight <= 0) return [];

    final double safeLeft = mapWidth * 0.05;
    final double safeRight = mapWidth * 0.95;
    final double safeTop = mapHeight * 0.05;
    final double safeBottom = mapHeight * 0.95;

    // Header Safe Area to guarantee absolute separation from all landmarks and labels
    final Rect headerSafeRect = Rect.fromLTWH(
      mapWidth * 0.03,
      mapHeight * 0.02,
      (mapWidth * 0.48).clamp(135.0, 180.0),
      (mapHeight * 0.10).clamp(32.0, 44.0),
    );

    final List<Widget> widgets = [];
    final List<Rect> iconRects = [];
    final List<Rect> placedLabelRects = [];

    // 1. First pass: Place all landmark icons (safely bounded)
    for (final node in nodes) {
      final bool isDest = node.id == 'node_final_destination';
      final AdventureController controller = Get.find<AdventureController>();

      final double rawCx = (isDest && isRevealing)
          ? (mapWidth * 0.50)
          : node.normalizedPosition.dx * mapWidth;
      final double rawCy = (isDest && isRevealing)
          ? controller.rxCompassNormalizedY.value * mapHeight
          : node.normalizedPosition.dy * mapHeight;

      final halfSize = node.size / 2;
      final cx = (isDest && isRevealing)
          ? (mapWidth * 0.50)
          : rawCx.clamp(safeLeft + halfSize, safeRight - halfSize);
      final cy = rawCy.clamp(safeTop + halfSize, safeBottom - halfSize);

      final stage = controller.rxRevealStage.value;
      final bool isClimax = stage == RevealStage.youClimax ||
          stage == RevealStage.holdMoment ||
          stage == RevealStage.invitationCard;
      final bool isMerged = stage == RevealStage.pathsMerging ||
          stage == RevealStage.compassRising ||
          stage == RevealStage.firstThought ||
          stage == RevealStage.secondThought ||
          isClimax;
      final bool isNewest =
          (node.stepRevealed == highestStep && highestStep > 0);
      final double nodeScale = isDest
          ? (isClimax ? 1.70 : (isMerged ? 1.55 : 1.0))
          : (isNewest ? (animProgress * 1.0).clamp(0.0, 1.0) : 1.0);
      final double nodeOpacity = isRevealing
          ? (isDest ? 1.0 : 0.0)
          : (isNewest ? (animProgress * 1.0).clamp(0.0, 1.0) : 1.0);

      final iconRect = Rect.fromCenter(
        center: Offset(cx, cy),
        width: node.size,
        height: node.size,
      );
      iconRects.add(iconRect);

      widgets.add(
        AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          left: cx - halfSize,
          top: cy - halfSize,
          child: AnimatedScale(
            scale: nodeScale,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: nodeOpacity,
              duration: const Duration(milliseconds: 300),
              child: _buildLandmarkIcon(node),
            ),
          ),
        ),
      );
    }

    // 2. Second pass: Calculate smart collision-free, boundary-safe positions for labels
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (!node.showLabel || node.label.isEmpty) continue;

      final currentIconRect = iconRects[i];
      final cx = currentIconRect.center.dx;
      final cy = currentIconRect.center.dy;
      final bool isNewest =
          (node.stepRevealed == highestStep && highestStep > 0);
      final double scale =
          isNewest ? (animProgress * 1.0).clamp(0.0, 1.0) : 1.0;
      final double opacity = isRevealing
          ? 0.0
          : (isNewest ? (animProgress * 1.0).clamp(0.0, 1.0) : 1.0);

      final labelWidth = (node.label.length * 6.6) + 14.0;
      const labelHeight = 18.0;

      // Candidate placements in priority order
      final candidatePositions = <LabelPosition>[
        node.labelPosition,
        _oppositePosition(node.labelPosition),
        LabelPosition.below,
        LabelPosition.right,
        LabelPosition.above,
        LabelPosition.left,
      ];

      Rect? chosenRect;

      for (final pos in candidatePositions) {
        final rect = _calculateCandidateRect(
          pos: pos,
          cx: cx,
          cy: cy,
          nodeSize: node.size,
          labelWidth: labelWidth,
          labelHeight: labelHeight,
        );

        // Check if fits inside safe map boundaries
        final fitsInBounds = rect.left >= safeLeft &&
            rect.right <= safeRight &&
            rect.top >= safeTop &&
            rect.bottom <= safeBottom;

        if (!fitsInBounds) continue;

        // Check if overlaps with Header Safe Zone
        if (rect.overlaps(headerSafeRect.inflate(6.0))) continue;

        // Check if overlaps with any placed labels
        final overlapsLabels = placedLabelRects.any(
          (r) => r.inflate(2.0).overlaps(rect),
        );
        if (overlapsLabels) continue;

        // Check if overlaps other landmark icons (except its own icon)
        final overlapsOtherIcons = iconRects.where((r) => r != currentIconRect).any(
              (r) => r.inflate(1.5).overlaps(rect),
            );
        if (overlapsOtherIcons) continue;

        // Candidate fits cleanly without collision
        chosenRect = rect;
        break;
      }

      // If no candidate fit without collision, handle based on priority
      if (chosenRect == null) {
        if (node.isPrimary) {
          // Primary landmark: clamp strictly inside safe area avoiding header
          final defaultRect = _calculateCandidateRect(
            pos: node.labelPosition,
            cx: cx,
            cy: cy,
            nodeSize: node.size,
            labelWidth: labelWidth,
            labelHeight: labelHeight,
          );
          final clampedLeft =
              defaultRect.left.clamp(safeLeft, safeRight - labelWidth);
          double clampedTop =
              defaultRect.top.clamp(safeTop, safeBottom - labelHeight);

          final testRect =
              Rect.fromLTWH(clampedLeft, clampedTop, labelWidth, labelHeight);
          if (testRect.overlaps(headerSafeRect.inflate(4.0))) {
            clampedTop = headerSafeRect.bottom + 6.0;
          }

          chosenRect =
              Rect.fromLTWH(clampedLeft, clampedTop, labelWidth, labelHeight);
        } else {
          // Subdued/minor historical waypoint: suppress label to prevent clutter
          continue;
        }
      }

      placedLabelRects.add(chosenRect);

      widgets.add(
        Positioned(
          left: chosenRect.left,
          top: chosenRect.top,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 300),
              child: _buildLabelPill(node: node, labelWidth: labelWidth),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  LabelPosition _oppositePosition(LabelPosition pos) {
    switch (pos) {
      case LabelPosition.above:
        return LabelPosition.below;
      case LabelPosition.below:
        return LabelPosition.above;
      case LabelPosition.left:
        return LabelPosition.right;
      case LabelPosition.right:
        return LabelPosition.left;
    }
  }

  Rect _calculateCandidateRect({
    required LabelPosition pos,
    required double cx,
    required double cy,
    required double nodeSize,
    required double labelWidth,
    required double labelHeight,
  }) {
    switch (pos) {
      case LabelPosition.above:
        return Rect.fromLTWH(
          cx - (labelWidth / 2),
          cy - (nodeSize / 2) - labelHeight - 3.0,
          labelWidth,
          labelHeight,
        );
      case LabelPosition.below:
        return Rect.fromLTWH(
          cx - (labelWidth / 2),
          cy + (nodeSize / 2) + 3.0,
          labelWidth,
          labelHeight,
        );
      case LabelPosition.left:
        return Rect.fromLTWH(
          cx - (nodeSize / 2) - labelWidth - 4.0,
          cy - (labelHeight / 2),
          labelWidth,
          labelHeight,
        );
      case LabelPosition.right:
        return Rect.fromLTWH(
          cx + (nodeSize / 2) + 4.0,
          cy - (labelHeight / 2),
          labelWidth,
          labelHeight,
        );
    }
  }
  Widget _buildLandmarkIcon(MapLandmarkNode node) {
    final aura = _getLandmarkAuraConfig(node);

    return SizedBox(
      width: node.size,
      height: node.size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Luminous Radial Aura Halo behind the landmark asset
          Container(
            width: node.size * aura.radiusMultiplier,
            height: node.size * aura.radiusMultiplier,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.5,
                colors: [
                  aura.coreColor,
                  aura.outerColor,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Illustrated Landmark Artwork
          SizedBox(
            width: node.size,
            height: node.size,
            child: Image.asset(
              node.assetPath,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  _LandmarkAuraConfig _getLandmarkAuraConfig(MapLandmarkNode node) {
    if (node.id == 'node_final_destination') {
      final AdventureController controller = Get.find<AdventureController>();
      final stage = controller.rxRevealStage.value;
      final bool isClimax = stage == RevealStage.youClimax ||
          stage == RevealStage.holdMoment ||
          stage == RevealStage.invitationCard;
      final bool isRisingOrLater = stage == RevealStage.compassRising ||
          stage == RevealStage.firstThought ||
          stage == RevealStage.secondThought ||
          isClimax;
      return _LandmarkAuraConfig(
        coreColor: isClimax
            ? const Color(0xFFFFF7C8)
            : (isRisingOrLater
                ? const Color(0xFFFFF2B2)
                : const Color(0xE6FFE082)),
        outerColor: isClimax
            ? const Color(0xBBF3C65B)
            : const Color(0x88F3C65B),
        radiusMultiplier: isClimax ? 3.4 : (isRisingOrLater ? 2.8 : 1.9),
      );
    }
    if (node.id == 'start_origin') {
      return const _LandmarkAuraConfig(
        coreColor: Color(0xCC5DBBE8),
        outerColor: Color(0x55238F91),
        radiusMultiplier: 1.45,
      );
    }
    if (node.id.contains('sunrise')) {
      return const _LandmarkAuraConfig(
        coreColor: Color(0xCCFFD54F),
        outerColor: Color(0x66FFA726),
        radiusMultiplier: 1.6,
      );
    }
    if (node.id.contains('sunset')) {
      return const _LandmarkAuraConfig(
        coreColor: Color(0xCCFFA726),
        outerColor: Color(0x66FF7043),
        radiusMultiplier: 1.6,
      );
    }
    if (node.id.contains('campfire')) {
      return const _LandmarkAuraConfig(
        coreColor: Color(0xDDFFB74D),
        outerColor: Color(0x77FF5722),
        radiusMultiplier: 1.65,
      );
    }
    if (node.id.contains('lookout') || node.id.contains('bridge') || node.isSecondary) {
      return const _LandmarkAuraConfig(
        coreColor: Color(0xCCFFE082),
        outerColor: Color(0x55F3C65B),
        radiusMultiplier: 1.5,
      );
    }
    if (node.id.contains('pines') || node.id.contains('trail')) {
      return const _LandmarkAuraConfig(
        coreColor: Color(0xCC8BCB67),
        outerColor: Color(0x55388E3C),
        radiusMultiplier: 1.5,
      );
    }
    return const _LandmarkAuraConfig(
      coreColor: Color(0xCC8BCB67),
      outerColor: Color(0x55238F91),
      radiusMultiplier: 1.5,
    );
  }

  Widget _buildLabelPill({
    required MapLandmarkNode node,
    required double labelWidth,
  }) {
    final borderColor = node.isSecondary
        ? AppColorHelper.warmGold.withValues(alpha: 0.8)
        : AppColorHelper.borderTeal;
    final textColor = node.isSecondary
        ? AppColorHelper.darkNavy
        : AppColorHelper.darkText;

    return Container(
      width: labelWidth,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: node.isSecondary
            ? AppColorHelper.softCream
            : AppColorHelper.cardSurface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorHelper.darkNavy.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Text(
        node.label.toUpperCase(),
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 1.1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _LandmarkAuraConfig {
  final Color coreColor;
  final Color outerColor;
  final double radiusMultiplier;

  const _LandmarkAuraConfig({
    required this.coreColor,
    required this.outerColor,
    required this.radiusMultiplier,
  });
}
