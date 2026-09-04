import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../helper/app_message.dart';
import '../helper/app_string.dart';
import '../helper/core/base/app_base_controller.dart';
import '../helper/route.dart';
import '../model/task_model.dart';
import '../service/lock_service.dart';
import '../service/missed_message_service.dart';
import '../helper/firebase_messaging_service.dart';
import '../helper/single_app.dart';

class SplashController extends AppBaseController
    with GetSingleTickerProviderStateMixin {
  var rxUpdateRequired = false.obs;

  // Master Animation Controller for 7-Stage Wanderlust Sequence
  late AnimationController mainAnimController;
  late Animation<double> bgDarkFade;
  late Animation<double> logoEmergenceFade;
  late Animation<double> logoEmergenceScale;
  late Animation<double> taglineFadeIn;
  late Animation<double> taglineFadeOut;
  late Animation<double> landscapeFade;
  late Animation<double> lightPathProgress;
  late Animation<double> lightPathGlow;
  late Animation<double> logoMoveUp;
  late Animation<double> logoScaleDown;
  late Animation<double> compassFade;
  late Animation<double> loginContentSlide;
  late Animation<double> loginContentFade;

  // tasks
  RxList<TaskResponse> rxTasksResponse = <TaskResponse>[].obs;

  // Post-lock return route (admin vs user)
  RxString rxPostLockRoute = welcomePageRoute.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    initMasterAnimation();
    mainAnimController.forward();

    // Initialize messaging services
    await _initializeMessagingServices();
  }

  void initMasterAnimation() {
    mainAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7500),
    );

    // 1. APP LAUNCH: Dark background fade in (0.0s - 0.8s, 0.00 - 0.11)
    bgDarkFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.00, 0.11, curve: Curves.easeIn),
      ),
    );

    // 2. LOGO FADE IN: Golden logo in center (0.8s - 1.8s, 0.11 - 0.24)
    logoEmergenceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.11, 0.24, curve: Curves.easeOut),
      ),
    );

    logoEmergenceScale = Tween<double>(begin: 0.88, end: 1.00).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.11, 0.24, curve: Curves.easeOutCubic),
      ),
    );

    // 3. TAGLINE APPEARS: "Every journey starts within." (1.8s - 2.8s, 0.24 - 0.37)
    taglineFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.24, 0.37, curve: Curves.easeOut),
      ),
    );

    taglineFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.53, 0.68, curve: Curves.easeIn),
      ),
    );

    // 4. LIGHT PATH FORMS & LANDSCAPE EMERGES: (2.8s - 4.0s, 0.37 - 0.53)
    landscapeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.36, 0.65, curve: Curves.easeInOut),
      ),
    );

    lightPathProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.37, 0.60, curve: Curves.easeInOutSine),
      ),
    );

    // 5. JOURNEY AWAKENS: Path glows, logo ascends (4.0s - 6.0s, 0.53 - 0.80)
    lightPathGlow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.50, 0.75, curve: Curves.easeInOut),
      ),
    );

    logoMoveUp = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.53, 0.80, curve: Curves.easeInOutCubic),
      ),
    );

    logoScaleDown = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.53, 0.80, curve: Curves.easeInOutCubic),
      ),
    );

    // 6. PREPARE TO BEGIN: Compass settles at bottom of path (6.0s - 7.0s, 0.80 - 0.93)
    compassFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.80, 0.93, curve: Curves.easeOut),
      ),
    );

    // 7. LOGIN SCREEN: Dark teal sheet slides up smoothly (7.0s+, 0.90 - 1.00)
    loginContentSlide = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.90, 1.00, curve: Curves.easeOutCubic),
      ),
    );

    loginContentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.90, 1.00, curve: Curves.easeIn),
      ),
    );
  }

  /// Initialize messaging infrastructure (FCM, missed messages, sound player, etc.)
  Future<void> _initializeMessagingServices() async {
    try {
      final messagingService = Get.find<FirebaseMessagingService>();
      await messagingService.initialize();

      final missedMessageService = Get.find<MissedMessageService>();
      missedMessageService.startListening();
    } catch (e) {
      misErrorMessage('❌ Failed to initialize messaging services: $e');
    }
  }

  /// Checks Firebase auth state and user role, returns route to navigate to.
  Future<String> checkAuthAndNavigate() async {
    // Hold until Stage 6 (6.2s) before navigating if user is already authenticated
    await Future.delayed(const Duration(milliseconds: 6200));

    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        var preference = myApplication.preferenceHelper;
        if (preference != null) {
          final rememberMe = preference.getBool(rememberMeKey);
          final userId = preference.getString(userIdKey);
          final token = preference.getString(accessTokenKey);

          if (rememberMe && userId != "-1" && token.isNotEmpty) {
            await _clearStalePrefs();
          }
        }
        return loginPageRoute;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final userData = userDoc.data() ?? {};
      bool isAdmin = false;
      final possibleAdminFields = [
        'isAdmin',
        'IsAdmin',
        'isadmin',
        'ISADMIN',
        'admin',
        'Admin',
        'role',
        'Role',
        'userType',
      ];
      for (final field in possibleAdminFields) {
        final value = userData[field];
        if (value == true ||
            value == 'true' ||
            value == 'admin' ||
            value == 'ADMIN') {
          isAdmin = true;
          break;
        }
      }

      await _saveFcmToken(firebaseUser.uid);

      if (isAdmin) {
        return _getLockOrAdminRoute();
      }

      return _getLockOrWelcomeRoute();
    } catch (e) {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        return _getLockOrWelcomeRoute();
      }
      return loginPageRoute;
    }
  }

  String _getLockOrWelcomeRoute() {
    rxPostLockRoute.value = welcomePageRoute;
    try {
      final lockService = Get.isRegistered<LockService>()
          ? Get.find<LockService>()
          : Get.put(LockService());
      if (lockService.isLockEnabled()) {
        return lockPageRoute;
      }
    } catch (e) {
      developer.log('Error checking lock status: $e');
    }
    return welcomePageRoute;
  }

  String _getLockOrAdminRoute() {
    rxPostLockRoute.value = adminHomePageRoute;
    try {
      final lockService = Get.isRegistered<LockService>()
          ? Get.find<LockService>()
          : Get.put(LockService());
      if (lockService.isLockEnabled()) {
        return lockPageRoute;
      }
    } catch (e) {
      developer.log('Error checking lock status: $e');
    }
    return adminHomePageRoute;
  }

  Future<void> _clearStalePrefs() async {
    final preference = myApplication.preferenceHelper;
    if (preference != null) {
      await preference.remove(accessTokenKey);
      await preference.remove(loginPasswordKey);
      await preference.remove(userIdKey);
      await preference.remove(emailKey);
      await preference.setBool(rememberMeKey, false);
    }
  }

  Future<void> _saveFcmToken(String userId) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'fcmToken': fcmToken},
        );
      }
    } catch (e) {
      developer.log('Failed to save FCM token: $e');
    }
  }

  @override
  void onClose() {
    mainAnimController.dispose();
    super.onClose();
  }
}
