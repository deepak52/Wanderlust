import 'package:flutter/material.dart';
import '../../../helper/core/theme/color_helper.dart';

class ChoiceCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? assetIcon;
  final bool isSelected;
  final bool isSecondary;
  final VoidCallback onTap;
  final bool isEnabled;

  const ChoiceCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.assetIcon,
    required this.isSelected,
    this.isSecondary = false,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  State<ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<ChoiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant ChoiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _animController.forward().then((_) => _animController.reverse());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = widget.isSelected;
    final Color activeColor =
        widget.isSecondary ? AppColorHelper.warmGold : AppColorHelper.teal;
    final Color activeSurface = widget.isSecondary
        ? AppColorHelper.softCream
        : AppColorHelper.paleBlueSurface;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.isEnabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isHighlighted ? activeSurface : AppColorHelper.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted ? activeColor : AppColorHelper.borderTeal,
              width: isHighlighted ? 1.8 : 1.2,
            ),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColorHelper.darkNavy.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              if (widget.assetIcon != null || widget.icon != null) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 38,
                  height: 38,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? activeColor
                        : AppColorHelper.paleBlueSurface,
                    shape: BoxShape.circle,
                  ),
                  child: widget.assetIcon != null
                      ? Image.asset(
                          widget.assetIcon!,
                          fit: BoxFit.contain,
                        )
                      : Icon(
                          widget.icon,
                          color: isHighlighted ? Colors.white : activeColor,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight:
                            isHighlighted ? FontWeight.w800 : FontWeight.w700,
                        color: AppColorHelper.darkNavy,
                        letterSpacing: 0.6,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorHelper.subduedText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isHighlighted
                        ? activeColor
                        : AppColorHelper.borderTeal,
                    width: 1.6,
                  ),
                  color: isHighlighted ? activeColor : Colors.transparent,
                ),
                child: isHighlighted
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

