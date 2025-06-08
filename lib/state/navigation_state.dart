import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NavigationState with ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _currentRoute = '/';
  Map<String, dynamic>? _currentArgs;

  String get currentRoute => _currentRoute;
  Map<String, dynamic>? get currentArgs => _currentArgs;

  void updateRoute(String route, {Map<String, dynamic>? args}) {
    if (route == _currentRoute &&
        jsonEncode(args) == jsonEncode(_currentArgs)) {
      return; // no update needed
    }

    _currentRoute = route;
    _currentArgs = args;
    _saveRouteToPrefs(route, args);
    notifyListeners();
  }

  Future<void> _saveRouteToPrefs(
    String route,
    Map<String, dynamic>? args,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('last_route', route);
    if (args != null) {
      prefs.setString('last_route_args', jsonEncode(args));
    } else {
      prefs.remove('last_route_args');
    }
  }

  Future<void> restoreRouteFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _currentRoute = prefs.getString('last_route') ?? '/';
    final argsString = prefs.getString('last_route_args');
    if (argsString != null) {
      _currentArgs = jsonDecode(argsString);
    } else {
      _currentArgs = null;
    }
  }
}
