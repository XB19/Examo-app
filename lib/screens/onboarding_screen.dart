import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/buttons.dart';
import '../widgets/examo_logo.dart';
import '../widgets/header_decoration.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _next(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: AppColors.gradient),
              child: Stack(
                children: [
                  const HeaderDecoration(),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const ExamoBrand(iconSize: 23, fontSize: 19),
                              GestureDetector(
                                onTap: () => _next(context),
                                child: Text('Passer',
                                    style: TextStyle(color: Colors.white.withValues(alpha: .72), fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .3), blurRadius: 44, offset: const Offset(0, 20))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Container(
                                  color: const Color(0xFFEEF2F9),
                                  child: const Icon(Icons.menu_book_rounded, size: 90, color: AppColors.kx300),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.fromLTRB(26, 24, 26, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 22, height: 6, decoration: BoxDecoration(color: AppColors.kx700, borderRadius: BorderRadius.circular(99))),
                      const SizedBox(width: 6),
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(99))),
                      const SizedBox(width: 6),
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(99))),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text('Comprends\npourquoi tu t\'es trompé',
                      style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -0.9, height: 1.2)),
                  const SizedBox(height: 12),
                  Text(
                    'Traite de vraies épreuves du CEPD, du BEPC et du BAC. Réponds au clavier ou photographie ton cahier. Pour chaque erreur, Examo t\'explique simplement, à l\'écrit ou à voix haute.',
                    style: TextStyle(fontSize: 14, color: AppColors.ink2, height: 1.55, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _feature(Icons.camera_alt_outlined, 'Au clavier ou en photo'),
                      const SizedBox(width: 18),
                      _feature(Icons.wifi_off_rounded, 'Hors connexion'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(width: 118, child: AppButton(label: 'Retour', variant: AppButtonVariant.outline, onPressed: () {})),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Continuer',
                          icon: Icons.arrow_forward_rounded,
                          iconTrailing: true,
                          onPressed: () => _next(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String label) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.kx700),
          const SizedBox(width: 7),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink2), maxLines: 2),
          ),
        ],
      ),
    );
  }
}
