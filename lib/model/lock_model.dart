// lock_model.dart
// Lock Screen data models following Agro-Prod patterns

import 'package:local_auth/local_auth.dart' as local_auth;

/// Lock screen configuration
class LockConfig {
  final bool enabled;
  final bool biometricEnabled;
  final String? pinHash; // SHA-256 hash of PIN

  LockConfig({
    required this.enabled,
    this.biometricEnabled = true,
    this.pinHash,
  });

  factory LockConfig.fromJson(Map<String, dynamic> json) => LockConfig(
    enabled: json['enabled'] as bool? ?? false,
    biometricEnabled: json['biometricEnabled'] as bool? ?? true,
    pinHash: json['pinHash'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'biometricEnabled': biometricEnabled,
    'pinHash': pinHash,
  };

  LockConfig copyWith({
    bool? enabled,
    bool? biometricEnabled,
    String? pinHash,
  }) => LockConfig(
    enabled: enabled ?? this.enabled,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    pinHash: pinHash ?? this.pinHash,
  );
}

/// Available biometric types - wrapper around local_auth BiometricType
enum BiometricType { face, fingerprint, iris, unknown }

/// Extension to convert from local_auth BiometricType
extension BiometricTypeExtension on local_auth.BiometricType {
  BiometricType toModelType() {
    switch (this) {
      case local_auth.BiometricType.face:
        return BiometricType.face;
      case local_auth.BiometricType.fingerprint:
        return BiometricType.fingerprint;
      case local_auth.BiometricType.iris:
        return BiometricType.iris;
      default:
        return BiometricType.unknown;
    }
  }
}

/// Authentication result
class AuthResult {
  final bool success;
  final String? error;
  final BiometricType? biometricType;

  AuthResult({required this.success, this.error, this.biometricType});

  factory AuthResult.success({BiometricType? biometricType}) =>
      AuthResult(success: true, biometricType: biometricType);

  factory AuthResult.failure(String error) =>
      AuthResult(success: false, error: error);
}

/// Lock screen navigation arguments
class LockArguments {
  final String? returnRoute;
  final Map<String, dynamic>? returnArgs;

  LockArguments({this.returnRoute, this.returnArgs});
}
