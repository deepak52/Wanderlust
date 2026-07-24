import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApplication {
  MyApplication._internal();

  static final MyApplication _instance = MyApplication._internal();

  factory MyApplication() {
    return _instance;
  }

  late String? versionNumber;
  late String? serviceVersion;
  SharedPreferences? _prefs;

  Future<String> _getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<void> setVersionNumber() async {
    versionNumber = await _getVersionNumber();
    if (_prefs != null) {
      serviceVersion = _prefs!.getString('serviceVersion') ?? '1.0.0.0';
    }
  }

  Future<void> setUpSharedPreference() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get preferences => _prefs!;
}
