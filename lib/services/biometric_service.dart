import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if the device supports biometrics (fingerprint or face).
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Returns the list of enrolled biometric types (fingerprint, face, iris).
  static Future<List<BiometricType>> getEnrolledBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Authenticate the user using their enrolled biometrics.
  /// Returns true if authentication was successful, false otherwise.
  static Future<bool> authenticate({String reason = 'Verify your identity to unlock Nimbus Spend'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow device PIN/pattern as fallback
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
