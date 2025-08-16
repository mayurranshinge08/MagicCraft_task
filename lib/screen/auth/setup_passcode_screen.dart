import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/magic_app_bar.dart';
import '../../widgets/magic_button.dart';
import '../../widgets/passcode_input.dart';
import '../main/main_screen.dart';

class SetupPasscodeScreen extends StatefulWidget {
  final String mnemonic;
  final bool isImport;

  const SetupPasscodeScreen({
    super.key,
    required this.mnemonic,
    required this.isImport,
  });

  @override
  State<SetupPasscodeScreen> createState() => _SetupPasscodeScreenState();
}

class _SetupPasscodeScreenState extends State<SetupPasscodeScreen> {
  String _passcode = '';
  String _confirmPasscode = '';
  bool _isConfirming = false;
  bool _enableBiometric = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: const MagicAppBar(title: 'Setup Security'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),

                // Security Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shimmeringGold.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 40,
                    color: AppTheme.midnightBlue,
                  ),
                ),
                const SizedBox(height: 32),

                // Title and Description
                Text(
                  _isConfirming ? 'Confirm Passcode' : 'Create Passcode',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isConfirming
                      ? 'Enter your passcode again to confirm'
                      : 'Create a 6-digit passcode to secure your wallet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),

                const Spacer(),

                // Passcode Input
                PasscodeInput(
                  length: 6,
                  onCompleted: _onPasscodeCompleted,
                  onChanged: (value) {
                    if (_isConfirming) {
                      _confirmPasscode = value;
                    } else {
                      _passcode = value;
                    }
                  },
                ),

                const Spacer(),

                // Biometric Option (only show when not confirming and biometric is available)
                if (!_isConfirming &&
                    authProvider.availableBiometric != BiometricType.none)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
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
                        Icon(
                          authProvider.availableBiometric == BiometricType.face
                              ? Icons.face
                              : Icons.fingerprint,
                          color: AppTheme.shimmeringGold,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enable ${authProvider.biometricDisplayName}',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Use ${authProvider.biometricDisplayName.toLowerCase()} to unlock your wallet',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _enableBiometric,
                          onChanged: (value) {
                            setState(() {
                              _enableBiometric = value;
                            });
                          },
                          activeColor: AppTheme.shimmeringGold,
                          activeTrackColor: AppTheme.shimmeringGold.withOpacity(
                            0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPasscodeCompleted(String passcode) async {
    if (!_isConfirming) {
      // First passcode entry
      setState(() {
        _isConfirming = true;
      });
    } else {
      // Confirming passcode
      if (_passcode == _confirmPasscode) {
        await _setupSecurity();
      } else {
        // Passcodes don't match
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passcodes do not match. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isConfirming = false;
          _passcode = '';
          _confirmPasscode = '';
        });
      }
    }
  }

  Future<void> _setupSecurity() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Setup passcode
    final passcodeSuccess = await authProvider.setupPasscode(_passcode);
    if (!passcodeSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to setup passcode'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Setup biometric if enabled
    if (_enableBiometric) {
      await authProvider.setBiometricEnabled(true);
    }

    // Navigate to main screen
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    }
  }
}
