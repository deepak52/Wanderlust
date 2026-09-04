import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/admin_home_controller.dart';
import '../../helper/adventure_assets.dart';
import '../../helper/core/theme/color_helper.dart';

class AdminHomeScreen extends GetView<AdminHomeController> {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColorHelper.softBackground,
        appBar: _buildAdminAppBar(context),
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

            // 2. Admin Dashboard Content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Overview Summary Banner
                    _buildOverviewBanner(),
                    const SizedBox(height: 20),

                    // Key Metric Cards Row
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: 'ADVENTURES',
                              icon: Icons.explore_outlined,
                              countText:
                                  '${controller.adventuresCount.value} COMPLETED',
                              status: 'VIEW',
                              accentColor: AppColorHelper.teal,
                              onTap: controller.onViewResponses,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: 'TRAVELERS',
                              icon: Icons.forum_outlined,
                              countText:
                                  '${controller.travelersCount.value} REGISTERED',
                              status: 'CHAT',
                              accentColor: AppColorHelper.deepSkyBlue,
                              onTap: controller.onViewUserList,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Title
                    const Text(
                      'EXPEDITION MANAGEMENT',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColorHelper.teal,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Action Card 1: Adventure Responses
                    _buildNavigationCard(
                      title: 'Adventure & Tour Responses',
                      subtitle:
                          'Review choices, answers, and destination preferences',
                      icon: Icons.fact_check_outlined,
                      badgeText: 'VIEW',
                      badgeColor: AppColorHelper.teal,
                      onTap: controller.onViewResponses,
                    ),
                    const SizedBox(height: 14),

                    // Action Card 2: User Conversations
                    _buildNavigationCard(
                      title: 'User Conversations',
                      subtitle:
                          'Direct chat with companions, travelers & guests',
                      icon: Icons.chat_bubble_outline_rounded,
                      badgeText: 'CHAT',
                      badgeColor: AppColorHelper.deepSkyBlue,
                      onTap: controller.onViewUserList,
                    ),
                    const SizedBox(height: 24),

                    // Console Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColorHelper.paleBlueSurface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColorHelper.borderTeal,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 20,
                            color: AppColorHelper.teal,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Secure Wanderlust Admin Portal. All responses and messages are synced in real-time.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColorHelper.darkText,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAdminAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColorHelper.cardSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColorHelper.borderTeal,
          height: 1,
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
            'ADVENTURE CONSOLE',
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

  Widget _buildOverviewBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColorHelper.paleBlueSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColorHelper.borderTeal,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              size: 28,
              color: AppColorHelper.teal,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Command Center',
                  style: GoogleFonts.cinzel(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColorHelper.darkText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage invitations, tour responses and live conversations.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColorHelper.subduedText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required IconData icon,
    required String status,
    required String countText,
    required Color accentColor,
    VoidCallback? onTap,
  }) {
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, size: 20, color: accentColor),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  countText,
                  style: GoogleFonts.cinzel(
                    textStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColorHelper.subduedText,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
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
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColorHelper.paleBlueSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColorHelper.borderTeal,
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, size: 24, color: badgeColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColorHelper.darkText,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColorHelper.subduedText,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColorHelper.teal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
