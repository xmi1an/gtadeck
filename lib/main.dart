import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GTADeckApp(),
    ),
  );
}

class GTADeckApp extends StatelessWidget {
  const GTADeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GTADeck',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
