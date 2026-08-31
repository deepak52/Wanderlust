// lock_controller.dart
// Lock Screen Controller - All business logic extracted from Wanderlust LockScreen
// Follows Agro-Prod patterns: extends AppBaseController, uses LockService for all auth access

import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/app_string.dart';
import '../helper/core/base/app_base_controller.dart';
import '../helper/route.dart';
import '../helper/single_app.dart';
import '../model/lock_model.dart';
import '../service/lock_service.dart';

class LockController extends AppBaseController with WidgetsBindingObserver {
  // ==================== DEPENDENCIES ====================
  final LockService _lockService = Get.find<LockService>();

  // ==================== REACTIVE STATE ====================

  /// Whether lock is enabled globally
  final RxBool lockEnabled = false.obs;

  /// Whether app is currently unlocked
  final RxBool unlocked = true.obs;

  /// Whether app backgrounding has marked the app as requiring unlock
  final RxBool requiresUnlock = false.obs;

  /// Guard to check if LockScreen is currently showing
  bool get isLockScreenShowing => Get.currentRoute == lockPageRoute;

  /// Whether biometric authentication is available
  final RxBool biometricAvailable = false.obs;

  /// Whether PIN is set
  final RxBool hasPin = false.obs;

  /// Current authentication state
  final RxBool isAuthenticating = false.obs;

  /// Error message for failed authentication
  final RxString errorMessage = ''.obs;

  /// PIN input state
  final RxString pinInput = ''.obs;
  final RxBool pinErrorVisible = false.obs;

  // ==================== COMPUTED PROPERTIES ====================

  /// Whether any authentication method is available
  bool get canAuthenticate => biometricAvailable.value || hasPin.value;

  // ==================== LIFECYCLE ====================

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeLock();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // ==================== INITIALIZATION ====================

