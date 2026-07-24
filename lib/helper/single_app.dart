// ohaan_app.dart

import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'app_string.dart';
import 'shared_pref.dart';

class MyApplication {
  // Private constructor to enforce singleton behavior
  MyApplication._internal() {
    logger = Logger();
  }

  static final MyApplication _instance = MyApplication._internal();

  factory MyApplication() {
    return _instance;
  }

  late Logger logger;

  late String? versionNumber;
  late String? serviceVersion;
  late SharedPreferenceHelper? preferenceHelper;
  // late UserProfileResponse? userProfile;

  Future<String> _getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<void> setVersionNumber() async {
    versionNumber = await _getVersionNumber();
    if (preferenceHelper != null) {
      serviceVersion = preferenceHelper!.getString(
        serviceKey,
        defaultValue: '1.0.0.0',
      );
    }
  }

  // void setUserProfile(UserProfileResponse data) {
  //   userProfile = data;
  // }

  Future<void> setUpSharedPreference() async {
    preferenceHelper = await SharedPreferenceHelper().init();
  }
}

// Global instance for easy access
MyApplication myApplication = MyApplication();
