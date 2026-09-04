import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controller/splash_controller.dart';
import '../../helper/app_message.dart';
import '../../helper/app_string.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/core/environment/env.dart';
import '../../helper/navigation.dart';
import '../../helper/route.dart';
import '../../model/lock_model.dart';
import 'package:wanderlust/widgets/splash/golden_light_path_painter.dart';
import 'package:wanderlust/widgets/splash/wanderlust_golden_logo.dart';
import '../login/login_screen.dart';

class SplashScreen extends AppBaseView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget buildView() {
    // Trigger auth check and navigation handling in background
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final targetRoute = await controller.checkAuthAndNavigate();
      appLog('Splash navigation target: $targetRoute');
      if (controller.rxUpdateRequired.value) {
        _openAppUpdateDialog();
      } else if (targetRoute != loginPageRoute) {
        // If user is already authenticated or needs lock screen, navigate directly after hold
        final navArgs = targetRoute == lockPageRoute
            ? LockArguments(returnRoute: controller.rxPostLockRoute.value)
            : {tasksDataKey: controller.rxTasksResponse};
        navigateToAndRemoveAll(targetRoute, arguments: navArgs);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF041014),
      body: AnimatedBuilder(
        animation: controller.mainAnimController,
        builder: (context, child) {
          final size = MediaQuery.of(context).size;
          final safeAreaTop = MediaQuery.of(context).padding.top;

          // Dark teal login panel begins at 25% from top, covering 75% of screen height
          final double panelTopY = size.height * 0.25;
          const double finalNameH = 72.0;
          final double finalNameTop = (safeAreaTop +
                  (panelTopY - safeAreaTop - finalNameH) / 2)
              .clamp(safeAreaTop + 2.0, panelTopY - 78.0);

          // Center splash initial layout (Stages 2 & 3)
          const double initialNameH = 92.0;
          const double initialEmblemH = 125.0;
          const double initialSpacing = 10.0;
          final double initialTotalH = initialEmblemH + initialSpacing + initialNameH;
          final double centerMidY = size.height * 0.40;
          final double initialNameTop =
              (centerMidY - initialTotalH / 2) + initialEmblemH + initialSpacing;

          // Pure, smooth, continuous trajectory of Wanderlust Name:
          final double currentNameTop =
              lerpDouble(initialNameTop, finalNameTop, controller.logoMoveUp.value) ??
                  initialNameTop;
          final double currentNameH =
              lerpDouble(initialNameH, finalNameH, controller.logoScaleDown.value) ??
                  finalNameH;

          // Emblem sits naturally above the name and fades out during ascent
          final double currentEmblemH =
              lerpDouble(initialEmblemH, 70.0, controller.logoScaleDown.value) ?? 70.0;
          final double currentSpacing =
              lerpDouble(initialSpacing, 6.0, controller.logoScaleDown.value) ?? 6.0;
          final double currentEmblemTop = currentNameTop - currentEmblemH - currentSpacing;
          final double currentEmblemOpacity =
              (1.0 - controller.logoMoveUp.value).clamp(0.0, 1.0);

          // Tagline combined opacity (fades in at Stage 3, fades out at Stage 5)
          final double taglineOpacity = (controller.taglineFadeIn.value *
                  controller.taglineFadeOut.value)
              .clamp(0.0, 1.0);
          final double currentTaglineTop = currentNameTop + currentNameH + 16.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1️⃣ STAGE 1: Deep Dark Nocturnal Background (assets/images/splashBg4.png)
              Positioned.fill(
                child: Opacity(
                  opacity: controller.bgDarkFade.value.clamp(0.0, 1.0),
                  child: Image.asset(
                    'assets/images/splashBg4.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2️⃣ STAGE 4 & 5: Landscape Emergence (assets/images/loginbg.png)
              if (controller.landscapeFade.value > 0.005)
                Positioned.fill(
                  child: Opacity(
                    opacity: controller.landscapeFade.value.clamp(0.0, 1.0),
                    child: Image.asset(
                      'assets/images/loginbg.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),

              // 3️⃣ STAGE 4 & 5: Glowing Golden Light Path
              if (controller.lightPathProgress.value > 0.005)
                Positioned.fill(
                  child: CustomPaint(
                    painter: GoldenLightPathPainter(
                      progress: controller.lightPathProgress.value,
                      glow: controller.lightPathGlow.value,
                    ),
                  ),
                ),

              // 4️⃣ STAGE 6: Golden Compass Settle Marker at Bottom
              if (controller.compassFade.value > 0.005)
                Positioned(
                  bottom: size.height * 0.06,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: (controller.compassFade.value *
                            (1.0 - controller.loginContentSlide.value))
                        .clamp(0.0, 1.0),
                    child: Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF3C65B)
                                  .withValues(alpha: 0.6),
                              blurRadius: 18,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/invitation/landmarks/start_compass.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

              // 5️⃣ STAGE 7: Login Card Slides Up from Bottom (Occupies only panelTopY to bottom!)
              if (controller.loginContentSlide.value > 0.005)
                Positioned(
                  top: panelTopY,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      (1.0 - controller.loginContentSlide.value) *
                          (size.height - panelTopY),
                    ),
                    child: Opacity(
                      opacity:
                          controller.loginContentFade.value.clamp(0.0, 1.0),
                      child: const LoginCard(),
                    ),
                  ),
                ),

              // 6️⃣ STAGE 2, 3, 5, 6, 7: Dynamic Wanderlust Logo & Tagline (Smooth Decoupled Motion)
              if (controller.logoEmergenceFade.value > 0.005) ...[
                // A) Top Emblem (wanderlustlogoUp.png): Smoothly ascends and fades away
                if (currentEmblemOpacity > 0.005)
                  Positioned(
                    top: currentEmblemTop,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Opacity(
                        opacity: (controller.logoEmergenceFade.value *
                                currentEmblemOpacity)
                            .clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: controller.logoEmergenceScale.value,
                          child: WanderlustEmblem(
                            height: currentEmblemH,
                            color: const Color(0xFFFFD54F),
                          ),
                        ),
                      ),
                    ),
                  ),

                // B) Wanderlust Name (wanderlust.png): Continuous smooth glide into final 25% position
                Positioned(
                  top: currentNameTop,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity:
                          controller.logoEmergenceFade.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: controller.logoEmergenceScale.value,
                        child: WanderlustName(
                          height: currentNameH,
                          color: const Color(0xFFFFF1C2),
                        ),
                      ),
                    ),
                  ),
                ),

                // C) Stage 3 Tagline: "Every journey starts within."
                if (taglineOpacity > 0.005)
                  Positioned(
                    top: currentTaglineTop,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Opacity(
                        opacity: taglineOpacity,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            (1.0 - controller.taglineFadeIn.value) * 8.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.park_rounded,
                                size: 15,
                                color: Color(0xFFFFD54F),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Every journey starts within.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 16.5,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFFF1C2),
                                  letterSpacing: 0.4,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _openAppUpdateDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Widget okButton = TextButton(
          child: const Text('OK'),
          onPressed: () {
            if (AppEnvironment.isAndroid()) {
              SystemNavigator.pop();
            } else if (AppEnvironment.isIos()) {
              exit(0);
            }
          },
        );

        return AlertDialog(
          title: const Text('App Update Required'),
          content: const Text(
            'A new version of Wanderlust is available. Please update to continue using the app.',
          ),
          actions: [
            okButton,
          ],
        );
      },
    );
  }
}
