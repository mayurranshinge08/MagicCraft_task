import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Wallet Storage
  static Future<void> storeWallet(
    String mnemonic,
    String privateKey,
    String address,
  ) async {
    final walletData = {
      'mnemonic': mnemonic,
      'privateKey': privateKey,
      'address': address,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _storage.write(
      key: AppConstants.secureStorageWalletKey,
      value: jsonEncode(walletData),
    );
  }

  static Future<Map<String, dynamic>?> getWallet() async {
    final walletJson = await _storage.read(
      key: AppConstants.secureStorageWalletKey,
    );
    if (walletJson == null) return null;

    try {
      return jsonDecode(walletJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> hasWallet() async {
    final wallet = await getWallet();
    return wallet != null;
  }

  static Future<void> deleteWallet() async {
    await _storage.delete(key: AppConstants.secureStorageWalletKey);
  }

  // Passcode Storage
  static Future<void> storePasscode(String passcode) async {
    final hashedPasscode = _hashPasscode(passcode);
    await _storage.write(
      key: AppConstants.secureStoragePasscodeKey,
      value: hashedPasscode,
    );
  }

  static Future<bool> verifyPasscode(String passcode) async {
    final storedHash = await _storage.read(
      key: AppConstants.secureStoragePasscodeKey,
    );
    if (storedHash == null) return false;

    final inputHash = _hashPasscode(passcode);
    return storedHash == inputHash;
  }

  static Future<bool> hasPasscode() async {
    final passcode = await _storage.read(
      key: AppConstants.secureStoragePasscodeKey,
    );
    return passcode != null;
  }

  static Future<void> deletePasscode() async {
    await _storage.delete(key: AppConstants.secureStoragePasscodeKey);
  }

  // Network Settings
  static Future<void> storeSelectedNetwork(String networkId) async {
    await _storage.write(key: 'selected_network', value: networkId);
  }

  static Future<String> getSelectedNetwork() async {
    return await _storage.read(key: 'selected_network') ?? 'ethereum';
  }

  // Custom RPC Storage
  static Future<void> storeCustomRpc(String networkId, String rpcUrl) async {
    await _storage.write(key: 'custom_rpc_$networkId', value: rpcUrl);
  }

  static Future<String?> getCustomRpc(String networkId) async {
    return await _storage.read(key: 'custom_rpc_$networkId');
  }

  // Biometric Preference Storage
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  static Future<String?> getBiometricEnabled() async {
    return await _storage.read(key: 'biometric_enabled');
  }

  // Utility Methods
  static String _hashPasscode(String passcode) {
    final bytes = utf8.encode(passcode + 'magiccraft_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
