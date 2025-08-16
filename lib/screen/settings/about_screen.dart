import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/magic_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MagicAppBar(title: 'About'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shimmeringGold.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 60,
                    color: AppTheme.midnightBlue,
                  ),
                ),
                const SizedBox(height: 32),

                // App Info
                Text(
                  'MagicCraft Wallet',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.shimmeringGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 32),

                // Description
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.darkPurple.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.arcanePurple.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'MagicCraft Wallet is a secure, non-custodial EVM wallet that puts you in complete control of your digital assets. Built with cutting-edge security features and a magical user experience.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Features
                Text(
                  'Features',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildFeatureItem(
                  icon: Icons.security,
                  title: 'Secure & Non-Custodial',
                  description: 'Your keys, your crypto',
                ),
                _buildFeatureItem(
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  description: 'Unlock with fingerprint or face',
                ),
                _buildFeatureItem(
                  icon: Icons.language,
                  title: 'Multi-Chain Support',
                  description: 'Ethereum, BSC, and Polygon',
                ),
                _buildFeatureItem(
                  icon: Icons.qr_code,
                  title: 'QR Code Support',
                  description: 'Easy sending and receiving',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.arcanePurple.withOpacity(0.3),
            ),
            child: Icon(icon, color: AppTheme.shimmeringGold, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
