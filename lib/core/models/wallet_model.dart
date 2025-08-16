import 'package:web3dart/web3dart.dart';

class WalletModel {
  final String address;
  final String privateKey;
  final String mnemonic;
  final DateTime createdAt;
  final String name;

  WalletModel({
    required this.address,
    required this.privateKey,
    required this.mnemonic,
    required this.createdAt,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'privateKey': privateKey,
      'mnemonic': mnemonic,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      address: json['address'],
      privateKey: json['privateKey'],
      mnemonic: json['mnemonic'],
      createdAt: DateTime.parse(json['createdAt']),
      name: json['name'],
    );
  }

  EthereumAddress get ethereumAddress => EthereumAddress.fromHex(address);

  EthPrivateKey get credentials => EthPrivateKey.fromHex(privateKey);
}

class TokenBalance {
  final String symbol;
  final String name;
  final String balance;
  final String contractAddress;
  final int decimals;
  final double usdValue;

  TokenBalance({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.contractAddress,
    required this.decimals,
    required this.usdValue,
  });

  String get formattedBalance {
    final value = double.tryParse(balance) ?? 0.0;
    if (value == 0) return '0';
    if (value < 0.001) return '<0.001';
    return value.toStringAsFixed(3);
  }

  String get formattedUsdValue {
    if (usdValue < 0.01) return '<\$0.01';
    return '\$${usdValue.toStringAsFixed(2)}';
  }
}

class TransactionModel {
  final String hash;
  final String from;
  final String to;
  final String value;
  final String symbol;
  final DateTime timestamp;
  final bool isIncoming;
  final String status;
  final String? gasUsed;
  final String? gasPrice;

  TransactionModel({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.symbol,
    required this.timestamp,
    required this.isIncoming,
    required this.status,
    this.gasUsed,
    this.gasPrice,
  });

  String get formattedValue {
    final val = double.tryParse(value) ?? 0.0;
    return val.toStringAsFixed(4);
  }

  String get shortHash {
    if (hash.length < 10) return hash;
    return '${hash.substring(0, 6)}...${hash.substring(hash.length - 4)}';
  }

  String get shortAddress {
    final addr = isIncoming ? from : to;
    if (addr.length < 10) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }
}
