import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controller/splash_controller.dart';
import '../../helper/app_message.dart';
import '../../helper/app_string.dart';
import '../../helper/core/base/app_base_view.dart';
import '../../helper/core/environment/env.dart';
import '../../helper/navigation.dart';
import '../../helper/route.dart';
import '../../model/lock_model.dart';
import '../../widgets/splash/wanderlust_wave_painter.dart';
import '../login/login_screen.dart';

/// Shared Single Source of Truth for Final Wanderlust Branding Logo Height
const double kFinalWanderlustLogoHeight = 84.0;

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
      backgroundColor: const Color(0xFF0F2E1E), // Deep Forest Green base
      body: AnimatedBuilder(
        animation: controller.mainAnimController,
        builder: (context, child) {
          final size = MediaQuery.of(context).size;
          final safeAreaTop = MediaQuery.of(context).padding.top;

          // Stage 4: Logo Move & Scale calculations
          final moveProgress = controller.logoMoveUp.value; // 0.0 -> 1.0
          final emergenceOpacity = controller.logoEmergenceFade.value; // 0.0 -> 1.0
          final emergenceScale = controller.logoEmergenceScale.value; // 0.80 -> 1.00

          // Shared Single Source of Truth for Top Logo Height (84.0px)
          const double finalLogoHeight = kFinalWanderlustLogoHeight;
          const double initialLogoHeight = 120.0; // Emerges in screen center

          // Calculate exact height interpolation from center emergence to final locked size (84.0px)
          final double currentLogoHeight = emergenceScale *
              (lerpDouble(initialLogoHeight, finalLogoHeight, moveProgress) ?? finalLogoHeight);

          // Top position: moves from screen center to locked top position (safeAreaTop + 16.0)
          final double targetTop = safeAreaTop + 16.0;
          final double startTop = (size.height - currentLogoHeight) / 2;
          final double currentTop = lerpDouble(startTop, targetTop, moveProgress) ?? targetTop;

          // Base Wave Header Position (below top logo header area)
          final double baseWaveY = targetTop + 64.0 + 40.0;

          // Use assets/images/wanderlust.png (clean transparent RGBA PNG)
          const logoAsset = 'assets/images/wanderlust.png';

          // Fade out animated logo as login content fades in to avoid double logo
          final animatedLogoOpacity =
              emergenceOpacity * (1.0 - controller.loginContentFade.value);

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1️⃣ STAGE 1: Full-Screen Landscape Background (splashBg4.png)
              Positioned.fill(
                child: FadeTransition(
                  opacity: controller.bgFade,
                  child: Image.asset(
                    'assets/images/splashBg4.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2️⃣ STAGE 4: Organic Wave Transition (WanderlustWavePainter)
              Positioned.fill(
                child: CustomPaint(
                  painter: WanderlustWavePainter(
                    progress: controller.waveProgress.value,
                    color: const Color(0xFF0F2E1E),
                    baseWaveY: baseWaveY,
                  ),
                ),
              ),

              // 3️⃣ STAGE 5 & 6: Login Screen Content Reveal
              if (controller.loginContentFade.value > 0.01)
                Positioned.fill(
                  child: Opacity(
                    opacity: controller.loginContentFade.value,
                    child: const LoginScreen(),
                  ),
                ),

              // 4️⃣ STAGE 2, 3, 4: Emerging & Moving Wanderlust Logo (Single Source of Truth: 84.0px height)
              if (animatedLogoOpacity > 0.01)
                Positioned(
                  top: currentTop,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: animatedLogoOpacity,
                      child: SizedBox(
                        height: currentLogoHeight,
                        child: Image.asset(
                          logoAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
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
