import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/lock_manager.dart';

/// A widget that blocks its [child] behind device authentication (biometric or PIN/pattern).
/// It authenticates on first display and whenever the app resumes from background.
class AuthGate extends StatefulWidget {
  /// The widget to display once unlocked
  final Widget child;

  const AuthGate({Key? key, required this.child}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _unlocked = false;
  bool _authInProgress = false;
  bool _hasUnlockedOnce = false;
  bool _paused = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockStatusAndAuthenticate();
  }

  Future<void> _checkLockStatusAndAuthenticate() async {
    final lockEnabled = await LockManager.isLockEnabled();
    if (lockEnabled) {
      _authenticate();
    } else {
      setState(() {
        _unlocked = true; // immediately allow access
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _paused = true;
    } else if (state == AppLifecycleState.resumed &&
        _paused &&
        _hasUnlockedOnce) {
      _paused = false;
      _lockAndAuthenticate();
    }
  }

  void _lockAndAuthenticate() async {
    final lockEnabled = await LockManager.isLockEnabled();
    if (!lockEnabled) {
      setState(() {
        _unlocked = true;
      });
      return;
    }

    setState(() {
      _unlocked = false;
      _errorMessage = null;
    });
    _authenticate();
  }

  Future<void> _authenticate() async {
    if (_authInProgress) return;
    _authInProgress = true;
    setState(() {
      _errorMessage = null;
    });

    try {
      final canAuthenticate =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canAuthenticate) {
        setState(() {
          _errorMessage = 'No device security available';
        });
        return;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock Wanderlust',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: false,
          useErrorDialogs: true,
        ),
      );

      if (authenticated && mounted) {
        setState(() {
          _unlocked = true;
          _hasUnlockedOnce = true;
          _errorMessage = null;
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Authentication failed';
        });
      }
    } catch (e) {
      debugPrint('AuthGate error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        _authInProgress = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      // Prevent back navigation to exit lock
      return WillPopScope(
        onWillPop: () async {
          _authenticate();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App logo and title positioned near the top
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icons/app_icon.png',
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Wanderlust is locked',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Center lock icon and unlock text
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: _authenticate,
                          child: const Text(
                            'Unlock',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
