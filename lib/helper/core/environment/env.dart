// Environment configuration for Wanderlust app.
// This replaces the Agro-Prod specific environment configuration.

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../app_string.dart';
import '../../enum.dart';

class EnvironmentConfig {
  final String baseApiurl;
  final String title;
  final String appUpdateDate;
  final String releaseDate;
  final bool enableLogs; // Display logs in console
  final bool
  enableNetworkImages; // Disable or enable loading images from s3. disbale in dev stage for reduce the s3 hits.
  final String version;
  late PlatformType platformType;

  EnvironmentConfig({
    required this.baseApiurl,
    required this.title,
    required this.appUpdateDate,
    required this.releaseDate,
    required this.enableLogs,
    required this.enableNetworkImages,
    required this.version,
  }) {
    if (kIsWeb) {
      platformType = PlatformType.android; // Default for web
    } else if (Platform.isAndroid) {
      platformType = PlatformType.android;
    } else if (Platform.isIOS) {
      platformType = PlatformType.ios;
    } else {
      throw Exception(platformNotSupportedMsg);
    }
  }
}

class DevEnvironment extends EnvironmentConfig {
  DevEnvironment()
    : super(
        baseApiurl: 'https://wanderlust-dev.firebaseio.com',
        title: 'Wanderlust Dev',
        appUpdateDate: '2025-01-01',
        releaseDate: '2025-01-01',
        enableLogs: true,
        enableNetworkImages: false,
        version: '1.0.0',
      );
}

class ProdEnvironment extends EnvironmentConfig {
  ProdEnvironment()
    : super(
        baseApiurl: 'https://wanderlust.firebaseio.com',
        title: 'Wanderlust',
        appUpdateDate: '2025-01-01',
        releaseDate: '2025-01-01',
        enableLogs: false,
        enableNetworkImages: true,
        version: '1.0.0',
      );
}

class UatEnvironment extends EnvironmentConfig {
  UatEnvironment()
    : super(
        baseApiurl: 'https://wanderlust-staging.firebaseio.com',
        title: 'Wanderlust UAT',
        appUpdateDate: '2025-01-01',
        releaseDate: '2025-01-01',
        enableLogs: true,
        enableNetworkImages: true,
        version: '1.0.0',
      );
}

class AppEnvironment {
  static late EnvironmentConfig config;
  static late Environment environment;
  static late UserDeviceType deviceType;
  static late AppClient appClient;
  static late ThemeModeType themeModeType;

  static void setEnv(Environment env) {
    environment = env;
    switch (env) {
      case Environment.DEV:
        config = DevEnvironment();
        break;
      case Environment.PROD:
        config = ProdEnvironment();
        break;
      case Environment.UAT:
        config = UatEnvironment();
    }
  }

  static void setDeviceType(UserDeviceType type) {
    deviceType = type;
  }

  static void setClient(AppClient client) {
    appClient = client;
  }

  static void setThemeMode(ThemeModeType type) {
    themeModeType = type;
  }

  static bool isDarkMode() => themeModeType == ThemeModeType.dark;
  static bool isDevMode() => environment == Environment.DEV;
  static bool isProdMode() => environment == Environment.PROD;
  static bool isUatMode() => environment == Environment.UAT;

  static bool isAndroid() => config.platformType == PlatformType.android;
  static bool isIos() => config.platformType == PlatformType.ios;
}
