import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../services/secure_storage_service.dart';

class NetworkProvider extends ChangeNotifier {
  String _currentNetworkId = 'ethereum';
  Map<String, String> _customRpcs = {};

  // Getters
  String get currentNetworkId => _currentNetworkId;
  NetworkConfig get currentNetwork =>
      AppConstants.supportedNetworks[_currentNetworkId]!;
  List<String> get supportedNetworkIds =>
      AppConstants.supportedNetworks.keys.toList();

  String get currentRpcUrl {
    final customRpc = _customRpcs[_currentNetworkId];
    return customRpc ?? currentNetwork.rpcUrl;
  }

  // Initialize network provider
  Future<void> initialize() async {
    try {
      _currentNetworkId = await SecureStorageService.getSelectedNetwork();
      await _loadCustomRpcs();
      notifyListeners();
    } catch (e) {
      // Use default network if loading fails
      _currentNetworkId = 'ethereum';
    }
  }

  // Switch to different network
  Future<void> switchNetwork(String networkId) async {
    if (!AppConstants.supportedNetworks.containsKey(networkId)) {
      throw Exception('Unsupported network: $networkId');
    }

    _currentNetworkId = networkId;
    await SecureStorageService.storeSelectedNetwork(networkId);
    notifyListeners();
  }

  // Add or update custom RPC for a network
  Future<void> setCustomRpc(String networkId, String rpcUrl) async {
    if (!AppConstants.supportedNetworks.containsKey(networkId)) {
      throw Exception('Unsupported network: $networkId');
    }

    _customRpcs[networkId] = rpcUrl;
    await SecureStorageService.storeCustomRpc(networkId, rpcUrl);
    notifyListeners();
  }

  // Remove custom RPC for a network
  Future<void> removeCustomRpc(String networkId) async {
    _customRpcs.remove(networkId);
    await SecureStorageService.storeCustomRpc(networkId, '');
    notifyListeners();
  }

  // Get network configuration by ID
  NetworkConfig? getNetworkConfig(String networkId) {
    return AppConstants.supportedNetworks[networkId];
  }

  // Check if network has custom RPC
  bool hasCustomRpc(String networkId) {
    return _customRpcs.containsKey(networkId) &&
        _customRpcs[networkId]!.isNotEmpty;
  }

  // Get custom RPC URL for network
  String? getCustomRpc(String networkId) {
    return _customRpcs[networkId];
  }

  // Load all custom RPCs from storage
  Future<void> _loadCustomRpcs() async {
    for (final networkId in supportedNetworkIds) {
      final customRpc = await SecureStorageService.getCustomRpc(networkId);
      if (customRpc != null && customRpc.isNotEmpty) {
        _customRpcs[networkId] = customRpc;
      }
    }
  }

  // Get explorer URL for transaction
  String getTransactionUrl(String txHash) {
    return '${currentNetwork.explorerUrl}/tx/$txHash';
  }

  // Get explorer URL for address
  String getAddressUrl(String address) {
    return '${currentNetwork.explorerUrl}/address/$address';
  }
}
