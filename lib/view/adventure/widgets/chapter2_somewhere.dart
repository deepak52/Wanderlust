import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controller/adventure_controller.dart';
import '../../../helper/core/theme/color_helper.dart';
import '../../../model/adventure_state_model.dart';
import 'choice_card.dart';

class Chapter2Somewhere extends StatelessWidget {
  const Chapter2Somewhere({super.key});

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
      case AdventureChapter.chapter2Intro:
        return _buildChapter2IntroView(context, controller);
      case AdventureChapter.chapter2:
        return _buildSituationGameplayView(context, controller);
      case AdventureChapter.chapter2Complete:
        return _buildChapter2CompletionView(context, controller);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 1. Chapter 2 Intro Prologue
  Widget _buildChapter2IntroView(
      BuildContext context, AdventureController controller) {
    return Container(
      key: const ValueKey('ch2_intro'),
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
                  'THE TRAIL',
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
            'WHERE THE ROAD LEADS',
            style: GoogleFonts.cinzel(
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColorHelper.darkText,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Now imagine being there.',
            style: TextStyle(
              fontSize: 15,
              color: AppColorHelper.teal,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "You don't know what's around the next bend.\nThat's the best part.",
            style: TextStyle(
              fontSize: 14,
              color: AppColorHelper.subduedText,
              height: 1.45,
              fontWeight: FontWeight.w400,
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
              onPressed: controller.startChapter2,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ENTER THE JOURNEY',
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

  /// 2. Chapter 2 Situation Gameplay
  Widget _buildSituationGameplayView(
      BuildContext context, AdventureController controller) {
    return Obx(() {
      final currentSit = controller.currentSituation;
      final selectedOption = controller.rxSelectedCurrentOption.value;
      final isAdvancing = controller.rxIsAdvancing.value;

      final int stepNumber = currentSit.index + 3;
      String sectionTag;
      String footnoteText;

      if (currentSit.index == 1) {
        sectionTag = 'MEMORIES';
        footnoteText = 'Memories make the journey last forever.';
      } else if (currentSit.index == 2) {
        sectionTag = 'THE CROSSROADS';
        footnoteText = 'Every choice leads somewhere new.';
      } else {
        sectionTag = 'THE CROSSING';
        footnoteText = 'The crossing awaits.';
      }

      return Column(
        key: ValueKey('situation_${currentSit.index}'),
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

          // Situation Title
          Text(
            currentSit.title,
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
                  currentSit.promptLine1,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColorHelper.darkNavy,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (currentSit.promptLine2 != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    currentSit.promptLine2!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColorHelper.subduedText,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                if (currentSit.promptLine3 != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    currentSit.promptLine3!,
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
              key: ValueKey<int>(currentSit.index),
              child: Column(
                children: [
                  ChoiceCard(
                    title: currentSit.optionA,
                    icon: currentSit.iconA,
                    assetIcon: currentSit.definitionA.assetPath,
                    isSecondary: currentSit.definitionA.isPathB,
                    isSelected: selectedOption == currentSit.optionA,
                    isEnabled: !isAdvancing,
                    onTap: () =>
                        controller.selectSituationDecision(currentSit.optionA),
                  ),
                  const SizedBox(height: 10),
                  ChoiceCard(
                    title: currentSit.optionB,
                    icon: currentSit.iconB,
                    assetIcon: currentSit.definitionB.assetPath,
                    isSecondary: currentSit.definitionB.isPathB,
                    isSelected: selectedOption == currentSit.optionB,
                    isEnabled: !isAdvancing,
                    onTap: () =>
                        controller.selectSituationDecision(currentSit.optionB),
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
              const Icon(
                Icons.spa_rounded,
                size: 13,
                color: AppColorHelper.teal,
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

  /// 3. Chapter 2 Completion View
  Widget _buildChapter2CompletionView(
      BuildContext context, AdventureController controller) {
    return Container(
      key: const ValueKey('ch2_complete'),
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
                  Icons.explore,
                  color: AppColorHelper.teal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The trail opens up.',
                      style: GoogleFonts.cinzel(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColorHelper.darkText,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Text(
                      'You have your own way of exploring.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColorHelper.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "An adventure is only half the story.",
            style: TextStyle(
              fontSize: 15,
              color: AppColorHelper.darkText,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "There's one more thing to discover.",
            style: TextStyle(
              fontSize: 14.5,
              color: AppColorHelper.subduedText,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
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
              onPressed: controller.onContinueChapter2,
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

