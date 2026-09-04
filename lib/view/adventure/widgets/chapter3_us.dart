import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controller/adventure_controller.dart';
import '../../../helper/core/theme/color_helper.dart';
import '../../../model/adventure_state_model.dart';
import 'choice_card.dart';

class Chapter3Us extends StatelessWidget {
  const Chapter3Us({super.key});

  @override
  Widget build(BuildContext context) {
    final AdventureController controller = Get.find<AdventureController>();

    return Obx(() {
      final chapter = controller.rxChapter.value;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _buildCurrentSubView(context, chapter, controller),
      );
    });
  }

  Widget _buildCurrentSubView(BuildContext context, AdventureChapter chapter,
      AdventureController controller) {
    switch (chapter) {
      case AdventureChapter.chapter3Intro:
        return _buildChapter3IntroView(context, controller);
      case AdventureChapter.chapter3:
        return _buildInteractionGameplayView(context, controller);
      case AdventureChapter.chapter3Complete:
      case AdventureChapter.chapter3Placeholder:
        return _buildChapter3CompletionView(context, controller);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 1. Chapter 3 Intro Prologue
  Widget _buildChapter3IntroView(
      BuildContext context, AdventureController controller) {
    return Container(
      key: const ValueKey('ch3_intro'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColorHelper.cardSurface,
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorHelper.paleBlueSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColorHelper.borderTeal,
                    width: 1,
                  ),
                ),
                child: const Text(
                  'ONE LAST THOUGHT',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColorHelper.teal,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "THERE'S ONE MORE THING",
            style: GoogleFonts.cinzel(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColorHelper.darkText,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "You know where you like to go.",
            style: TextStyle(
              fontSize: 14.5,
              color: AppColorHelper.darkText,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "You know how you like to wander.",
            style: TextStyle(
              fontSize: 14,
              color: AppColorHelper.subduedText,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "What happens when it's not just you anymore?",
            style: TextStyle(
              fontSize: 15,
              color: AppColorHelper.teal,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorHelper.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: AppColorHelper.teal.withValues(alpha: 0.35),
              ),
              onPressed: controller.startChapter3,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BEGIN',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Chapter 3 Interaction Gameplay
  Widget _buildInteractionGameplayView(
      BuildContext context, AdventureController controller) {
    return Obx(() {
      final currentInter = controller.currentInteraction;
      final selectedOption = controller.rxSelectedCurrentOption.value;
      final isAdvancing = controller.rxIsAdvancing.value;

      final int stepNumber = currentInter.index + 6;
      String sectionTag;
      String footnoteText;

      if (currentInter.index == 1) {
        sectionTag = 'EVENING MAGIC';
        footnoteText = 'Warmth, stories and stars.';
      } else if (currentInter.index == 2) {
        sectionTag = 'THE MOMENT';
        footnoteText = 'Look closer to find wonder.';
      } else {
        sectionTag = 'THE DESTINATION';
        footnoteText = 'Some journeys change everything.';
      }

      return Column(
        key: ValueKey('interaction_${currentInter.index}'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step Tracker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorHelper.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColorHelper.borderTeal,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorHelper.darkNavy.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Text(
                  '0$stepNumber / 09',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColorHelper.teal,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                sectionTag,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColorHelper.subduedText,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            currentInter.title,
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 17.5,
              fontWeight: FontWeight.w700,
              color: AppColorHelper.darkNavy,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),

          // Story Scenario Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppColorHelper.paleBlueSurface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColorHelper.borderTeal,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentInter.promptLine1,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColorHelper.darkNavy,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (currentInter.promptLine2 != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    currentInter.promptLine2!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColorHelper.subduedText,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                if (currentInter.promptLine3 != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    currentInter.promptLine3!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColorHelper.teal,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Animated Decision Cards
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(currentInter.index),
              child: Column(
                children: [
                  ChoiceCard(
                    title: currentInter.optionA,
                    icon: currentInter.iconA,
                    assetIcon: currentInter.definitionA.assetPath,
                    isSecondary: currentInter.definitionA.isPathB,
                    isSelected: selectedOption == currentInter.optionA,
                    isEnabled: !isAdvancing,
                    onTap: () => controller
                        .selectInteractionChoice(currentInter.optionA),
                  ),
                  const SizedBox(height: 10),
                  ChoiceCard(
                    title: currentInter.optionB,
                    icon: currentInter.iconB,
                    assetIcon: currentInter.definitionB.assetPath,
                    isSecondary: currentInter.definitionB.isPathB,
                    isSelected: selectedOption == currentInter.optionB,
                    isEnabled: !isAdvancing,
                    onTap: () => controller
                        .selectInteractionChoice(currentInter.optionB),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Atmospheric Quote Footnote
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                currentInter.index == 1
                    ? Icons.local_fire_department_rounded
                    : Icons.spa_rounded,
                size: 13,
                color: currentInter.index == 1
                    ? AppColorHelper.warmGold
                    : AppColorHelper.teal,
              ),
              const SizedBox(width: 6),
              Text(
                footnoteText,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  color: AppColorHelper.subduedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  /// 3. Chapter 3 Completion View
  Widget _buildChapter3CompletionView(
      BuildContext context, AdventureController controller) {
    return Container(
      key: const ValueKey('ch3_complete'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColorHelper.cardSurface,
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorHelper.paleBlueSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColorHelper.warmGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'A quiet realization.',
                style: GoogleFonts.cinzel(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColorHelper.darkText,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "Maybe that's the thing about a journey.",
            style: TextStyle(
              fontSize: 15.5,
              color: AppColorHelper.darkText,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "It's not always the place you'll remember.",
            style: TextStyle(
              fontSize: 15,
              color: AppColorHelper.subduedText,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "It's who you shared it with.",
            style: TextStyle(
              fontSize: 16,
              color: AppColorHelper.teal,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorHelper.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                shadowColor: AppColorHelper.teal.withValues(alpha: 0.35),
              ),
              onPressed: controller.onContinueChapter3,
              child: const Text(
                'CONTINUE',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
