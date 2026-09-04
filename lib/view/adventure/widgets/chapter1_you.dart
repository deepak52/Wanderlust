import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/adventure_controller.dart';
import '../../../helper/core/theme/color_helper.dart';
import '../../../model/adventure_state_model.dart';
import 'choice_card.dart';

class Chapter1You extends StatelessWidget {
  const Chapter1You({super.key});

  @override
  Widget build(BuildContext context) {
    final AdventureController controller = Get.find<AdventureController>();

    return Obx(() {
      final isCompleted =
          controller.rxChapter.value == AdventureChapter.chapter1Complete;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: isCompleted
            ? _buildCompletionState(context, controller)
            : _buildQuestionState(context, controller),
      );
    });
  }

  Widget _buildQuestionState(
      BuildContext context, AdventureController controller) {
    return Obx(() {
      final currentQ = controller.currentQuestion;
      final selectedOption = controller.rxSelectedCurrentOption.value;
      final isAdvancing = controller.rxIsAdvancing.value;

      final sectionTag =
          currentQ.index == 3 ? 'THE TRAIL' : 'FIRST IMPRESSIONS';

      String footnoteText;
      if (currentQ.index == 1) {
        footnoteText = 'Every journey begins with a first glance.';
      } else if (currentQ.index == 2) {
        footnoteText = 'Let the path guide us.';
      } else {
        footnoteText = 'Every step reveals a story.';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Step Tracker
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
                  '0${currentQ.index} / 09',
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

          // Title & Subtitle
          Text(
            currentQ.prompt,
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 17.5,
              fontWeight: FontWeight.w700,
              color: AppColorHelper.darkNavy,
              height: 1.35,
              letterSpacing: 0.4,
            ),
          ),
          if (currentQ.subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              currentQ.subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColorHelper.subduedText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Animated Question Choice Cards
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
              key: ValueKey<int>(currentQ.index),
              child: Column(
                children: [
                  ChoiceCard(
                    title: currentQ.optionA,
                    icon: currentQ.iconA,
                    assetIcon: currentQ.definitionA.assetPath,
                    isSelected: selectedOption == currentQ.optionA,
                    isEnabled: !isAdvancing,
                    onTap: () => controller.selectOption(currentQ.optionA),
                  ),
                  const SizedBox(height: 10),
                  ChoiceCard(
                    title: currentQ.optionB,
                    icon: currentQ.iconB,
                    assetIcon: currentQ.definitionB.assetPath,
                    isSelected: selectedOption == currentQ.optionB,
                    isEnabled: !isAdvancing,
                    onTap: () => controller.selectOption(currentQ.optionB),
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

  Widget _buildCompletionState(
      BuildContext context, AdventureController controller) {
    return Container(
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
                  'FIRST IMPRESSIONS DISCOVERED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColorHelper.teal,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'THE TRAIL AHEAD',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColorHelper.darkNavy,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You have set the atmosphere for your journey. Now let us see what waits along the trail.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColorHelper.subduedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
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
              onPressed: controller.onContinueChapter1,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CONTINUE ALONG THE TRAIL',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

