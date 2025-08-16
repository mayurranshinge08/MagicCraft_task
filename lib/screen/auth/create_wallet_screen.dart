import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/providers/wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/magic_app_bar.dart';
import '../../widgets/magic_button.dart';
import 'setup_passcode_screen.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final _nameController = TextEditingController(text: 'My Wallet');
  String? _generatedMnemonic;
  bool _isGenerating = false;
  bool _isMnemonicVisible = false;
  bool _hasConfirmedBackup = false;

  @override
  void initState() {
    super.initState();
    _generateMnemonic();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _generateMnemonic() async {
    setState(() => _isGenerating = true);

    // Simulate generation delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    // For demo purposes, we'll generate a mnemonic here
    // In production, this would be done securely
    _generatedMnemonic =
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

    setState(() => _isGenerating = false);
  }

  Future<void> _createWallet() async {
    if (_generatedMnemonic == null || !_hasConfirmedBackup) return;

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final success = await walletProvider.createWallet(
      name: _nameController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => SetupPasscodeScreen(
                mnemonic: _generatedMnemonic!,
                isImport: false,
              ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(walletProvider.error ?? 'Failed to create wallet'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyMnemonic() {
    if (_generatedMnemonic != null) {
      Clipboard.setData(ClipboardData(text: _generatedMnemonic!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recovery phrase copied to clipboard'),
          backgroundColor: AppTheme.arcanePurple,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MagicAppBar(title: 'Create Wallet'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Name Input
                Text(
                  'Wallet Name',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.shimmeringGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter wallet name',
                  ),
                ),
                const SizedBox(height: 32),

                // Recovery Phrase Section
                Text(
                  'Recovery Phrase',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.shimmeringGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Write down these 12 words in the exact order. This is the only way to recover your wallet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Mnemonic Display
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.darkPurple.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.arcanePurple.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child:
                        _isGenerating
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.shimmeringGold,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Generating secure recovery phrase...',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            )
                            : Column(
                              children: [
                                // Visibility Toggle
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recovery Phrase',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: _copyMnemonic,
                                          icon: const Icon(
                                            Icons.copy,
                                            color: AppTheme.shimmeringGold,
                                            size: 20,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _isMnemonicVisible =
                                                  !_isMnemonicVisible;
                                            });
                                          },
                                          icon: Icon(
                                            _isMnemonicVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: AppTheme.shimmeringGold,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Mnemonic Words Grid
                                Expanded(
                                  child:
                                      _isMnemonicVisible &&
                                              _generatedMnemonic != null
                                          ? _buildMnemonicGrid(
                                            _generatedMnemonic!.split(' '),
                                          )
                                          : Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: AppTheme.midnightBlue
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.visibility_off,
                                                    color: Colors.white38,
                                                    size: 48,
                                                  ),
                                                  SizedBox(height: 16),
                                                  Text(
                                                    'Tap the eye icon to reveal\nyour recovery phrase',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white38,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                ),
                              ],
                            ),
                  ),
                ),

                const SizedBox(height: 24),

                // Backup Confirmation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _hasConfirmedBackup
                              ? AppTheme.shimmeringGold.withOpacity(0.5)
                              : AppTheme.arcanePurple.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _hasConfirmedBackup,
                        onChanged: (value) {
                          setState(() {
                            _hasConfirmedBackup = value ?? false;
                          });
                        },
                        activeColor: AppTheme.shimmeringGold,
                        checkColor: AppTheme.midnightBlue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'I have safely backed up my recovery phrase',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Create Button
                Consumer<WalletProvider>(
                  builder: (context, walletProvider, child) {
                    return MagicButton(
                      text: 'Create Wallet',
                      onPressed:
                          _hasConfirmedBackup && !_isGenerating
                              ? _createWallet
                              : null,
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
    );
  }

  Widget _buildMnemonicGrid(List<String> words) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: words.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.midnightBlue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.arcanePurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: AppTheme.shimmeringGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  words[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
