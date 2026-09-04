import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controller/user_list_controller.dart';
import '../../helper/adventure_assets.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/core/theme/color_helper.dart';

class UserListScreen extends AppBaseView<UserListController> {
  const UserListScreen({super.key});

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

            // 2. Main Content
            SafeArea(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColorHelper.teal,
                    ),
                  );
                }

                final users = controller.filteredUsers;

                return Column(
                  children: [
                    // Subtitle & Search Field
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Direct communication with travelers & companions.',
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

                    // User List / Empty State
                    Expanded(
                      child: users.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                final userData = user.data();
                                final email =
                                    userData['email']?.toString() ?? 'Unknown';
                                final name =
                                    userData['name']?.toString() ?? '';
                                final photoUrl =
                                    userData['photoUrl']?.toString() ?? '';

                                return _buildUserCard(
                                  user: user,
                                  email: email,
                                  name: name,
                                  photoUrl: photoUrl,
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
            'CONVERSATIONS',
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
          hintText: 'Search travelers by email...',
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

  Widget _buildUserCard({
    required dynamic user,
    required String email,
    required String name,
    required String photoUrl,
  }) {
    final emailInitial = email.isNotEmpty ? email[0].toUpperCase() : 'T';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: () => controller.onUserTap(user),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColorHelper.paleBlueSurface,
                    border: Border.all(
                      color: AppColorHelper.borderTeal,
                      width: 1.5,
                    ),
                    image: photoUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: photoUrl.isEmpty
                      ? Text(
                          emailInitial,
                          style: GoogleFonts.cinzel(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColorHelper.teal,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Name & Email Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : email,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColorHelper.darkText,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name.isNotEmpty ? email : 'Traveler Account',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorHelper.subduedText,
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing Chat Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColorHelper.paleBlueSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColorHelper.borderTeal,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: AppColorHelper.teal,
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
              Icons.people_outline,
              size: 48,
              color: AppColorHelper.teal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.searchQuery.value.isEmpty
                ? 'NO EXPEDITIONS YET'
                : 'NO MATCHING TRAVELERS',
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
            'When someone begins their journey,\nthey\'ll appear here.',
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
}
