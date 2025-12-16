import 'package:conseilbox/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Ajout de l'import pour Provider

import 'config/app_theme.dart';
import 'core/managers/favorites_manager.dart'; // Ajout de l'import pour FavoritesManager

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable verbose network image logging

  await initializeDateFormatting('fr_FR');
  Intl.defaultLocale = 'fr_FR';
  runApp(const ConseilBoxApp());
}

class ConseilBoxApp extends StatelessWidget {
  const ConseilBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesManager(),
      child: MaterialApp(
        title: 'ConseilBox',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
