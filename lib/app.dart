import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_settings.dart';
import 'screens/home_screen.dart';

class PomotomoApp extends StatelessWidget {
  const PomotomoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<AppSettings>().accentColor;

    return MaterialApp(
      title: 'Pomotomo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        colorSchemeSeed: accent,
      ),
      home: const HomeScreen(),
    );
  }
}