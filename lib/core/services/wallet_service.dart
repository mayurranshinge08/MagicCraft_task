import 'dart:math';
import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:hex/hex.dart';
import 'package:web3dart/web3dart.dart';

import '../models/wallet_model.dart';
import 'secure_storage_service.dart';

class WalletService {
  static const String _derivationPath =
      "m/44'/60'/0'/0/0"; // Ethereum derivation path

  /// Generate a new 12-word mnemonic using cryptographically secure entropy
  static String generateMnemonic() {
    // Generate 128 bits of entropy for 12-word mnemonic
    final random = Random.secure();
    final entropy = Uint8List(16);
    for (int i = 0; i < entropy.length; i++) {
      entropy[i] = random.nextInt(256);
    }

    return bip39.entropyToMnemonic(HEX.encode(entropy));
  }

  /// Validate if a mnemonic is valid according to BIP39
  static bool validateMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic.trim());
  }

  /// Derive private key from mnemonic using BIP32/BIP44
  static String derivePrivateKey(String mnemonic) {
    if (!validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic phrase');
    }

    // Generate seed from mnemonic
    final seed = bip39.mnemonicToSeed(mnemonic);

    // Create master key from seed
    final master = bip32.BIP32.fromSeed(seed);

    // Derive key using Ethereum derivation path
    final child = master.derivePath(_derivationPath);

    if (child.privateKey == null) {
      throw Exception('Failed to derive private key');
    }

    return HEX.encode(child.privateKey!);
  }

  /// Get Ethereum address from private key
  static String getAddressFromPrivateKey(String privateKeyHex) {
    final privateKey = EthPrivateKey.fromHex(privateKeyHex);
    return privateKey.address.hex;
  }

  /// Create a new wallet with generated mnemonic
  static Future<WalletModel> createWallet({String? name}) async {
    final mnemonic = generateMnemonic();
    return await importWallet(mnemonic, name: name ?? 'My Wallet');
  }

  /// Import wallet from existing mnemonic
  static Future<WalletModel> importWallet(String mnemonic,
      {String? name}) async {
    if (!validateMnemonic(mnemonic)) {
      throw Exception('Invalid mnemonic phrase');
    }

    final privateKey = derivePrivateKey(mnemonic);
    final address = getAddressFromPrivateKey(privateKey);

    final wallet = WalletModel(
      address: address,
      privateKey: privateKey,
      mnemonic: mnemonic.trim(),
      createdAt: DateTime.now(),
      name: name ?? 'Imported Wallet',
    );

    // Store wallet securely
    await SecureStorageService.storeWallet(
      wallet.mnemonic,
      wallet.privateKey,
      wallet.address,
    );

    return wallet;
  }

  /// Load existing wallet from secure storage
  static Future<WalletModel?> loadWallet() async {
    final walletData = await SecureStorageService.getWallet();
    if (walletData == null) return null;

    try {
      return WalletModel(
        address: walletData['address'],
        privateKey: walletData['privateKey'],
        mnemonic: walletData['mnemonic'],
        createdAt: DateTime.parse(walletData['createdAt']),
        name: walletData['name'] ?? 'My Wallet',
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if wallet exists in secure storage
  static Future<bool> hasWallet() async {
    return await SecureStorageService.hasWallet();
  }

  /// Delete wallet from secure storage
  static Future<void> deleteWallet() async {
    await SecureStorageService.deleteWallet();
  }

  /// Get wallet credentials for transactions
  static EthPrivateKey getCredentials(String privateKeyHex) {
    return EthPrivateKey.fromHex(privateKeyHex);
  }

  /// Validate Ethereum address format
  static bool isValidAddress(String address) {
    try {
      EthereumAddress.fromHex(address);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Format address for display (shortened)
  static String formatAddress(String address,
      {int prefixLength = 6, int suffixLength = 4}) {
    if (address.length <= prefixLength + suffixLength) {
      return address;
    }
    return '${address.substring(0, prefixLength)}...${address.substring(address.length - suffixLength)}';
  }

  /// Convert Wei to Ether
  static String weiToEther(BigInt wei) {
    return EtherAmount.fromBigInt(EtherUnit.wei, wei)
        .getValueInUnit(EtherUnit.ether)
        .toString();
  }

  /// Convert Ether to Wei
  static BigInt etherToWei(String ether) {
    final etherAmount = EtherAmount.fromUnitAndValue(EtherUnit.ether, ether);
    return etherAmount.getInWei;
  }
}
