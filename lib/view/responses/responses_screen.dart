import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../controller/responses_controller.dart';
import '../../helper/adventure_assets.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/core/theme/color_helper.dart';
import '../../model/response_model.dart';

class ResponsesScreen extends AppBaseView<ResponsesController> {
  const ResponsesScreen({super.key});

  @override
  Widget buildView() => Scaffold(
        backgroundColor: AppColorHelper.softBackground,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            // 1. Subtle Map Texture
            Positioned.fill(
              child: Image.asset(
                AdventureAssets.revealMapTexture,
                fit: BoxFit.cover,
                color: AppColorHelper.softBackground.withValues(alpha: 0.9),
                colorBlendMode: BlendMode.softLight,
              ),
            ),

            // 2. Content
            SafeArea(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColorHelper.teal,
                    ),
                  );
                }

                final responses = controller.filteredResponses;

                return Column(
                  children: [
                    // Subtitle bar & Search Field
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'See how each expedition unfolded.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColorHelper.subduedText,
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSearchField(),
                        ],
                      ),
                    ),

                    // Responses list or empty state
                    Expanded(
                      child: responses.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: responses.length,
                              itemBuilder: (context, index) {
                                return _buildResponseCard(
                                  context,
                                  responses[index],
                                );
                              },
                            ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      );

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
            'ADVENTURE RESPONSES',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColorHelper.subduedText,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          tooltip: 'Logout',
          onPressed: controller.onLogout,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
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
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.onSearchChanged,
        cursorColor: AppColorHelper.teal,
        style: const TextStyle(
          color: AppColorHelper.darkText,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search by traveler email...',
          hintStyle: const TextStyle(
            color: AppColorHelper.hintText,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColorHelper.teal,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildResponseCard(BuildContext context, ResponseModel response) {
    final emailInitial = response.email.isNotEmpty
        ? response.email.substring(0, 1).toUpperCase()
        : 'T';

    final isAdventure =
        response.adventureCompleted || response.invitationResponse != null;

    final String timeString =
        DateFormat('MMM d, h:mm a').format(response.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColorHelper.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColorHelper.borderTeal,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorHelper.darkNavy.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => controller.onResponseTap(response),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row: Avatar, Email, Delete
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColorHelper.teal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            response.email,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColorHelper.darkText,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Submitted $timeString',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColorHelper.subduedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      tooltip: 'Delete Response',
                      onPressed: () => _confirmDelete(context, response),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status & Invitation Pills Row
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorHelper.paleBlueSurface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColorHelper.borderTeal,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isAdventure
                            ? 'EXPEDITION COMPLETE'
                            : 'TOUR RESPONSES',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColorHelper.teal,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    // Invitation Pill (if present)
                    if (response.invitationResponse != null &&
                        response.invitationResponse!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColorHelper.softCream,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColorHelper.warmGold.withValues(alpha: 0.8),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          response.invitationResponse!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: AppColorHelper.darkNavy,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Footer Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColorHelper.paleBlueSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColorHelper.borderTeal,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 16,
                        color: AppColorHelper.teal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VIEW EXPEDITION',
                        style: GoogleFonts.cinzel(
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColorHelper.darkTeal,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColorHelper.teal,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColorHelper.paleBlueSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColorHelper.borderTeal,
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.explore_off_outlined,
              size: 48,
              color: AppColorHelper.teal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchQuery.value.isEmpty
                ? 'NO RESPONSES YET'
                : 'NO MATCHING RESPONSES',
            style: GoogleFonts.cinzel(
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColorHelper.darkText,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'When travelers submit their adventure choices,\nthey will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColorHelper.subduedText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ResponseModel response) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColorHelper.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColorHelper.borderTeal,
            width: 1.2,
          ),
        ),
        title: Text(
          'Delete Response?',
          style: GoogleFonts.cinzel(
            textStyle: const TextStyle(
              color: AppColorHelper.darkText,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${response.email}\'s expedition response? This cannot be undone.',
          style: const TextStyle(color: AppColorHelper.subduedText, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColorHelper.subduedText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      controller.deleteResponse(response);
    }
  }
}
