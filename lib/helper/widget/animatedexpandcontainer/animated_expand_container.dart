import 'package:flutter/material.dart';

class AnimatedExpandContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double initialHeight;
  final Duration delay;
  final double finalHeight;
  final double initialWidth;
  final double finalWidth;
  final Alignment alignment;
  final bool clipChild;
  final VoidCallback? onComplete;

  const AnimatedExpandContainer({
    super.key,
    required this.child,
    this.onComplete,
    this.duration = const Duration(seconds: 1),
    this.initialHeight = 0.0,
    this.delay = const Duration(milliseconds: 800),
    this.finalHeight = double.infinity,
    this.initialWidth = double.infinity,
    this.finalWidth = 0.0,
    this.alignment = Alignment.topCenter,
    this.clipChild = false,
  });

  @override
  State<AnimatedExpandContainer> createState() =>
      _AnimatedExpandContainerState();
}

class _AnimatedExpandContainerState extends State<AnimatedExpandContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _heightAnimation = Tween<double>(
      begin: widget.initialHeight,
      end: widget.finalHeight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _widthAnimation = Tween<double>(
      begin: widget.initialWidth,
      end: widget.finalWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();

        Future.delayed(widget.duration, () {
          if (mounted) widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return Align(
          alignment: widget.alignment,
          child: Container(
            width: _widthAnimation.value,
            height: _heightAnimation.value,
            color: Colors.transparent,
            child:
                widget.clipChild ? ClipRect(child: widget.child) : widget.child,
          ),
        );
      },
    );
  }
}
