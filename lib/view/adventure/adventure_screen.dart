import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/adventure_controller.dart';
import '../../helper/core/theme/color_helper.dart';
import '../../model/adventure_state_model.dart';
import 'widgets/adventure_intro.dart';
import 'widgets/adventure_map.dart';
import 'widgets/chapter1_you.dart';
import 'widgets/chapter2_somewhere.dart';
import 'widgets/chapter3_us.dart';
import 'widgets/reveal_invitation.dart';

class AdventureScreen extends GetView<AdventureController> {
  const AdventureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorHelper.softBackground,
      body: Obx(() {
        final chapter = controller.rxChapter.value;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: chapter == AdventureChapter.intro
              ? AdventureIntro(
                  key: const ValueKey('intro_view'),
                  onStart: controller.startAdventure,
                )
              : _buildAdventureGameplay(context),
        );
      }),
    );
  }

  Widget _buildAdventureGameplay(BuildContext context) {
    return Obx(() {
      final bool isRevealing = controller.isRevealing;

      return Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base Gameplay Screen (Expands out of card into full-screen landscape)
          AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
            color: isRevealing
                ? const Color(0xFF071C24)
                : AppColorHelper.softBackground,
            child: SafeArea(
              key: const ValueKey('gameplay_view'),
              bottom: !isRevealing,
              top: !isRevealing,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOutCubic,
                padding: isRevealing
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Navigation & Branding Bar (Fades/collapses during reveal)
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 600),
                      crossFadeState: isRevealing
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: _buildTopBar(context),
                      secondChild: const SizedBox.shrink(),
                    ),
                    if (!isRevealing) const SizedBox(height: 12),

                    // Dynamic Adventure Map (Expands to 100% full screen)
                    Expanded(
                      flex: isRevealing ? 1 : 11,
                      child: AdventureMap(isRevealing: isRevealing),
                    ),
                    if (!isRevealing) const SizedBox(height: 16),

                    // Chapter Interactive Choices (Fades/collapses during reveal)
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 600),
                      crossFadeState: isRevealing
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.44,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: _buildChapterChoices(),
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Cinematic Reveal Overlay (Cumulative story text, YOU climax, glowing compass & frosted invitation panel)
          if (isRevealing)
            const Positioned.fill(
              child:
                  RevealInvitation(key: ValueKey('reveal_cinematic_overlay')),
            ),
        ],
      );
    });
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColorHelper.cardSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColorHelper.borderTeal,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColorHelper.darkNavy.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 15,
              color: AppColorHelper.darkTeal,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Wanderlust',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColorHelper.darkNavy,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 1),
            const Text(
              'JOURNEYS & MEMORIES',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: AppColorHelper.subduedText,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColorHelper.cardSurface,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColorHelper.borderTeal,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorHelper.darkNavy.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.more_horiz_rounded,
            size: 20,
            color: AppColorHelper.darkTeal,
          ),
        ),
      ],
    );
  }

  Widget _buildChapterChoices() {
    return Obx(() {
      final ch = controller.rxChapter.value;
      if (ch == AdventureChapter.chapter1 ||
          ch == AdventureChapter.chapter1Complete) {
        return const Chapter1You();
      } else if (ch == AdventureChapter.chapter2Intro ||
          ch == AdventureChapter.chapter2 ||
          ch == AdventureChapter.chapter2Complete) {
        return const Chapter2Somewhere();
      } else if (ch == AdventureChapter.chapter3Intro ||
          ch == AdventureChapter.chapter3 ||
          ch == AdventureChapter.chapter3Complete ||
          ch == AdventureChapter.chapter3Placeholder) {
        return const Chapter3Us();
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
