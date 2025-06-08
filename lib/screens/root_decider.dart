// lib/screens/root_decider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helpers/notification_helper.dart';
import 'login_screen.dart';
import 'admin_home_screen.dart';
import 'welcome_screen.dart';

class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final user = snap.data;
        if (user == null) return const LoginScreen();
        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
          builder: (context, snap2) {
            if (snap2.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap2.hasError) {
              return Center(
                child: Text('Error loading user data: ${snap2.error}'),
              );
            }
            if (!snap2.hasData || !snap2.data!.exists) {
              return const Center(child: Text('User data not found.'));
            }
            final data = snap2.data!.data() as Map<String, dynamic>?;
            final isAdmin = data?['isAdmin'] ?? false;
            NotificationHelper.saveTokenToFirestore(isAdmin);
            return isAdmin ? const AdminHomeScreen() : const WelcomeScreen();
          },
        );
      },
    );
  }
}