  void _initializeLock() async {
    final config = _lockService.getLockConfig();
    lockEnabled.value = config.enabled;

    if (config.enabled) {
      unlocked.value = false;
      await _checkBiometricAvailability();
      hasPin.value = _lockService.hasPin();
    } else {
      unlocked.value = true;
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await _lockService.canCheckBiometrics();
    biometricAvailable.value = available;
  }

  // ==================== LIFECYCLE HANDLERS ====================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Dynamically query single source of truth for lock status
    final currentLockState = _lockService.isLockEnabled();
    lockEnabled.value = currentLockState;
    final isAuthenticated = FirebaseAuth.instance.currentUser != null;
    final currentRoute = Get.currentRoute;
    final currentArgs = Get.arguments;

    developer.log('[LOCK_STATE] Lifecycle: ${state.name}');

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      developer.log('[LOCK_STATE] Background check: enabled=$currentLockState');
      if (currentLockState && isAuthenticated) {
        if (currentRoute.isNotEmpty &&
            currentRoute != lockPageRoute &&
            currentRoute != splashPageRoute &&
            currentRoute != loginPageRoute &&
            currentRoute != registerPageRoute) {
          if (!requiresUnlock.value) {
            requiresUnlock.value = true;
            developer.log('[LOCK_STATE] Marking app as locked');
          }
        }
      } else {
        requiresUnlock.value = false;
      }
    } else if (state == AppLifecycleState.resumed) {
      developer.log('[LOCK_STATE] Resume check: enabled=$currentLockState');
      if (currentLockState && requiresUnlock.value && isAuthenticated) {
        if (!isLockScreenShowing) {
          developer.log('[LOCK_STATE] Showing lock screen');
          _lockApp();
          Get.toNamed(
            lockPageRoute,
            arguments: LockArguments(
              returnRoute: currentRoute,
              returnArgs: currentArgs is Map<String, dynamic> ? currentArgs : null,
            ),
          );
        }
      } else {
        requiresUnlock.value = false;
        developer.log('[LOCK_STATE] Lock screen NOT required');
      }
    }
  }

  // ==================== LOCK/UNLOCK LOGIC ====================

  /// Lock the app (require authentication on next resume)
  void _lockApp() {
    unlocked.value = false;
  }

  /// Unlock the app
  void _unlockApp() {
    unlocked.value = true;
    requiresUnlock.value = false;
    errorMessage.value = '';
    developer.log('''
APP_LOCK_DEBUG:
UNLOCK SUCCESS
requiresUnlock = false
restoring previous route
''');
  }

  /// Trigger authentication (public for UI to call)
  Future<void> authenticate() async {
    if (unlocked.value) return;

    isAuthenticating.value = true;
    errorMessage.value = '';

    try {
      // Try biometric first if available
      if (biometricAvailable.value) {
        final result = await _lockService.authenticateWithBiometrics();
        if (result.success) {
          _unlockApp();
          isAuthenticating.value = false;
          return;
        }
        errorMessage.value = result.error ?? 'Biometric authentication failed';
      }

      // Fall back to PIN if available
      if (hasPin.value) {
        // PIN entry will be handled by UI
        isAuthenticating.value = false;
        return;
      }

      // No auth method available
      errorMessage.value = 'No authentication method configured';
    } catch (e) {
      errorMessage.value = 'Authentication error: $e';
    } finally {
      isAuthenticating.value = false;
    }
  }

  /// Verify PIN entered by user
  Future<void> verifyPin(String pin) async {
    if (pin.length != 4) {
      _showPinError('Enter 4-digit PIN');
      return;
    }

    isAuthenticating.value = true;
    pinErrorVisible.value = false;

    final result = await _lockService.verifyPin(pin);
    if (result.success) {
      _unlockApp();
      pinInput.value = '';
    } else {
      _showPinError(result.error ?? 'Incorrect PIN');
      pinInput.value = '';
    }
    isAuthenticating.value = false;
  }

  // ==================== PUBLIC METHODS (UI Actions) ====================

  /// Add digit to PIN input
  void addPinDigit(String digit) {
    if (pinInput.value.length < 4) {
      pinInput.value += digit;
      if (pinInput.value.length == 4) {
        verifyPin(pinInput.value);
      }
    }
  }

  /// Remove last digit from PIN input
  void removePinDigit() {
    if (pinInput.value.isNotEmpty) {
      pinInput.value = pinInput.value.substring(0, pinInput.value.length - 1);
    }
  }

  /// Clear PIN input
  void clearPin() {
    pinInput.value = '';
    pinErrorVisible.value = false;
  }

  /// Show PIN error
  void _showPinError(String message) {
    errorMessage.value = message;
    pinErrorVisible.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      pinErrorVisible.value = false;
    });
  }

  /// Enable/disable lock (called from Settings / UI)
  Future<void> setLockEnabled(bool enabled) async {
    await _lockService.setLockEnabled(enabled);
    lockEnabled.value = enabled;

    if (enabled) {
      await _checkBiometricAvailability();
      hasPin.value = _lockService.hasPin();
    } else {
      unlocked.value = true;
      requiresUnlock.value = false;
    }
  }

  /// Set up PIN (called from Settings)
  Future<void> setPin(String pin) async {
    await _lockService.setPin(pin);
    hasPin.value = true;
  }

  /// Check if PIN is required (for Settings UI)
  bool get requiresPin => lockEnabled.value && !hasPin.value;

  /// Navigate back to appropriate screen after unlock
  Future<void> navigateAfterUnlock(LockArguments? args) async {
    String? targetRoute = args?.returnRoute;
    Map<String, dynamic>? targetArgs = args?.returnArgs;

    // Check if arguments were passed as Map in Get.arguments or LockArguments
    final rawArgs = Get.arguments;
    if (targetRoute == null && rawArgs is Map<String, dynamic>) {
      targetRoute = rawArgs['returnRoute'] as String?;
      targetArgs = rawArgs['returnArgs'] as Map<String, dynamic>?;
    } else if (targetRoute == null && rawArgs is LockArguments) {
      targetRoute = rawArgs.returnRoute;
      targetArgs = rawArgs.returnArgs;
    }

    developer.log('''
LOCK_NAV_DEBUG:
unlockSuccessful = true
routeAfterUnlock = ${targetRoute ?? 'POPPING_STACK'}
''');

    // Preferred Solution: If LockScreen was pushed on top of an existing route stack,
    // pop LockScreen to reveal the exact authenticated screen underneath.
    requiresUnlock.value = false;
    if (Get.currentRoute == lockPageRoute && Get.key.currentState?.canPop() == true) {
      Get.back();
      return;
    }

    // If targetRoute is explicitly provided and valid (not login/splash/lock)
    if (targetRoute != null &&
        targetRoute.isNotEmpty &&
        targetRoute != loginPageRoute &&
        targetRoute != splashPageRoute &&
        targetRoute != lockPageRoute) {
      Get.offAllNamed(targetRoute, arguments: targetArgs);
      return;
    }

    // Check current authenticated Firebase user with fallback wait
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      try {
        firebaseUser = await FirebaseAuth.instance
            .authStateChanges()
            .firstWhere((u) => u != null)
            .timeout(const Duration(seconds: 2));
      } catch (_) {
        firebaseUser = FirebaseAuth.instance.currentUser;
      }
    }

    if (firebaseUser == null) {
      // Check if session preference credentials exist
      final preference = myApplication.preferenceHelper;
      final userId = preference?.getString(userIdKey);
      final email = preference?.getString(emailKey);
      if (userId != null &&
          userId.isNotEmpty &&
          userId != "-1" &&
          email != null &&
          email.isNotEmpty) {
        Get.offAllNamed(welcomePageRoute);
        return;
      }

      developer.log('''
LOCK_NAV_DEBUG:
LOGIN_NAVIGATION_TRIGGERED
reason = Firebase user is null and no valid stored credentials found
caller/path = LockController.navigateAfterUnlock
''');

      Get.offAllNamed(loginPageRoute);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final userData = userDoc.data() ?? {};
      final isAdmin = userData['isAdmin'] == true ||
          userData['IsAdmin'] == true ||
          userData['admin'] == true ||
          userData['role'] == 'admin';

      if (isAdmin) {
        Get.offAllNamed(adminHomePageRoute);
      } else {
        Get.offAllNamed(welcomePageRoute);
      }
    } catch (_) {
      Get.offAllNamed(welcomePageRoute);
    }
  }

  // ==================== PRIVATE HELPERS ====================

  // _setError removed - unused
}
