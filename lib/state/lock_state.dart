import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockState extends ChangeNotifier with WidgetsBindingObserver {
  bool _lockEnabled;
  bool _unlocked;

  LockState({required bool lockEnabled})
    : _lockEnabled = lockEnabled,
      _unlocked = !lockEnabled {
    WidgetsBinding.instance.addObserver(this);
  }

  bool get lockEnabled => _lockEnabled;
  bool get unlocked => _unlocked;

  void setLockEnabled(bool enabled) async {
    _lockEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lock_enabled', enabled);
  }

  void setUnlocked(bool value) {
    _unlocked = value;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_lockEnabled && state == AppLifecycleState.paused) {
      _unlocked = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
