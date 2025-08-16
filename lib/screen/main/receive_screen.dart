import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/network_provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/magic_app_bar.dart';
import '../../widgets/magic_button.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _includeAmount = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _generateQRData() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final address = walletProvider.walletAddress;

    if (!_includeAmount || _amountController.text.trim().isEmpty) {
      return address;
    }

    // Generate ethereum: URI with amount
    final amount = _amountController.text.trim();
    return 'ethereum:$address?value=${_etherToWei(amount)}';
  }

  String _etherToWei(String ether) {
    try {
      final etherAmount = double.parse(ether);
      final weiAmount = (etherAmount * 1e18).toInt();
      return weiAmount.toString();
    } catch (e) {
      return '0';
    }
  }

  void _copyAddress() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    Clipboard.setData(ClipboardData(text: walletProvider.walletAddress));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address copied to clipboard'),
        backgroundColor: AppTheme.arcanePurple,
      ),
    );
  }

  void _shareAddress() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );

    String shareText =
        'My ${networkProvider.currentNetwork.name} wallet address:\n${walletProvider.walletAddress}';

    if (_includeAmount && _amountController.text.trim().isNotEmpty) {
      shareText +=
          '\n\nRequested amount: ${_amountController.text.trim()} ${networkProvider.currentNetwork.nativeCurrency.symbol}';
    }

    if (_noteController.text.trim().isNotEmpty) {
      shareText += '\n\nNote: ${_noteController.text.trim()}';
    }

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MagicAppBar(title: 'Receive'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Consumer2<WalletProvider, NetworkProvider>(
              builder: (context, walletProvider, networkProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Network Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkPurple.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.arcanePurple.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getNetworkColor(
                                networkProvider.currentNetworkId,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _getNetworkInitial(
                                  networkProvider.currentNetworkId,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  networkProvider.currentNetwork.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Receiving ${networkProvider.currentNetwork.nativeCurrency.symbol}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.arcanePurple.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _generateQRData(),
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Wallet Address
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.darkPurple.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.arcanePurple.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: AppTheme.shimmeringGold,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Your Wallet Address',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.shimmeringGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.midnightBlue.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              walletProvider.walletAddress,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Request Amount (Optional)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.darkPurple.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.arcanePurple.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _includeAmount,
                                onChanged: (value) {
                                  setState(() {
                                    _includeAmount = value ?? false;
                                  });
                                },
                                activeColor: AppTheme.shimmeringGold,
                                checkColor: AppTheme.midnightBlue,
                              ),
                              Text(
                                'Request specific amount',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          if (_includeAmount) ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: _amountController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                hintText: '0.0',
                                suffixText:
                                    networkProvider
                                        .currentNetwork
                                        .nativeCurrency
                                        .symbol,
                                suffixStyle: const TextStyle(
                                  color: AppTheme.shimmeringGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _noteController,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Note (Optional)',
                                hintText: 'What is this payment for?',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: MagicButton(
                            text: 'Copy Address',
                            icon: Icons.copy,
                            onPressed: _copyAddress,
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MagicButton(
                            text: 'Share',
                            icon: Icons.share,
                            onPressed: _shareAddress,
                            isPrimary: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Warning Text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Only send ${networkProvider.currentNetwork.nativeCurrency.symbol} and ${networkProvider.currentNetwork.name} tokens to this address.',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _getNetworkColor(String networkId) {
    switch (networkId) {
      case 'ethereum':
        return const Color(0xFF627EEA);
      case 'bsc':
        return const Color(0xFFF3BA2F);
      case 'polygon':
        return const Color(0xFF8247E5);
      default:
        return AppTheme.arcanePurple;
    }
  }

  String _getNetworkInitial(String networkId) {
    switch (networkId) {
      case 'ethereum':
        return 'E';
      case 'bsc':
        return 'B';
      case 'polygon':
        return 'P';
      default:
        return 'N';
    }
  }
}
