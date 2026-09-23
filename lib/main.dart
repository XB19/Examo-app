import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ExamoApp());
}

class ExamoApp extends StatelessWidget {
  const ExamoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Examo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
