import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/network_provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/services/wallet_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/magic_app_bar.dart';
import '../../widgets/magic_button.dart';

class TransactionConfirmationScreen extends StatefulWidget {
  final String recipientAddress;
  final String amount;
  final String tokenSymbol;
  final String? tokenContractAddress;
  final BigInt? estimatedGas;
  final String? note;

  const TransactionConfirmationScreen({
    super.key,
    required this.recipientAddress,
    required this.amount,
    required this.tokenSymbol,
    this.tokenContractAddress,
    this.estimatedGas,
    this.note,
  });

  @override
  State<TransactionConfirmationScreen> createState() =>
      _TransactionConfirmationScreenState();
}

class _TransactionConfirmationScreenState
    extends State<TransactionConfirmationScreen> {
  bool _isConfirming = false;

  Future<void> _confirmTransaction() async {
    setState(() => _isConfirming = true);

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final networkProvider = Provider.of<NetworkProvider>(
      context,
      listen: false,
    );

    final txHash = await walletProvider.sendTransaction(
      toAddress: widget.recipientAddress,
      amount: widget.amount,
      networkProvider: networkProvider,
      tokenContractAddress: widget.tokenContractAddress,
    );

    setState(() => _isConfirming = false);

    if (txHash != null && mounted) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildSuccessDialog(txHash, networkProvider),
      );
    } else if (mounted) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(walletProvider.error ?? 'Transaction failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSuccessDialog(String txHash, NetworkProvider networkProvider) {
    return AlertDialog(
      backgroundColor: AppTheme.darkPurple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.arcanePurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.goldGradient,
            ),
            child: const Icon(
              Icons.check,
              size: 40,
              color: AppTheme.midnightBlue,
            ),
          ),
          const SizedBox(height: 24),

          // Success Message
          Text(
            'Transaction Sent!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Your transaction has been broadcast to the network.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),

          // Transaction Hash
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.midnightBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Hash: ${WalletService.formatAddress(txHash)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    // TODO: Open in explorer
                  },
                  child: const Text(
                    'View in Explorer',
                    style: TextStyle(color: AppTheme.shimmeringGold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.arcanePurple,
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MagicAppBar(title: 'Confirm Transaction'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction Summary Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.darkPurple.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.arcanePurple.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Amount
                              Text(
                                '${widget.amount} ${widget.tokenSymbol}',
                                style: Theme.of(
                                  context,
                                ).textTheme.displaySmall?.copyWith(
                                  color: AppTheme.shimmeringGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sending to',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 16),

                              // Recipient Address
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.midnightBlue.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.account_circle,
                                      color: AppTheme.shimmeringGold,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        WalletService.formatAddress(
                                          widget.recipientAddress,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Transaction Details
                        _buildDetailSection('Transaction Details', [
                          _buildDetailRow(
                            'Network',
                            Provider.of<NetworkProvider>(
                              context,
                            ).currentNetwork.name,
                          ),
                          _buildDetailRow('Token', widget.tokenSymbol),
                          _buildDetailRow(
                            'Amount',
                            '${widget.amount} ${widget.tokenSymbol}',
                          ),
                          if (widget.estimatedGas != null)
                            _buildDetailRow(
                              'Estimated Gas',
                              '${WalletService.weiToEther(widget.estimatedGas!)} ETH',
                            ),
                          if (widget.note != null && widget.note!.isNotEmpty)
                            _buildDetailRow('Note', widget.note!),
                        ]),
                        const SizedBox(height: 24),

                        // Security Warning
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
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Double-check everything',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Transactions cannot be reversed. Make sure the recipient address and amount are correct.',
                                      style: TextStyle(
                                        color: Colors.orange.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Confirm Button
                MagicButton(
                  text: 'Confirm & Send',
                  onPressed: _isConfirming ? null : _confirmTransaction,
                  isLoading: _isConfirming,
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.shimmeringGold,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
