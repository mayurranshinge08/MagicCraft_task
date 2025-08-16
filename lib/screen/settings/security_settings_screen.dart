import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/magic_app_bar.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MagicAppBar(title: 'Security Settings'),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.magicGradient),
        child: const SafeArea(
          child: Center(
            child: Text(
              'Security Settings\n(Coming Soon)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
