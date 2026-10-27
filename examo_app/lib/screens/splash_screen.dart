import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/examo_logo.dart';
import '../widgets/header_decoration.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1600), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _goNext,
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradient),
          child: Stack(
            children: [
              const HeaderDecoration(),
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withValues(alpha: .22)),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 44, offset: const Offset(0, 18))],
                        ),
                        alignment: Alignment.center,
                        child: const ExamoIcon(size: 62),
                      ),
                      const SizedBox(height: 24),
                      const Text('Examo',
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.4)),
                      const SizedBox(height: 9),
                      Text('Tes annales, corrigées et expliquées',
                          style: TextStyle(fontSize: 13.5, color: Colors.white.withValues(alpha: .84), fontWeight: FontWeight.w500)),
                      const SizedBox(height: 44),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(AppColors.gold500),
                          const SizedBox(width: 7),
                          _dot(Colors.white.withValues(alpha: .45)),
                          const SizedBox(width: 7),
                          _dot(Colors.white.withValues(alpha: .25)),
                        ],
                      ),
                      const Spacer(flex: 4),
                      const Text('CEPD · BEPC · BACCALAURÉAT',
                          style: TextStyle(fontSize: 10, letterSpacing: 2.4, color: Colors.white54, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      Text('GRATUIT · POUR TOUS LES ÉLÈVES',
                          style: TextStyle(fontSize: 12.5, letterSpacing: .6, color: Colors.white.withValues(alpha: .92), fontWeight: FontWeight.w700)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color c) => Container(width: 9, height: 9, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}
