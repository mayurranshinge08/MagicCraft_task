import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import '../constants/app_constants.dart';
import '../models/wallet_model.dart';
import '../services/secure_storage_service.dart';
import '../services/wallet_service.dart';
import 'network_provider.dart';

class WalletProvider extends ChangeNotifier {
  WalletModel? _currentWallet;
  List<TokenBalance> _tokenBalances = [];
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  WalletModel? get currentWallet => _currentWallet;
  List<TokenBalance> get tokenBalances => _tokenBalances;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasWallet => _currentWallet != null;

  String get walletAddress => _currentWallet?.address ?? '';
  String get formattedAddress =>
      _currentWallet != null
          ? WalletService.formatAddress(_currentWallet!.address)
          : '';

  // Create new wallet
  Future<bool> createWallet({String? name}) async {
    try {
      _setLoading(true);
      _clearError();

      final wallet = await WalletService.createWallet(name: name);
      _currentWallet = wallet;

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create wallet: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Import wallet from mnemonic
  Future<bool> importWallet(String mnemonic, {String? name}) async {
    try {
      _setLoading(true);
      _clearError();

      final wallet = await WalletService.importWallet(mnemonic, name: name);
      _currentWallet = wallet;

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to import wallet: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load existing wallet
  Future<bool> loadWallet() async {
    try {
      _setLoading(true);
      _clearError();

      final wallet = await WalletService.loadWallet();
      if (wallet != null) {
        _currentWallet = wallet;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to load wallet: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete wallet
  Future<void> deleteWallet() async {
    try {
      await WalletService.deleteWallet();
      _currentWallet = null;
      _tokenBalances.clear();
      _recentTransactions.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete wallet: ${e.toString()}');
    }
  }

  // Refresh wallet data (balances and transactions)
  Future<void> refreshWalletData(NetworkProvider networkProvider) async {
    if (_currentWallet == null) return;

    try {
      _setLoading(true);
      _clearError();

      await Future.wait([
        _loadTokenBalances(networkProvider),
        _loadRecentTransactions(networkProvider),
      ]);
    } catch (e) {
      _setError('Failed to refresh wallet data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load token balances (native + MCRT)
  Future<void> _loadTokenBalances(NetworkProvider networkProvider) async {
    if (_currentWallet == null) return;

    final client = Web3Client(networkProvider.currentNetwork.rpcUrl, Client());
    final address = _currentWallet!.ethereumAddress;

    try {
      // Get native token balance
      final nativeBalance = await client.getBalance(address);
      final nativeBalanceEther = WalletService.weiToEther(
        nativeBalance.getInWei,
      );

      final balances = <TokenBalance>[
        TokenBalance(
          symbol: networkProvider.currentNetwork.nativeCurrency.symbol,
          name: networkProvider.currentNetwork.nativeCurrency.name,
          balance: nativeBalanceEther,
          contractAddress: '',
          decimals: networkProvider.currentNetwork.nativeCurrency.decimals,
          usdValue: 0.0, // TODO: Implement price fetching
        ),
      ];

      // Get MCRT token balance if contract address exists
      final mcrtAddress =
          AppConstants.mcrtTokenAddresses[networkProvider.currentNetworkId];
      if (mcrtAddress != null && mcrtAddress.isNotEmpty) {
        // TODO: Implement ERC-20 token balance fetching
        balances.add(
          TokenBalance(
            symbol: 'MCRT',
            name: 'MagicCraft Token',
            balance: '0',
            contractAddress: mcrtAddress,
            decimals: 18,
            usdValue: 0.0,
          ),
        );
      }

      _tokenBalances = balances;
      notifyListeners();
    } finally {
      client.dispose();
    }
  }

  // Load recent transactions
  Future<void> _loadRecentTransactions(NetworkProvider networkProvider) async {
    // TODO: Implement transaction history fetching from blockchain explorer APIs
    // For now, return empty list
    _recentTransactions = [];
    notifyListeners();
  }

  // Send transaction
  Future<String?> sendTransaction({
    required String toAddress,
    required String amount,
    required NetworkProvider networkProvider,
    String? tokenContractAddress,
  }) async {
    if (_currentWallet == null) return null;

    try {
      _setLoading(true);
      _clearError();

      final client = Web3Client(
        networkProvider.currentNetwork.rpcUrl,
        Client(),
      );
      final credentials = _currentWallet!.credentials;

      String? txHash;

      if (tokenContractAddress == null || tokenContractAddress.isEmpty) {
        // Send native token
        final amountWei = WalletService.etherToWei(amount);
        txHash = await client.sendTransaction(
          credentials,
          Transaction(
            to: EthereumAddress.fromHex(toAddress),
            value: EtherAmount.fromBigInt(EtherUnit.wei, amountWei),
          ),
          chainId: networkProvider.currentNetwork.chainId,
        );
      } else {
        // TODO: Implement ERC-20 token transfer
      }

      client.dispose();
      return txHash;
    } catch (e) {
      _setError('Failed to send transaction: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Estimate gas for transaction
  Future<BigInt?> estimateGas({
    required String toAddress,
    required String amount,
    required NetworkProvider networkProvider,
    String? tokenContractAddress,
  }) async {
    if (_currentWallet == null) return null;

    try {
      final client = Web3Client(
        networkProvider.currentNetwork.rpcUrl,
        Client(),
      );

      BigInt gasEstimate;

      if (tokenContractAddress == null || tokenContractAddress.isEmpty) {
        // Estimate gas for native token transfer
        final amountWei = WalletService.etherToWei(amount);
        gasEstimate = await client.estimateGas(
          sender: _currentWallet!.ethereumAddress,
          to: EthereumAddress.fromHex(toAddress),
          value: EtherAmount.fromBigInt(EtherUnit.wei, amountWei),
        );
      } else {
        // TODO: Implement gas estimation for ERC-20 transfers
        gasEstimate = BigInt.from(21000); // Default gas limit
      }

      client.dispose();
      return gasEstimate;
    } catch (e) {
      return BigInt.from(21000); // Fallback gas limit
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
