import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/gradient_header.dart';

/// Le téléchargement d'annales pour un usage hors connexion n'est pas encore
/// implémenté côté app (ça suppose de mettre en cache le contenu et les
/// images des sujets) : on l'annonce clairement plutôt que d'inventer des
/// pourcentages de téléchargement.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: Column(
                children: [
                  const HeaderNavBar(title: 'Hors connexion'),
                  Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), border: Border.all(color: Colors.white.withValues(alpha: .22)), borderRadius: BorderRadius.circular(22)),
                        child: const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 13),
                      const Text('Bientôt disponible', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                        child: Text('Télécharger tes annales pour t\'entraîner sans réseau est en préparation.',
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 12, height: 1.5)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Center(
                  child: AppCard(
                    color: AppColors.kx50,
                    borderColor: AppColors.kx100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.wifi_rounded, color: AppColors.kx700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Pour l\'instant, Examo a besoin d\'une connexion internet pour afficher les annales et corriger tes copies.',
                            style: TextStyle(fontSize: 12.5, color: AppColors.ink2, height: 1.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
