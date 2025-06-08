import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../state/navigation_state.dart';

class AuthGate extends StatefulWidget {
  final Widget child;
  final bool lockEnabled;

  const AuthGate({
    Key? key,
    required this.child,
    required this.lockEnabled,
  }) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _authenticated = false;
  bool _authInProgress = false;
  bool _paused = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.lockEnabled) {
      _showLockScreen();
    } else {
      _authenticated = true;
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
      _authenticated = false;
    } else if (state == AppLifecycleState.resumed && _paused) {
      _paused = false;
      if (widget.lockEnabled) {
        _showLockScreen();
      }
    }
  }

  Future<void> _showLockScreen() async {
    if (_authInProgress || _authenticated) return;

    setState(() {
      _authInProgress = true;
      _error = null;
    });

    try {
      final canAuthenticate = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        setState(() => _error = 'Device authentication not supported.');
        return;
      }

      final result = await _auth.authenticate(
        localizedReason: 'Unlock Wanderlust',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (result) {
        setState(() {
          _authenticated = true;
          _error = null;
        });

        // Navigate to last route
        final navState = context.read<NavigationState>();
        final lastRoute = navState.currentRoute;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (lastRoute.isNotEmpty &&
              ModalRoute.of(context)?.settings.name != lastRoute) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                lastRoute, (route) => false);
          }
        });
      } else {
        setState(() => _error = 'Authentication failed.');
      }
    } catch (e) {
      setState(() => _error = 'Error: ${e.toString()}');
    } finally {
      setState(() => _authInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.lockEnabled || _authenticated) return widget.child;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/app_icon.png', height: 100),
                const SizedBox(height: 24),
                const Text(
                  'Wanderlust is locked',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Icon(Icons.lock_outline, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _authInProgress ? null : _showLockScreen,
                  child: const Text('Unlock'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: const Text('Exit App', style: TextStyle(color: Colors.white)),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
