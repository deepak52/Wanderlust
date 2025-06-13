import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/notification_helper.dart';
import 'state/navigation_state.dart';
import 'state/lock_state.dart' as custom;

import 'screens/root_decider.dart';
import 'screens/user_list_screen.dart';
import 'screens/responses_screen.dart';
import 'widgets/auth_gate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // ✅ FCM background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ✅ Init notifications
  await NotificationHelper.initializeFCM();
  NotificationHelper.setUpForegroundListener();

  final prefs = await SharedPreferences.getInstance();
  final lockEnabled = prefs.getBool('lock_enabled') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => custom.LockState(lockEnabled: lockEnabled),
        ),
        ChangeNotifierProvider(create: (_) => NavigationState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lockState = context.watch<custom.LockState>();
    final navigationState = context.watch<NavigationState>();

    return MaterialApp(
      title: 'Wanderlust',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const RootDecider(),
        '/user_list': (context) => UserListScreen(),
        '/responses': (context) => ResponsesScreen(),
      },
      navigatorObservers: [_RouteObserver(navigationState)],
      builder: (context, child) {
        return AuthGate(
          lockEnabled: lockState.lockEnabled,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _RouteObserver extends NavigatorObserver {
  final NavigationState navigationState;
  _RouteObserver(this.navigationState);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      navigationState.updateRoute(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.name != null) {
      navigationState.updateRoute(previousRoute!.settings.name!);
    }
  }
}
