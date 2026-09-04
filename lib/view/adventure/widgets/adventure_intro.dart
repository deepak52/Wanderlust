import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../helper/adventure_assets.dart';
import '../../../helper/core/theme/color_helper.dart';

class AdventureIntro extends StatefulWidget {
  final VoidCallback onStart;

  const AdventureIntro({
    super.key,
    required this.onStart,
  });

  @override
  State<AdventureIntro> createState() => _AdventureIntroState();
}

class _AdventureIntroState extends State<AdventureIntro>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeHeader;
  late Animation<double> _fadeBody;
  late Animation<double> _fadeButton;
  late Animation<Offset> _slideContent;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeHeader = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _fadeBody = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _fadeButton = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideContent = Tween<Offset>(
      begin: const Offset(0.0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Atmospheric Painterly Background (welcome_mysterious.png)
        Positioned.fill(
          child: Image.asset(
            AdventureAssets.bgWelcomeMysterious,
            fit: BoxFit.cover,
          ),
        ),

        // 2. Cinematic Vignette Overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColorHelper.darkNavy.withValues(alpha: 0.65),
                  AppColorHelper.darkNavy.withValues(alpha: 0.30),
                  AppColorHelper.darkNavy.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // 3. Elegant Intro Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: SlideTransition(
              position: _slideContent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Title / Accent Mark
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _fadeHeader,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColorHelper.cardSurface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColorHelper.borderTeal,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColorHelper.darkNavy.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: AppColorHelper.warmGold,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'A SPECIAL ADVENTURE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColorHelper.darkTeal,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Main Hook Typography
                      FadeTransition(
                        opacity: _fadeHeader,
                        child: Text(
                          'I made something\nfor you.',
                          style: GoogleFonts.cinzel(
                            textStyle: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.25,
                              letterSpacing: 0.4,
                              shadows: [
                                Shadow(
                                  blurRadius: 16,
                                  color: Colors.black87,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Middle Context Body
                  FadeTransition(
                    opacity: _fadeBody,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColorHelper.cardSurface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColorHelper.borderTeal,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColorHelper.darkNavy.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "It's not a quiz.\nIt's not a test.\nAnd there's no wrong answer.",
                            style: TextStyle(
                              fontSize: 17,
                              color: AppColorHelper.darkText,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColorHelper.teal,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Just play along.",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColorHelper.teal,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Button
                  FadeTransition(
                    opacity: _fadeButton,
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorHelper.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 6,
                          shadowColor:
                              AppColorHelper.teal.withValues(alpha: 0.4),
                        ),
                        onPressed: widget.onStart,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "LET'S PLAY",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.4,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

