import 'dart:ui';
import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final String backgroundImage;
  final Widget child;
  final bool blur;

  const BackgroundContainer({
    super.key,
    required this.backgroundImage,
    required this.child,
    this.blur = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          backgroundImage,
          fit: BoxFit.cover,
        ),
        if (blur)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withAlpha(51),
            ),
          ),
        child,
      ],
    );
  }
}
