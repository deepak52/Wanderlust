import 'dart:ui';
import 'package:flutter/material.dart';

/// Helper to render any transparent PNG asset with multi-layer contour shadow
Widget buildAssetWithContourShadow({
  required String assetPath,
  required double height,
  required Color color,
}) {
  return Stack(
    alignment: Alignment.center,
    children: [
      // 1. Deep atmospheric contour drop-shadow (follows exact silhouettes)
      Transform.translate(
        offset: const Offset(0, 2.5),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: SizedBox(
            height: height,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              color: Colors.black.withValues(alpha: 0.85),
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
      ),

      // 2. Crisp dark contrast rim (sharp edge against white clouds/stars)
      Transform.translate(
        offset: const Offset(0, 1.0),
        child: SizedBox(
          height: height,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            color: const Color(0xFF041014).withValues(alpha: 0.70),
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
      ),

      // 3. Radiant luminous gold foreground asset
      SizedBox(
        height: height,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          color: color,
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    ],
  );
}

/// Standalone Wanderlust Emblem (assets/images/wanderlustlogoUp.png)
class WanderlustEmblem extends StatelessWidget {
  final double height;
  final Color color;

  const WanderlustEmblem({
    super.key,
    this.height = 80.0,
    this.color = const Color(0xFFFFD54F),
  });

  @override
  Widget build(BuildContext context) {
    return buildAssetWithContourShadow(
      assetPath: 'assets/images/wanderlustlogoUp.png',
      height: height,
      color: color,
    );
  }
}

/// Standalone Wanderlust Name (assets/images/wanderlust.png)
class WanderlustName extends StatelessWidget {
  final double height;
  final Color color;

  const WanderlustName({
    super.key,
    this.height = 58.0,
    this.color = const Color(0xFFFFF1C2),
  });

  @override
  Widget build(BuildContext context) {
    return buildAssetWithContourShadow(
      assetPath: 'assets/images/wanderlust.png',
      height: height,
      color: color,
    );
  }
}

/// Combined Wanderlust Brand Logo with optional emblem
class WanderlustGoldenLogo extends StatelessWidget {
  final double emblemHeight;
  final double nameHeight;
  final double spacing;
  final double emblemOpacity;
  final Color emblemColor;
  final Color nameColor;

  const WanderlustGoldenLogo({
    super.key,
    this.emblemHeight = 80.0,
    this.nameHeight = 58.0,
    this.spacing = 6.0,
    this.emblemOpacity = 1.0,
    this.emblemColor = const Color(0xFFFFD54F),
    this.nameColor = const Color(0xFFFFF1C2),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (emblemOpacity > 0.005) ...[
          Opacity(
            opacity: emblemOpacity.clamp(0.0, 1.0),
            child: WanderlustEmblem(height: emblemHeight, color: emblemColor),
          ),
          SizedBox(height: spacing * emblemOpacity.clamp(0.0, 1.0)),
        ],
        WanderlustName(height: nameHeight, color: nameColor),
      ],
    );
  }
}
