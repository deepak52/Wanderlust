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

  // Master Animation Controller for 6-Stage Wanderlust Sequence
  late AnimationController mainAnimController;
  late Animation<double> bgFade;
  late Animation<double> logoEmergenceFade;
  late Animation<double> logoEmergenceScale;
  late Animation<double> logoMoveUp;
  late Animation<double> logoScaleDown;
  late Animation<double> waveProgress;
  late Animation<double> loginContentFade;
  late Animation<double> loginContentSlide;

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
      duration: const Duration(milliseconds: 5500),
    );

    // Stage 1: Background Fade In (0.00 - 0.20)
    bgFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.00, 0.20, curve: Curves.easeIn),
      ),
    );

    // Stage 2: Logo Emerges (0.18 - 0.42)
    logoEmergenceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.18, 0.42, curve: Curves.easeOut),
      ),
    );

    logoEmergenceScale = Tween<double>(begin: 0.80, end: 1.00).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.18, 0.42, curve: Curves.easeOutCubic),
      ),
    );

    // Stage 4: Logo Moves Up & Scales Down (0.45 - 0.78)
    logoMoveUp = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.45, 0.78, curve: Curves.easeInOutCubic),
      ),
    );

    logoScaleDown = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.45, 0.78, curve: Curves.easeInOutCubic),
      ),
    );

    // Stage 4: Organic Wave Transition (0.50 - 0.88)
    waveProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.50, 0.88, curve: Curves.easeOutCubic),
      ),
    );

    // Stage 5: Login Content Staggered Reveal (0.75 - 0.98)
    loginContentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.75, 0.98, curve: Curves.easeOut),
      ),
    );

    loginContentSlide = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: mainAnimController,
        curve: const Interval(0.75, 0.98, curve: Curves.easeOutCubic),
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
    // Hold briefly until Stage 3 logo display before deciding navigation
    await Future.delayed(const Duration(milliseconds: 3800));

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

      if (!userDoc.exists) {
        return _getLockOrWelcomeRoute();
      }

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
