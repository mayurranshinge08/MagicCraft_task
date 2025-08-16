import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/magic_button.dart';
import 'create_wallet_screen.dart';
import 'import_wallet_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Magic Crystal Logo
                        Container(
                          width: 120,
                          height: 100,
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

                        // Welcome Text
                        Text(
                          'Welcome to',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'MagicCraft Wallet',
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(
                                color: AppTheme.shimmeringGold,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          'Your gateway to the magical world of decentralized finance',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white60, height: 1.5),
                        ),

                        const Spacer(flex: 3),

                        // Feature Cards
                        _buildFeatureCard(
                          icon: Icons.security,
                          title: 'Secure & Non-Custodial',
                          description:
                              'Your keys, your crypto. Complete control over your assets.',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          icon: Icons.speed,
                          title: 'Multi-Chain Support',
                          description:
                              'Access Ethereum, BSC, and Polygon networks seamlessly.',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          icon: Icons.fingerprint,
                          title: 'Biometric Security',
                          description:
                              'Unlock your wallet with fingerprint or face recognition.',
                        ),

                        const Spacer(flex: 2),

                        // Action Buttons
                        Column(
                          children: [
                            MagicButton(
                              text: 'Create New Wallet',
                              onPressed: () => _navigateToCreateWallet(),
                              isPrimary: true,
                            ),
                            const SizedBox(height: 16),
                            MagicButton(
                              text: 'Import Existing Wallet',
                              onPressed: () => _navigateToImportWallet(),
                              isPrimary: false,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.arcanePurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.shimmeringGold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateWallet() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateWalletScreen()));
  }

  void _navigateToImportWallet() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ImportWalletScreen()));
  }
}
