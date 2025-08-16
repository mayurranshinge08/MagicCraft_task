import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/wallet_provider.dart';
import '../../core/services/wallet_service.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/magic_app_bar.dart';
import '../../widgets/magic_button.dart';
import 'setup_passcode_screen.dart';

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({super.key});

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  final _nameController = TextEditingController(text: 'Imported Wallet');
  final _mnemonicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isMnemonicValid = false;

  @override
  void initState() {
    super.initState();
    _mnemonicController.addListener(_validateMnemonic);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mnemonicController.dispose();
    super.dispose();
  }

  void _validateMnemonic() {
    final mnemonic = _mnemonicController.text.trim();
    final isValid = WalletService.validateMnemonic(mnemonic);

    if (isValid != _isMnemonicValid) {
      setState(() {
        _isMnemonicValid = isValid;
      });
    }
  }

  Future<void> _importWallet() async {
    if (!_formKey.currentState!.validate() || !_isMnemonicValid) return;

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final success = await walletProvider.importWallet(
      _mnemonicController.text.trim(),
      name: _nameController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => SetupPasscodeScreen(
                mnemonic: _mnemonicController.text.trim(),
                isImport: true,
              ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(walletProvider.error ?? 'Failed to import wallet'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MagicAppBar(title: 'Import Wallet'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkPurple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.arcanePurple.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.shimmeringGold,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Enter your 12-word recovery phrase to restore your existing wallet.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Wallet Name Input
                  Text(
                    'Wallet Name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.shimmeringGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter wallet name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a wallet name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Recovery Phrase Input
                  Text(
                    'Recovery Phrase',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.shimmeringGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkPurple.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              _isMnemonicValid
                                  ? AppTheme.shimmeringGold.withOpacity(0.5)
                                  : AppTheme.arcanePurple.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Status Indicator
                          Row(
                            children: [
                              Icon(
                                _isMnemonicValid
                                    ? Icons.check_circle
                                    : Icons.error_outline,
                                color:
                                    _isMnemonicValid
                                        ? AppTheme.shimmeringGold
                                        : Colors.white38,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isMnemonicValid
                                    ? 'Valid recovery phrase'
                                    : 'Enter your 12-word recovery phrase',
                                style: TextStyle(
                                  color:
                                      _isMnemonicValid
                                          ? AppTheme.shimmeringGold
                                          : Colors.white60,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Mnemonic Input
                          Expanded(
                            child: TextFormField(
                              controller: _mnemonicController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                hintText:
                                    'word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12',
                                hintStyle: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your recovery phrase';
                                }
                                if (!WalletService.validateMnemonic(
                                  value.trim(),
                                )) {
                                  return 'Invalid recovery phrase';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Import Button
                  Consumer<WalletProvider>(
                    builder: (context, walletProvider, child) {
                      return MagicButton(
                        text: 'Import Wallet',
                        onPressed: _isMnemonicValid ? _importWallet : null,
                        isLoading: walletProvider.isLoading,
                        isPrimary: true,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
