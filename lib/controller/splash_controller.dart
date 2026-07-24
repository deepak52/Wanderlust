import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../helper/app_message.dart';
import '../helper/app_string.dart';
import '../helper/core/base/app_base_controller.dart';
import '../helper/shared_pref.dart';
import '../helper/route.dart';
import '../model/task_model.dart';
import '../service/lock_service.dart';
import '../service/missed_message_service.dart';
import '../helper/firebase_messaging_service.dart';
import '../helper/single_app.dart';

class SplashController extends AppBaseController
    with GetSingleTickerProviderStateMixin {
  SharedPreferenceHelper? _preference;
  var rxUpdateRequired = false.obs;

  // animation
  late AnimationController _textController;
  late Animation<Offset> logoSlide;
  RxBool rxShowSecondImage = false.obs;

  late Animation<double> logoFade;

  // tasks
  RxList<TaskResponse> rxTasksResponse = <TaskResponse>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    initTextAnimation();
    _textController.forward();

    // Initialize messaging services
    await _initializeMessagingServices();

    // Hold the logo at center for ~1 second
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Initialize messaging infrastructure (FCM, missed messages, sound player, etc.)
  Future<void> _initializeMessagingServices() async {
    try {
      // Initialize Firebase Messaging (FCM + local notifications)
      final messagingService = Get.find<FirebaseMessagingService>();
      await messagingService.initialize();

      // Start missed message listener (connectivity monitoring)
      final missedMessageService = Get.find<MissedMessageService>();
      missedMessageService.startListening();

      appLog('📦 Messaging services initialized successfully');
    } catch (e) {
      misErrorMessage('❌ Failed to initialize messaging services: $e');
    }
  }

  /// Checks Firebase auth state and user role, returns route to navigate to.
  /// Returns:
  /// - loginPageRoute - if no user logged in
  /// - lockPageRoute - if user logged in and app lock is enabled
  /// - welcomePageRoute - if regular user logged in and lock disabled
  /// - adminHomePageRoute - if admin user logged in and lock disabled
  Future<String> checkAuthAndNavigate() async {
    // Ensure minimum splash duration
    await Future.delayed(const Duration(milliseconds: 2500));

    try {
      // Check current Firebase user (not just local prefs)
      final User? firebaseUser = FirebaseAuth.instance.currentUser;

      developer.log('=== SPLASH AUTH CHECK DEBUG ===');
      developer.log('Firebase User: ${firebaseUser?.uid ?? "null"}');
      developer.log('Firebase User Email: ${firebaseUser?.email ?? "null"}');

      if (firebaseUser == null) {
        // No Firebase user - check remember me from local prefs as fallback
        var preference = myApplication.preferenceHelper;
        if (preference != null) {
          final rememberMe = preference.getBool(rememberMeKey);
          final userId = preference.getString(userIdKey);
          final token = preference.getString(accessTokenKey);

          if (rememberMe && userId != "-1" && token.isNotEmpty) {
            // Has remember me credentials but no Firebase user
            // This could happen if token expired - force login
            await _clearStalePrefs();
          }
        }
        developer.log('No Firebase user -> returning loginPageRoute');
        return loginPageRoute;
      }

      // Firebase user exists - fetch role from Firestore
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(firebaseUser.uid)
              .get();

      developer.log('User doc exists: ${userDoc.exists}');
      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};
        developer.log('User doc data: $userData');
        developer.log('All fields: ${userData.keys.toList()}');
      }

      if (!userDoc.exists) {
        // User document doesn't exist - treat as regular user
        developer.log('No user doc -> returning _getLockOrWelcomeRoute()');
        return _getLockOrWelcomeRoute();
      }

      final userData = userDoc.data() ?? {};

      // Check for admin field with multiple possible names (case-insensitive)
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
        'UserType',
        'user_role',
        'userRole',
      ];
      for (final field in possibleAdminFields) {
        final value = userData[field];
        developer.log(
          'Checking field "$field": $value (type: ${value.runtimeType})',
        );
        if (value == true ||
            value == 'true' ||
            value == 'admin' ||
            value == 'ADMIN') {
          isAdmin = true;
          developer.log('Found admin=true via field: $field');
          break;
        }
      }

      developer.log('Computed isAdmin: $isAdmin');

      // Save FCM token for this user
      await _saveFcmToken(firebaseUser.uid);

      // If admin, check lock before going to admin home
      if (isAdmin) {
        developer.log('isAdmin=true -> returning _getLockOrAdminRoute()');
        return _getLockOrAdminRoute();
      }

      // Regular user - check lock before going to welcome
      developer.log('isAdmin=false -> returning _getLockOrWelcomeRoute()');
      return _getLockOrWelcomeRoute();
    } catch (e) {
      // On any error, fall back to login
      developer.log('Auth check error: $e');
      return loginPageRoute;
    }
  }

  /// Check if app lock is enabled and return appropriate route for regular user
  String _getLockOrWelcomeRoute() {
    final lockService = Get.find<LockService>();
    if (lockService.isLockEnabled()) {
      return lockPageRoute;
    }
    return welcomePageRoute;
  }

  /// Check if app lock is enabled and return appropriate route for admin
  String _getLockOrAdminRoute() {
    final lockService = Get.find<LockService>();
    if (lockService.isLockEnabled()) {
      return lockPageRoute;
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

  Future<void> resetPref() async {
    _preference?.remove(accessTokenKey);
    _preference?.remove(loginPasswordKey);
  }

  void initTextAnimation() {
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    logoSlide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0, 1.0),
          end: const Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70,
      ),
      TweenSequenceItem(tween: ConstantTween(const Offset(0, 0)), weight: 10),
    ]).animate(_textController);

    logoFade = TweenSequence<double>([
      // stay invisible for a short moment
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 20),

      // smooth fade-in
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 80,
      ),
    ]).animate(_textController);
  }

  @override
  void onClose() {
    _textController.dispose();
    super.onClose();
  }
}
