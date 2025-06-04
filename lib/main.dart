import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/root_decider.dart';
import 'screens/admin_home_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/lock_screen.dart';
import 'widgets/auth_gate.dart';

import 'helpers/notification_helper.dart';
import 'services/missed_message_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationHelper.initializeFCM();
  NotificationHelper.setUpForegroundListener();
  MissedMessageService().startListening();
  await NotificationHelper.clearAllNotifications();

  final prefs = await SharedPreferences.getInstance();
  final lockEnabled = prefs.getBool('lock_enabled') ?? false;

  runApp(MyApp(lockEnabled: lockEnabled));
}

class MyApp extends StatelessWidget {
  final bool lockEnabled;

  const MyApp({super.key, required this.lockEnabled});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Name',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeDecider(lockEnabled: lockEnabled),
      routes: {
        '/admin_home': (context) => const AdminHomeScreen(),
        '/welcome_screen': (context) => const WelcomeScreen(),
      },
    );
  }
}

class HomeDecider extends StatefulWidget {
  final bool lockEnabled;

  const HomeDecider({super.key, required this.lockEnabled});

  @override
  State<HomeDecider> createState() => _HomeDeciderState();
}

class _HomeDeciderState extends State<HomeDecider> {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();

    if (widget.lockEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => LockScreen(
                  onUnlocked: () {
                    setState(() {
                      _unlocked = true;
                    });
                    Navigator.of(context).pop();
                  },
                ),
          ),
        );
      });
    } else {
      _unlocked = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lockEnabled && !_unlocked) {
      return const Scaffold(body: SizedBox()); // empty until unlocked
    }

    return const AuthGate(child: RootDecider());
  }
}
