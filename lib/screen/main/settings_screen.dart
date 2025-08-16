import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/network_provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/magic_app_bar.dart';
import '../settings/about_screen.dart';
import '../settings/network_management_screen.dart';
import '../settings/security_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MagicAppBar(title: 'Settings'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Info Card
                Consumer<WalletProvider>(
                  builder: (context, walletProvider, child) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.darkPurple.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.arcanePurple.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.goldGradient,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              size: 30,
                              color: AppTheme.midnightBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'My Wallet',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  walletProvider.formattedAddress,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Settings Sections
                _buildSettingsSection(context, 'Network & Connection', [
                  _buildSettingsItem(
                    context,
                    icon: Icons.language,
                    title: 'Network Management',
                    subtitle: 'Manage networks and custom RPCs',
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => const NetworkManagementScreen(),
                          ),
                        ),
                  ),
                  Consumer<NetworkProvider>(
                    builder: (context, networkProvider, child) {
                      return _buildSettingsItem(
                        context,
                        icon: Icons.wifi,
                        title: 'Current Network',
                        subtitle: networkProvider.currentNetwork.name,
                        trailing: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getNetworkColor(
                              networkProvider.currentNetworkId,
                            ),
                          ),
                        ),
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const NetworkManagementScreen(),
                              ),
                            ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSettingsSection(context, 'Security', [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return _buildSettingsItem(
                        context,
                        icon: Icons.fingerprint,
                        title: 'Biometric Authentication',
                        subtitle:
                            authProvider.isBiometricEnabled
                                ? 'Enabled'
                                : 'Disabled',
                        trailing: Switch(
                          value: authProvider.isBiometricEnabled,
                          onChanged:
                              authProvider.availableBiometric !=
                                      BiometricType.none
                                  ? (value) =>
                                      authProvider.setBiometricEnabled(value)
                                  : null,
                          activeColor: AppTheme.shimmeringGold,
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.security,
                    title: 'Security Settings',
                    subtitle: 'Manage passcode and security options',
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => const SecuritySettingsScreen(),
                          ),
                        ),
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSettingsSection(context, 'Wallet Management', [
                  _buildSettingsItem(
                    context,
                    icon: Icons.backup,
                    title: 'Backup Wallet',
                    subtitle: 'View recovery phrase',
                    onTap: () {
                      // TODO: Show recovery phrase with authentication
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feature coming soon'),
                          backgroundColor: AppTheme.arcanePurple,
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.delete_forever,
                    title: 'Reset Wallet',
                    subtitle: 'Delete wallet and start over',
                    isDestructive: true,
                    onTap: () => _showResetWalletDialog(context),
                  ),
                ]),
                const SizedBox(height: 24),

                _buildSettingsSection(context, 'About', [
                  _buildSettingsItem(
                    context,
                    icon: Icons.info,
                    title: 'About MagicCraft',
                    subtitle: 'Version, terms, and support',
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.shimmeringGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.darkPurple.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.arcanePurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              isDestructive
                  ? Colors.red.withOpacity(0.2)
                  : AppTheme.arcanePurple.withOpacity(0.3),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppTheme.shimmeringGold,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive ? Colors.red.withOpacity(0.7) : Colors.white70,
        ),
      ),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: Colors.white38),
      onTap: onTap,
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

  void _showResetWalletDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.darkPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppTheme.arcanePurple.withOpacity(0.3),
                width: 1,
              ),
            ),
            title: const Text(
              'Reset Wallet',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'This will permanently delete your wallet and all associated data. Make sure you have backed up your recovery phrase.\n\nThis action cannot be undone.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final walletProvider = Provider.of<WalletProvider>(
                    context,
                    listen: false,
                  );
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );

                  await walletProvider.deleteWallet();
                  await authProvider.logout();

                  // Navigate back to onboarding
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
                child: const Text(
                  'Reset Wallet',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
