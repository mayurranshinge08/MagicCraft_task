import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magiccraft_wallet/screen/splash_screen.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/network_provider.dart';
import 'core/providers/wallet_provider.dart';
import 'core/theme/app_theme.dart';
import 'widgets/magical_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for magical theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1B2F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MagicCraftWallet());
}

class MagicCraftWallet extends StatelessWidget {
  const MagicCraftWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: MaterialApp(
        title: 'MagicCraft Wallet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MagicalBackground(child: SplashScreen()),
      ),
    );
  }
}
