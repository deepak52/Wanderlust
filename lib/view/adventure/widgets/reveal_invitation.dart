import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controller/adventure_controller.dart';
import '../../../model/adventure_state_model.dart';

/// Transparent overlay over the full-screen AdventureMap displaying cumulative story text
/// and the floating frosted invitation dialog box matching the reference storyboard.
class RevealInvitation extends StatelessWidget {
  const RevealInvitation({super.key});

  @override
  Widget build(BuildContext context) {
    final AdventureController controller = Get.find<AdventureController>();
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Obx(() {
      final stage = controller.rxRevealStage.value;
      final selectedResponse = controller.rxSelectedInvitationResponse.value;

      final bool showFirstThought = stage == RevealStage.firstThought ||
          stage == RevealStage.secondThought ||
          stage == RevealStage.youClimax ||
          stage == RevealStage.holdMoment ||
          stage == RevealStage.invitationCard;

      final bool showSecondThought = stage == RevealStage.secondThought ||
          stage == RevealStage.youClimax ||
          stage == RevealStage.holdMoment ||
          stage == RevealStage.invitationCard;

      final bool showYouClimax = stage == RevealStage.youClimax ||
          stage == RevealStage.holdMoment ||
          stage == RevealStage.invitationCard;

      final bool showInvitationCard = stage == RevealStage.invitationCard;

      // Card height is ~48% of the screen height
      final double cardHeight = (screenHeight * 0.48).clamp(350.0, 420.0);

      return Material(
        color: Colors.transparent,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // 1. Cinematic atmospheric vignette over upper landscape
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: screenHeight * 0.55,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0x99031017),
                          const Color(0x40031017),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Cumulative Narrative Flow (Centered on X, positioned above compass at y=0.45)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: screenHeight * 0.55,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Thought 1: "Turns out, I wasn't really trying to find a place..."
                        AnimatedOpacity(
                          opacity: showFirstThought ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          child: Text(
                            "Turns out,\nI wasn't really trying\nto find a place...",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize:
                                  (screenWidth * 0.066).clamp(24.0, 30.0),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF7EED8),
                              height: 1.25,
                              letterSpacing: 0.3,
                              shadows: const [
                                Shadow(
                                  color: Color(0xDD020C10),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                                Shadow(
                                  color: Color(0x88000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (showSecondThought) ...[
                          const SizedBox(height: 8),
                          _buildFlourish(starSize: 11, lineWidth: 38),
                          const SizedBox(height: 8),
                        ] else ...[
                          const SizedBox(height: 12),
                        ],

                        // Thought 2: "I was wondering who I'd want to go with." (Thought 1 stays visible!)
                        AnimatedOpacity(
                          opacity: showSecondThought ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          child: Text(
                            "I was wondering\nwho I'd want to go with.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize:
                                  (screenWidth * 0.068).clamp(25.0, 31.0),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF7EED8),
                              height: 1.25,
                              letterSpacing: 0.3,
                              shadows: const [
                                Shadow(
                                  color: Color(0xDD020C10),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                                Shadow(
                                  color: Color(0x88000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (showYouClimax) ...[
                          const SizedBox(height: 8),
                          _buildFlourish(starSize: 11, lineWidth: 38),
                          const SizedBox(height: 8),
                        ] else ...[
                          const SizedBox(height: 12),
                        ],

                        // Thought 3: The Climax "YOU." (Dead-center on X, close above compass)
                        AnimatedScale(
                          scale: showYouClimax ? 1.0 : 0.84,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutBack,
                          child: AnimatedOpacity(
                            opacity: showYouClimax ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            child: Text(
                              'YOU.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize:
                                    (screenWidth * 0.185).clamp(66.0, 84.0),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFBE6B3),
                                letterSpacing: 3.5,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFFF3C65B)
                                        .withValues(alpha: 0.90),
                                    blurRadius: 30,
                                  ),
                                  const Shadow(
                                    color: Color(0xDD020C10),
                                    blurRadius: 16,
                                    offset: Offset(0, 3),
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

              // 3. Floating Frosted Glass Invitation Card (Matches Image 2 exactly)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                left: 16,
                right: 16,
                height: cardHeight,
                bottom: showInvitationCard ? 18 : -(cardHeight + 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      height: cardHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xED0D1F26),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0x4D68A2A8),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.55),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Subtitle "So..."
                          Text(
                            'So...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFE5DDD0),
                              letterSpacing: 0.5,
                            ),
                          ),

                          // Invitation Heading (2 lines, much bigger)
                          Text(
                            'Want to find\nsomewhere with me?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize:
                                  (screenWidth * 0.076).clamp(27.0, 34.0),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFBF4E4),
                              height: 1.22,
                              letterSpacing: 0.4,
                              shadows: const [
                                Shadow(
                                  color: Color(0x88000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),

                          // Star Flourish Divider
                          _buildFlourish(starSize: 13, lineWidth: 38),

                          // Action Button 1: YES, LET'S GO (Bigger text & height)
                          _buildActionButton(
                            title: "YES, LET'S GO",
                            icon: Icons.check_circle_outline_rounded,
                            isPrimary: true,
                            isSelected: selectedResponse == "YES, LET'S GO",
                            onTap: () => controller
                                .selectInvitationOption("YES, LET'S GO"),
                          ),

                          // Action Button 2: TELL ME MORE (Bigger text & height)
                          _buildActionButton(
                            title: 'TELL ME MORE',
                            icon: Icons.chat_bubble_outline_rounded,
                            isPrimary: false,
                            isSelected: selectedResponse == 'TELL ME MORE',
                            onTap: () => controller
                                .selectInvitationOption('TELL ME MORE'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required bool isPrimary,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bgColor = isPrimary ? const Color(0xFF196971) : Colors.transparent;
    const fgColor = Colors.white;
    final borderColor = isPrimary
        ? const Color(0xFF196971)
        : const Color(0x6686B3B8);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF227E87) : bgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isSelected ? Colors.white : borderColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPrimary || isSelected)
                ? const Color(0xFF196971).withValues(alpha: 0.40)
                : Colors.transparent,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: fgColor,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: fgColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlourish({double starSize = 9.0, double lineWidth = 32.0}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: lineWidth,
          height: 0.8,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color(0xCCF3C65B),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '✦',
          style: TextStyle(
            color: const Color(0xFFF3C65B),
            fontSize: starSize,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: lineWidth,
          height: 0.8,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xCCF3C65B),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
