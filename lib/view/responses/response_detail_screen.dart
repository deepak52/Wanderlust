import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../controller/response_detail_controller.dart';
import '../../helper/adventure_assets.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/core/theme/color_helper.dart';
import '../adventure/widgets/adventure_map.dart';

class ResponseDetailScreen extends AppBaseView<ResponseDetailController> {
  const ResponseDetailScreen({super.key});

  @override
  Widget buildView() {
    final response = controller.response;
    final emailInitial = response.email.isNotEmpty
        ? response.email.substring(0, 1).toUpperCase()
        : 'T';
    final String timeString =
        DateFormat('MMM d, yyyy • h:mm a').format(response.timestamp);

    return Scaffold(
      backgroundColor: AppColorHelper.softBackground,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // 1. Subtle Map Texture Layer
          Positioned.fill(
            child: Image.asset(
              AdventureAssets.revealMapTexture,
              fit: BoxFit.cover,
              color: AppColorHelper.softBackground.withValues(alpha: 0.9),
              colorBlendMode: BlendMode.softLight,
            ),
          ),

          // 2. Scrollable Body
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Traveler Profile Card
                  _buildTravelerHeaderCard(
                    emailInitial: emailInitial,
                    email: response.email,
                    timeString: timeString,
                    isAdventure: response.adventureCompleted ||
                        response.invitationResponse != null,
                  ),
                  const SizedBox(height: 20),

                  // SECTION 1: THE EXPEDITION MAP
                  _buildSectionHeader('SECTION 1', 'THE EXPEDITION MAP'),
                  const SizedBox(height: 10),
                  _buildMapSection(response),
                  const SizedBox(height: 24),

                  // SECTION 2: FINAL INVITATION DECISION
                  if (response.invitationResponse != null &&
                      response.invitationResponse!.isNotEmpty) ...[
                    _buildSectionHeader('SECTION 2', 'FINAL INVITATION DECISION'),
                    const SizedBox(height: 10),
                    _buildInvitationDecisionCard(response.invitationResponse!),
                    const SizedBox(height: 24),
                  ],

                  // SECTION 3: EXPEDITION ANSWERS & CHOICES
                  _buildSectionHeader(
                    response.invitationResponse != null ? 'SECTION 3' : 'SECTION 2',
                    'EXPEDITION ANSWERS & CHOICES',
                  ),
                  const SizedBox(height: 10),
                  _buildAnswersBreakdown(response),
                  const SizedBox(height: 32),

                  // Action Button: OPEN CONVERSATION
                  _buildOpenConversationButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColorHelper.cardSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColorHelper.borderTeal,
          height: 1,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 14.0),
        child: Center(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColorHelper.paleBlueSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColorHelper.borderTeal,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: AppColorHelper.darkTeal,
              ),
            ),
          ),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'WANDERLUST',
            style: GoogleFonts.cinzel(
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColorHelper.teal,
                letterSpacing: 2.2,
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'EXPEDITION DETAIL',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColorHelper.subduedText,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String tag, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColorHelper.paleBlueSurface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColorHelper.borderTeal,
              width: 1,
            ),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColorHelper.teal,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cinzel(
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColorHelper.darkText,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelerHeaderCard({
    required String emailInitial,
    required String email,
    required String timeString,
    required bool isAdventure,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColorHelper.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColorHelper.borderTeal,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorHelper.darkNavy.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColorHelper.paleBlueSurface,
              border: Border.all(
                color: AppColorHelper.borderTeal,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              emailInitial,
              style: GoogleFonts.cinzel(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorHelper.teal,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColorHelper.darkText,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Submitted $timeString',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColorHelper.subduedText,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColorHelper.paleBlueSurface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColorHelper.borderTeal,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isAdventure ? 'EXPEDITION COMPLETE' : 'TOUR RESPONSES',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: AppColorHelper.teal,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(dynamic response) {
    if (response.mapNodes.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: AppColorHelper.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColorHelper.borderTeal,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.map_outlined,
              size: 40,
              color: AppColorHelper.teal,
            ),
            const SizedBox(height: 12),
            const Text(
              'Expedition map unavailable for this response.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColorHelper.darkText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'This response was submitted before map persistence was enabled.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColorHelper.subduedText,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
      child: AdventureMap(
        readOnly: true,
        customNodes: response.mapNodes,
        customSegments: response.mapSegments,
      ),
    );
  }

  Widget _buildInvitationDecisionCard(String invitationResponse) {
    final isYes = invitationResponse == "YES, LET'S GO";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColorHelper.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isYes
              ? AppColorHelper.teal
              : AppColorHelper.warmGold,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isYes ? AppColorHelper.teal : AppColorHelper.warmGold)
                .withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColorHelper.paleBlueSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isYes ? AppColorHelper.teal : AppColorHelper.warmGold,
                width: 1,
              ),
            ),
            child: Icon(
              isYes ? Icons.explore : Icons.chat_bubble_outline_rounded,
              color: isYes ? AppColorHelper.teal : AppColorHelper.warmGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INVITATION RESPONSE',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColorHelper.subduedText,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invitationResponse,
                  style: GoogleFonts.cinzel(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isYes
                          ? AppColorHelper.teal
                          : AppColorHelper.warmGold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswersBreakdown(dynamic response) {
    final Map<String, String> choices = response.adventureChoices;

    if (choices.isNotEmpty) {
      return Column(
        children: [
          // Part 1: FIRST IMPRESSIONS
          _buildChapterCard(
            chapterNumber: '01',
            chapterTitle: 'FIRST IMPRESSIONS (INSTINCT)',
            items: [
              _ChoiceItem('01 — Atmosphere', choices['q1']),
              _ChoiceItem('02 — Travel Style', choices['q2']),
              _ChoiceItem('03 — Memory Focus', choices['q3']),
            ],
          ),
          const SizedBox(height: 12),

          // Part 2: THE TRAIL
          _buildChapterCard(
            chapterNumber: '02',
            chapterTitle: 'THE TRAIL (REACTIVE WORLD)',
            items: [
              _ChoiceItem('01 — The Horizon Split', choices['chapter2_q1']),
              _ChoiceItem('02 — The Ridge Path', choices['chapter2_q2']),
              _ChoiceItem('03 — The Crossing', choices['chapter2_q3']),
            ],
          ),
          const SizedBox(height: 12),

          // Part 3: SHARED MOMENTS
          _buildChapterCard(
            chapterNumber: '03',
            chapterTitle: 'SHARED MOMENTS (CONNECTION)',
            items: [
              _ChoiceItem('01 — The First Morning', choices['chapter3_q1']),
              _ChoiceItem('02 — Come Look', choices['chapter3_q2']),
              _ChoiceItem('03 — What You Remember', choices['chapter3_q3']),
            ],
          ),
        ],
      );
    }

    // Fallback if legacy tour responses
    final List<String> answers = response.answers;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorHelper.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColorHelper.borderTeal,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: answers.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key + 1}. ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColorHelper.teal,
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      color: AppColorHelper.darkText,
                      fontSize: 13.5,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChapterCard({
    required String chapterNumber,
    required String chapterTitle,
    required List<_ChoiceItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorHelper.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColorHelper.borderTeal,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorHelper.darkNavy.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CHAPTER $chapterNumber',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColorHelper.teal,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                chapterTitle,
                style: GoogleFonts.cinzel(
                  textStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColorHelper.darkText,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColorHelper.borderTeal, height: 18),
          ...items.where((i) => i.value != null && i.value!.isNotEmpty).map((i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    i.label,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColorHelper.subduedText,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColorHelper.paleBlueSurface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColorHelper.borderTeal,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      i.value!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColorHelper.darkTeal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOpenConversationButton() {
    return GestureDetector(
      onTap: controller.onOpenConversation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColorHelper.teal,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColorHelper.teal.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'OPEN CONVERSATION',
              style: GoogleFonts.cinzel(
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceItem {
  final String label;
  final String? value;
  _ChoiceItem(this.label, this.value);
}

