import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/passcode_input.dart';
import '../main/main_screen.dart';

class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showBiometricPrompt = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _tryBiometricAuth();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  Future<void> _tryBiometricAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isBiometricEnabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      final success = await authProvider.authenticateWithBiometrics();

      if (success && mounted) {
        _navigateToMain();
      } else {
        setState(() {
          _showBiometricPrompt = false;
        });
      }
    } else {
      setState(() {
        _showBiometricPrompt = false;
      });
    }
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  Future<void> _onPasscodeCompleted(String passcode) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyPasscode(passcode);

    if (success) {
      _navigateToMain();
    } else {
      // Show error and clear passcode input
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid passcode. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo
                      Container(
                        width: 100,
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
                          size: 50,
                          color: AppTheme.midnightBlue,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Welcome Back Text
                      Text(
                        'Welcome Back',
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(
                          color: AppTheme.shimmeringGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unlock your MagicCraft wallet',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                      ),

                      const Spacer(flex: 2),

                      // Biometric Prompt or Passcode Input
                      if (_showBiometricPrompt &&
                          authProvider.isBiometricEnabled)
                        _buildBiometricPrompt(authProvider)
                      else
                        _buildPasscodeInput(),

                      const Spacer(flex: 3),

                      // Switch to Passcode Button (if biometric is available)
                      if (authProvider.isBiometricEnabled &&
                          _showBiometricPrompt)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _showBiometricPrompt = false;
                            });
                          },
                          child: Text(
                            'Use Passcode Instead',
                            style: TextStyle(
                              color: AppTheme.shimmeringGold.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
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
    );
  }

  Widget _buildBiometricPrompt(AuthProvider authProvider) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.arcanePurple.withOpacity(0.3),
            border: Border.all(
              color: AppTheme.shimmeringGold.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Icon(
            authProvider.availableBiometric == BiometricType.face
                ? Icons.face
                : Icons.fingerprint,
            size: 40,
            color: AppTheme.shimmeringGold,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Touch ${authProvider.biometricDisplayName}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use your ${authProvider.biometricDisplayName.toLowerCase()} to unlock',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white60),
        ),
        const SizedBox(height: 32),
        if (authProvider.isLoading)
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.shimmeringGold),
          ),
      ],
    );
  }

  Widget _buildPasscodeInput() {
    return Column(
      children: [
        Text(
          'Enter Passcode',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Enter your 6-digit passcode',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 48),
        PasscodeInput(length: 6, onCompleted: _onPasscodeCompleted),
      ],
    );
  }
}
