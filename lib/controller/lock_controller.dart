// lock_controller.dart
// Lock Screen Controller - All business logic extracted from Wanderlust LockScreen
// Follows Agro-Prod patterns: extends AppBaseController, uses LockService for all auth access

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/core/base/app_base_controller.dart';
import '../helper/route.dart';
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
    if (lockEnabled.value) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive ||
          state == AppLifecycleState.detached) {
        _lockApp();
      } else if (state == AppLifecycleState.resumed) {
        _onAppResumed();
      }
    }
  }

  void _onAppResumed() {
    if (lockEnabled.value && !unlocked.value) {
      authenticate();
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
    errorMessage.value = '';
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

  /// Enable/disable lock (called from Settings)
  Future<void> setLockEnabled(bool enabled) async {
    await _lockService.setLockEnabled(enabled);
    lockEnabled.value = enabled;

    if (enabled) {
      unlocked.value = false;
      await _checkBiometricAvailability();
      hasPin.value = _lockService.hasPin();
      authenticate();
    } else {
      unlocked.value = true;
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
  void navigateAfterUnlock(LockArguments? args) {
    if (args != null && args.returnRoute != null) {
      Get.offAllNamed(args.returnRoute!, arguments: args.returnArgs);
    } else {
      // Default: let SplashController decide
      Get.offAllNamed(loginPageRoute);
    }
  }

  // ==================== PRIVATE HELPERS ====================

  // _setError removed - unused
}
