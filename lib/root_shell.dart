import 'package:flutter/material.dart';
import 'screens/goals_screen.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_screen.dart';
import 'widgets/bottom_nav.dart';

/// Coquille principale avec navigation basse (Accueil / Annales / Progression /
/// Révisions / Profil), fidèle aux écrans 06, 07, 17, 19 et 22 de la maquette.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int index = 0;

  static const _screens = [
    HomeScreen(),
    LibraryScreen(),
    ProgressScreen(),
    GoalsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: ExamoBottomNav(currentIndex: index, onTap: (i) => setState(() => index = i)),
    );
  }
}
