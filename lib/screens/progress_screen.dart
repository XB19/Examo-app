import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_header.dart';
import 'remediation_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

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
                  HeaderNavBar(
                    title: 'Ma progression',
                    showBack: false,
                    actions: [
                      CircleIconButton(icon: Icons.calendar_today_outlined, ghost: true, onPressed: () {}),
                      const SizedBox(width: 4),
                      CircleIconButton(icon: Icons.settings_outlined, ghost: true, onPressed: () {}),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 2, 22, 0),
                    child: Row(
                      children: [
                        ProgressRing(
                          size: 104,
                          percent: 0.64,
                          center: const Text('64%', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -1)),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Préparation au BEPC', style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              const Text('Moyenne 11,4 / 20', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('18 épreuves · 24 h d\'entraînement', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 11, height: 1.5)),
                              ),
                              const SizedBox(height: 9),
                              Pill(label: '+ 1,8 ce mois', icon: Icons.trending_up_rounded, bg: AppColors.ok600.withValues(alpha: .3), fg: const Color(0xFFA7E7C9)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Évolution de ta moyenne', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            Text('6 dernières épreuves', style: TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('11,4', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.8)),
                                Row(children: const [
                                  Icon(Icons.trending_up_rounded, size: 12, color: AppColors.ok600),
                                  SizedBox(width: 3),
                                  Text('+ 2,1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ok600)),
                                ]),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Sparkline(values: const [0.35, 0.45, 0.22, 0.55, 0.66, 0.9]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SectionHeader(title: 'Niveau par matière', action: 'Détail'),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 4),
                    child: const MiniBarChart(data: [
                      ('Math', 72, AppColors.kx700),
                      ('Fr', 52, AppColors.kx700),
                      ('PC', 47, Color(0xFFE8A33C)),
                      ('SVT', 61, AppColors.kx700),
                      ('HG', 58, AppColors.kx700),
                      ('Ang', 66, AppColors.kx700),
                    ]),
                  ),
                  const SectionHeader(title: 'À travailler en priorité'),
                  _priorityTile(context, 'Théorème de Thalès', 'Mathématiques', 38, AppColors.crim600),
                  _priorityTile(context, 'Accord du participe passé', 'Français', 44, AppColors.crim600),
                  _priorityTile(context, 'Les circuits électriques', 'Physique-Chimie', 47, const Color(0xFFE8A33C)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priorityTile(BuildContext context, String title, String subject, int pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            MiniRing(percent: pct / 100, color: color, label: '$pct'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(subject, style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                ],
              ),
            ),
            SmallButton(label: 'Réviser', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RemediationScreen()))),
          ],
        ),
      ),
    );
  }
}
