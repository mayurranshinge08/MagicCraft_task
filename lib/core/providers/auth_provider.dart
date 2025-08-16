import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../services/secure_storage_service.dart';
import '../services/wallet_service.dart';

enum AuthState { initial, authenticated, unauthenticated, locked }

enum BiometricType { none, fingerprint, face, iris }

class AuthProvider extends ChangeNotifier {
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthState _authState = AuthState.initial;
  bool _isBiometricEnabled = false;
  BiometricType _availableBiometric = BiometricType.none;
  bool _isLoading = false;
  String? _error;

  // Getters
  AuthState get authState => _authState;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isLocked => _authState == AuthState.locked;
  bool get isBiometricEnabled => _isBiometricEnabled;
  BiometricType get availableBiometric => _availableBiometric;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize authentication system
  Future<void> initialize() async {
    try {
      _setLoading(true);
      await _checkBiometricAvailability();
      await _loadBiometricPreference();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Check if wallet exists
  Future<bool> hasExistingWallet() async {
    return await WalletService.hasWallet();
  }

  // Setup passcode during onboarding
  Future<bool> setupPasscode(String passcode) async {
    try {
      _setLoading(true);
      _clearError();

      await SecureStorageService.storePasscode(passcode);
      _authState = AuthState.authenticated;

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to setup passcode: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify passcode
  Future<bool> verifyPasscode(String passcode) async {
    try {
      _setLoading(true);
      _clearError();

      final isValid = await SecureStorageService.verifyPasscode(passcode);
      if (isValid) {
        _authState = AuthState.authenticated;
        notifyListeners();
      } else {
        _setError('Invalid passcode');
      }

      return isValid;
    } catch (e) {
      _setError('Failed to verify passcode: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    if (!_isBiometricEnabled || _availableBiometric == BiometricType.none) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your MagicCraft wallet',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        _authState = AuthState.authenticated;
        notifyListeners();
      }

      return isAuthenticated;
    } on PlatformException catch (e) {
      _setError('Biometric authentication failed: ${e.message}');
      return false;
    } catch (e) {
      _setError('Authentication error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Enable/disable biometric authentication
  Future<bool> setBiometricEnabled(bool enabled) async {
    if (enabled && _availableBiometric == BiometricType.none) {
      _setError('Biometric authentication is not available on this device');
      return false;
    }

    try {
      if (enabled) {
        // Test biometric authentication before enabling
        final canAuthenticate = await _localAuth.authenticate(
          localizedReason:
              'Enable biometric authentication for MagicCraft wallet',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (!canAuthenticate) {
          return false;
        }
      }

      _isBiometricEnabled = enabled;
      await SecureStorageService.setBiometricEnabled(enabled);

      notifyListeners();
      return true;
    } catch (e) {
      _setError(
        'Failed to ${enabled ? 'enable' : 'disable'} biometric authentication',
      );
      return false;
    }
  }

  // Lock the app
  void lockApp() {
    _authState = AuthState.locked;
    notifyListeners();
  }

  // Logout and clear authentication
  Future<void> logout() async {
    _authState = AuthState.unauthenticated;
    _isBiometricEnabled = false;
    await SecureStorageService.clearAll();
    notifyListeners();
  }

  // Check biometric availability
  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        _availableBiometric = BiometricType.none;
        return;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.contains(BiometricType.face)) {
        _availableBiometric = BiometricType.face;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        _availableBiometric = BiometricType.fingerprint;
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        _availableBiometric = BiometricType.iris;
      } else {
        _availableBiometric = BiometricType.none;
      }
    } catch (e) {
      _availableBiometric = BiometricType.none;
    }
  }

  // Load biometric preference from storage
  Future<void> _loadBiometricPreference() async {
    try {
      final enabled = await SecureStorageService.getBiometricEnabled();
      _isBiometricEnabled = enabled == 'true';
    } catch (e) {
      _isBiometricEnabled = false;
    }
  }

  // Get biometric icon based on available type
  String get biometricIcon {
    switch (_availableBiometric) {
      case BiometricType.face:
        return 'face';
      case BiometricType.fingerprint:
        return 'fingerprint';
      case BiometricType.iris:
        return 'visibility';
      case BiometricType.none:
        return 'security';
    }
  }

  // Get biometric display name
  String get biometricDisplayName {
    switch (_availableBiometric) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.none:
        return 'Biometric';
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
