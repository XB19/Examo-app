import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/progress_store.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Charge l'historique local (progression, séries) avant le premier écran ;
  // la coupure est imperceptible, masquée par l'écran de démarrage.
  await ProgressStore.instance.load();
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
