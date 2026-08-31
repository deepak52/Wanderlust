// lock_service.dart
// Lock Screen Service - All biometric/PIN/storage logic
// Follows Agro-Prod patterns: extends AppBaseService, uses Get.find for SharedPreferenceHelper

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart' as local_auth;
import 'package:get/get.dart';

import '../helper/core/base/app_base_service.dart';
import '../helper/shared_pref.dart';
import '../model/lock_model.dart';

class LockService extends AppBaseService {
  final local_auth.LocalAuthentication _localAuth =
      local_auth.LocalAuthentication();
  final SharedPreferenceHelper _prefs = Get.find<SharedPreferenceHelper>();

  static const String _lockConfigKey = 'lock_config';
  static const String _lockEnabledKey = 'lock_enabled';

  void initialize() {
    developer.log('LockService initialize called');
  }

  void dispose() {
    developer.log('LockService dispose called');
  }

  // ==================== INITIALIZATION ====================

  /// Initialize lock service (call after Get.put)
  Future<void> initLockService() async {
    // Ensure SharedPreferences is initialized
    await _prefs.init();
    // Check if key exists by trying to get it
    final value = _prefs.getString(_lockEnabledKey);
    if (value.isEmpty) {
      await _prefs.setBool(_lockEnabledKey, false);
    }
  }

  // ==================== LOCK CONFIG ====================

  /// Get current lock configuration
  LockConfig getLockConfig() {
    final enabled = isLockEnabled();
    final json = _prefs.getString(_lockConfigKey);
    if (json.isEmpty) {
      return LockConfig(enabled: enabled);
    }
    try {
      final Map<String, dynamic> data = jsonDecode(json);
      final config = LockConfig.fromJson(data);
      return config.copyWith(enabled: enabled || config.enabled);
    } catch (e) {
      debugPrint('Error parsing lock config: $e');
      return LockConfig(enabled: enabled);
    }
  }

  /// Save lock configuration
  Future<void> saveLockConfig(LockConfig config) async {
    final json = jsonEncode(config.toJson());
    await _prefs.setString(_lockConfigKey, json);
  }

  /// Check if lock is enabled
  bool isLockEnabled() {
    return _prefs.getBool(_lockEnabledKey, defaultValue: false);
  }

  /// Enable/disable lock
  Future<void> setLockEnabled(bool enabled) async {
    developer.log('[LOCK_STATE] Toggle changed: enabled=$enabled');
    await _prefs.setBool(_lockEnabledKey, enabled);
    final config = getLockConfig();
    await saveLockConfig(config.copyWith(enabled: enabled));
    developer.log('[LOCK_STATE] Persisted value=$enabled');
  }

  // ==================== BIOMETRIC ====================

  /// Check if biometric authentication is available
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<local_auth.BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting biometrics: $e');
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<AuthResult> authenticateWithBiometrics({
    String localizedReason = 'Unlock the app',
  }) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        // Note: biometricOnly, sensitiveTransaction and persistAcrossBackgrounding
        // are deprecated in newer local_auth versions
      );

      if (authenticated) {
        final biometrics = await getAvailableBiometrics();
        BiometricType? biometricType;
        if (biometrics.contains(local_auth.BiometricType.face)) {
          biometricType = BiometricType.face;
        } else if (biometrics.contains(local_auth.BiometricType.fingerprint)) {
          biometricType = BiometricType.fingerprint;
        } else if (biometrics.contains(local_auth.BiometricType.iris)) {
          biometricType = BiometricType.iris;
        }
        return AuthResult.success(biometricType: biometricType);
      }
      return AuthResult.failure('Authentication failed');
    } catch (e) {
      // Check if it's an authentication error (user cancelled, etc.)
      final errorStr = e.toString();
      if (errorStr.contains('cancelled') ||
          errorStr.contains('Canceled') ||
          errorStr.contains('UserCancel')) {
        return AuthResult.failure('Authentication cancelled');
      }
      return AuthResult.failure('Biometric error: $e');
    }
  }

  // ==================== PIN ====================

  /// Hash PIN with SHA-256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify PIN hash
  bool _verifyPinHash(String inputPin, String storedHash) {
    return _hashPin(inputPin) == storedHash;
  }

  /// Set new PIN
  Future<void> setPin(String pin) async {
    final config = getLockConfig();
    final hashedPin = _hashPin(pin);
    await saveLockConfig(config.copyWith(pinHash: hashedPin));
  }

  /// Check if PIN is set
  bool hasPin() {
    final config = getLockConfig();
    return config.pinHash != null && config.pinHash!.isNotEmpty;
  }

  /// Verify entered PIN
  Future<AuthResult> verifyPin(String pin) async {
    final config = getLockConfig();
    if (config.pinHash == null) {
      return AuthResult.failure('No PIN set');
    }
    if (_verifyPinHash(pin, config.pinHash!)) {
      return AuthResult.success();
    }
    return AuthResult.failure('Incorrect PIN');
  }

  // ==================== LOCK STATE ====================

  /// Lock the app (called when app goes to background)
  void lockApp() {
    // This is handled by the controller observing lifecycle
  }

  /// Unlock the app (called after successful auth)
  void unlockApp() {
    // This is handled by the controller
  }
}
