import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_header.dart';
import '../root_shell.dart';

class RemediationScreen extends StatelessWidget {
  const RemediationScreen({super.key});

  static const _exercises = [
    ('Exercice guidé', 'Facile', '5 questions · avec aide', AppColors.ok600, Icons.edit_note_rounded),
    ('Exercice d\'application', 'Moyen', '6 questions · sans aide', Color(0xFFF5A623), Icons.edit_note_rounded),
    ('Questions d\'annales', 'Difficile', '8 questions · 2019 à 2024', AppColors.crim600, Icons.edit_note_rounded),
  ];

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
                    title: 'Révision ciblée',
                    actions: [CircleIconButton(icon: Icons.favorite_border_rounded, ghost: true, onPressed: () {})],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 2, 22, 16),
                    child: Row(
                      children: [
                        ProgressRing(
                          size: 96,
                          percent: 0.38,
                          progressColor: AppColors.crim600,
                          center: const Text('38%', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -1)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Pill(label: 'MATHÉMATIQUES', bg: Colors.white.withValues(alpha: .18), fg: Colors.white),
                              const SizedBox(height: 9),
                              const Text('Théorème\nde Thalès', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.25)),
                              Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: Text('Ton point faible n° 1 · 4 erreurs\nsur les 3 dernières épreuves',
                                    style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 11, height: 1.5)),
                              ),
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
                    color: AppColors.kx50,
                    borderColor: AppColors.kx100,
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Icon(Icons.import_contacts_rounded, color: AppColors.kx700, size: 17),
                          SizedBox(width: 8),
                          Text('LE COURS EN 3 POINTS', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.kx700, letterSpacing: .5)),
                        ]),
                        const SizedBox(height: 11),
                        _point('1', 'Thalès s\'utilise quand deux droites sont ', 'parallèles', ' dans un triangle.'),
                        _point('2', 'On écrit les rapports ', 'dans le même ordre', ' : petit sur grand des deux côtés.'),
                        _point('3', 'On termine toujours par un ', 'produit en croix', '.'),
                      ],
                    ),
                  ),
                  SectionHeader(title: 'Ton entraînement', action: '19 questions'),
                  for (final e in _exercises) _exerciseTile(context, e),
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: AppColors.kx100, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.play_arrow_rounded, color: AppColors.kx700, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Explication audio du chapitre', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                              SizedBox(height: 3),
                              Text('4 min · écoutable hors connexion', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.file_download_outlined, color: AppColors.kx600),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: AppColors.line)), boxShadow: [
            BoxShadow(color: AppColors.kx900.withValues(alpha: .1), blurRadius: 26, offset: const Offset(0, -8)),
          ]),
          child: AppButton(
            label: 'Lancer l\'entraînement · 5 questions',
            icon: Icons.track_changes_rounded,
            height: 50,
            onPressed: () => RootShell.openTab(context, RootShell.annalesTab),
          ),
        ),
      ),
    );
  }

  Widget _point(String n, String a, String b, String c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13.5, height: 1.75, color: AppColors.ink2),
          children: [
            TextSpan(text: '$n. ', style: const TextStyle(color: AppColors.kx700, fontWeight: FontWeight.w800)),
            TextSpan(text: a),
            TextSpan(text: b, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
            TextSpan(text: c),
          ],
        ),
      ),
    );
  }

  Widget _exerciseTile(BuildContext context, (String, String, String, Color, IconData) e) {
    final (title, level, sub, color, icon) = e;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => RootShell.openTab(context, RootShell.annalesTab),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      Pill(label: level, bg: color.withValues(alpha: .1), fg: color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(sub, style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8C4D8)),
          ],
        ),
      ),
    );
  }
}
