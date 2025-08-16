class AppConstants {
  // App Info
  static const String appName = 'MagicCraft Wallet';
  static const String appVersion = '1.0.0';

  // Supported Networks
  static const Map<String, NetworkConfig> supportedNetworks = {
    'ethereum': NetworkConfig(
      name: 'Ethereum',
      chainId: 1,
      rpcUrl: 'https://mainnet.infura.io/v3/',
      explorerUrl: 'https://etherscan.io',
      nativeCurrency: CurrencyConfig(
        name: 'Ethereum',
        symbol: 'ETH',
        decimals: 18,
      ),
    ),
    'bsc': NetworkConfig(
      name: 'Binance Smart Chain',
      chainId: 56,
      rpcUrl: 'https://bsc-dataseed1.binance.org/',
      explorerUrl: 'https://bscscan.com',
      nativeCurrency: CurrencyConfig(name: 'BNB', symbol: 'BNB', decimals: 18),
    ),
    'polygon': NetworkConfig(
      name: 'Polygon',
      chainId: 137,
      rpcUrl: 'https://polygon-rpc.com/',
      explorerUrl: 'https://polygonscan.com',
      nativeCurrency: CurrencyConfig(
        name: 'MATIC',
        symbol: 'MATIC',
        decimals: 18,
      ),
    ),
  };

  // MCRT Token Contract Addresses
  static const Map<String, String> mcrtTokenAddresses = {
    'ethereum': '0x...', // Replace with actual MCRT contract address
    'bsc': '0x...', // Replace with actual MCRT contract address
    'polygon': '0x...', // Replace with actual MCRT contract address
  };

  // Security
  static const int mnemonicWordCount = 12;
  static const String secureStorageWalletKey = 'magiccraft_wallet';
  static const String secureStoragePasscodeKey = 'magiccraft_passcode';

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const int transactionHistoryLimit = 5;
}

class NetworkConfig {
  final String name;
  final int chainId;
  final String rpcUrl;
  final String explorerUrl;
  final CurrencyConfig nativeCurrency;

  const NetworkConfig({
    required this.name,
    required this.chainId,
    required this.rpcUrl,
    required this.explorerUrl,
    required this.nativeCurrency,
  });
}

class CurrencyConfig {
  final String name;
  final String symbol;
  final int decimals;

  const CurrencyConfig({
    required this.name,
    required this.symbol,
    required this.decimals,
  });
}
