import 'package:flutter/material.dart';
import 'package:conseilbox/features/splash/splash_screen.dart';
import 'config/app_theme.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const ConseilBoxApp());
}

class ConseilBoxApp extends StatelessWidget {
  const ConseilBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConseilBox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}