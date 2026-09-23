import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _today = [
    (Icons.graphic_eq_rounded, AppColors.mathBlue, 'Ton explication est prête', 'Examo a enregistré l\'explication vocale de ta question 3 sur Thalès.', 'il y a 15 min'),
    (Icons.check_circle_outline_rounded, AppColors.svtGreen, 'Correction prête', 'Ton épreuve de mathématiques BEPC 2024 est corrigée : 13/20, 3 erreurs à revoir.', 'il y a 1 h'),
    (Icons.track_changes_rounded, AppColors.gold600, 'Objectif presque atteint', 'Encore une épreuve avant dimanche pour tenir ton objectif de la semaine.', 'il y a 4 h'),
  ];

  static const _earlier = [
    (Icons.import_contacts_rounded, AppColors.frenchPurple, 'Nouvelle annale disponible', 'BEPC 2025 — Sciences de la vie et de la terre vient d\'être ajoutée.', 'Hier'),
    (Icons.warning_amber_rounded, AppColors.crim600, 'Attention à Thalès', 'Tu as encore perdu des points sur ce chapitre. Une révision ciblée t\'attend.', 'Hier'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
              child: Column(
                children: [
                  HeaderNavBar(
                    title: 'Notifications',
                    actions: [CircleIconButton(icon: Icons.settings_outlined, ghost: true, onPressed: () {})],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(children: const [
                      AppChip(label: 'Toutes · 8', tone: ChipTone.darkOn, height: 32),
                      SizedBox(width: 8),
                      AppChip(label: 'Explications', tone: ChipTone.darkOff, height: 32),
                      SizedBox(width: 8),
                      AppChip(label: 'Résultats', tone: ChipTone.darkOff, height: 32),
                    ]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('AUJOURD\'HUI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: .7)),
                      const Text('Tout marquer comme lu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.kx700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final n in _today) _tile(n, unread: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('PLUS TÔT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: .7)),
                  ),
                  for (final n in _earlier) _tile(n, unread: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile((IconData, Color, String, String, String) n, {required bool unread}) {
    final (icon, color, title, desc, time) = n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        color: unread ? AppColors.kx50 : Colors.white,
        borderColor: unread ? AppColors.kx100 : AppColors.line,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700))),
                      if (unread) Padding(
                        padding: const EdgeInsets.only(top: 5, left: 6),
                        child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.gold500, shape: BoxShape.circle)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.ink2, height: 1.5)),
                  const SizedBox(height: 6),
                  Text(time, style: const TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
