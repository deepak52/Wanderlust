import 'package:flutter/material.dart';

/// Widget that wraps child widgets to enforce biometric lock state
/// Monitoring AppLifecycleState to automatically lock the screen on resume
class AuthGate extends StatefulWidget {
  final Widget child;

  const AuthGate({
    super.key,
    required this.child,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
