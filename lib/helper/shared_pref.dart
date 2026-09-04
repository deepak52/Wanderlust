import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  SharedPreferences? _prefs;

  // Singleton instance
  static final SharedPreferenceHelper _instance =
      SharedPreferenceHelper._internal();

  factory SharedPreferenceHelper() {
    return _instance;
  }

  SharedPreferenceHelper._internal();

  // Initialize shared preferences
  Future<SharedPreferenceHelper> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('SharedPreferenceHelper init exception: $e');
    }
    return _instance;
  }

  // Set int value
  Future<bool> setInt(String key, int value) async {
    if (_prefs == null) return false;
    return _prefs!.setInt(key, value);
  }

  // Get int value
  int getInt(String key, {int defaultValue = -1}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  // Set double value
  Future<bool> setDouble(String key, double value) async {
    if (_prefs == null) return false;
    return _prefs!.setDouble(key, value);
  }

  // Get double value
  double getDouble(String key, {double defaultValue = -1}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  // Set bool value
  Future<bool> setBool(String key, bool value) async {
    if (_prefs == null) return false;
    return _prefs!.setBool(key, value);
  }

  // Get bool value
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  // Set String value
  Future<bool> setString(String key, String value) async {
    if (_prefs == null) return false;
    return _prefs!.setString(key, value);
  }

  // Get String value
  String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  // Set List<String> value
  Future<bool> setStringList(String key, List<String> value) async {
    if (_prefs == null) return false;
    return _prefs!.setStringList(key, value);
  }

  // Get List<String> value
  List<String> getStringList(String key, {List<String>? defaultValue}) {
    return _prefs?.getStringList(key) ?? (defaultValue ?? []);
  }

  // Remove a key-value pair
  Future<bool> remove(String key) async {
    if (_prefs == null) return false;
    return _prefs!.remove(key);
  }

  // Clear all data
  Future<bool> clear() async {
    if (_prefs == null) return false;
    return _prefs!.clear();
  }
}

// Preference keys constants
class PreferenceKeys {
  static const String userIdKey = 'user_id';
  static const String emailKey = 'email';
  static const String accessTokenKey = 'access_token';
  static const String loginPasswordKey = 'login_password';
  static const String rememberMeKey = 'remember_me';
  static const String deviceIdKey = 'device_id';
  static const String fcmTokenKey = 'fcm_token';
  static const String userCodeKey = 'user_code';
  static const String userNameKey = 'user_name';
  static const String defaultCompCodeKey = 'default_comp_code';
  static const String defaultBranchCodeKey = 'default_branch_code';
  static const String defaultLocationIDKey = 'default_location_id';
  static const String designationKey = 'designation';
  static const String isAdminKey = 'is_admin';
  static const String appLockEnabledKey = 'app_lock_enabled';
  static const String appLockPinKey = 'app_lock_pin';
  static const String appLockBiometricKey = 'app_lock_biometric';
  static const String lastSeenChatKey = 'last_seen_chat';
}
