import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_header.dart';
import 'correction_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  static const _parts = [
    ('Activités numériques', '5 / 6', 0.83, AppColors.ok600),
    ('Activités géométriques', '3 / 4', 0.75, AppColors.kx700),
    ('Problème', '1 / 2', 0.5, AppColors.crim600),
  ];

  static const _mistakes = [
    ('Q3', 'Théorème de Thalès', 'Rapport inversé'),
    ('Q7', 'Pythagore', 'Unité oubliée'),
    ('Q11', 'Équations', 'Erreur de signe'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: Column(
                children: [
                  HeaderNavBar(
                    title: 'Résultat',
                    showBack: false,
                    actions: [CircleIconButton(icon: Icons.ios_share_rounded, ghost: true, onPressed: () {})],
                  ),
                  const SizedBox(height: 4),
                  ProgressRing(
                    size: 132,
                    percent: 0.65,
                    strokeWidth: 12,
                    center: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('13', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
                        Text('sur 20', style: TextStyle(color: Color(0xC7FFFFFF), fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Bien joué, Koffi !', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                    child: Text('Tu as gagné 2 points par rapport à ta dernière épreuve de mathématiques.',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: .84), fontSize: 13, height: 1.5)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Pill(label: '+ 2 pts', icon: Icons.trending_up_rounded, bg: AppColors.ok600.withValues(alpha: .3), fg: const Color(0xFFA7E7C9)),
                        const SizedBox(width: 8),
                        Pill(label: 'Moyenne des élèves : 11,2', bg: Colors.white.withValues(alpha: .16), fg: Colors.white),
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
                  Row(children: const [
                    StatTile(value: '9', label: 'Bonnes réponses', valueColor: AppColors.ok600),
                    SizedBox(width: 9),
                    StatTile(value: '3', label: 'Erreurs', valueColor: AppColors.crim600),
                    SizedBox(width: 9),
                    StatTile(value: '1 h 42', label: 'Temps utilisé'),
                  ]),
                  const SectionHeader(title: 'Par partie d\'épreuve'),
                  for (final p in _parts) _partRow(p),
                  SectionHeader(title: 'Ce que tu dois revoir', action: '${_mistakes.length} erreurs'),
                  for (final m in _mistakes) _mistakeTile(context, m),
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
          child: Row(
            children: [
              SizedBox(width: 104, child: AppButton(label: 'Refaire', icon: Icons.refresh_rounded, variant: AppButtonVariant.outline, height: 50, fontSize: 13.5, onPressed: () => Navigator.of(context).maybePop())),
              const SizedBox(width: 11),
              Expanded(
                child: AppButton(
                  label: 'Voir la correction expliquée',
                  height: 50,
                  fontSize: 14,
                  onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const CorrectionScreen())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _partRow((String, String, double, Color) p) {
    final (name, score, pct, color) = p;
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              Text(score, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 7),
          LinearBar(percent: pct, color: color, height: 8),
        ],
      ),
    );
  }

  Widget _mistakeTile(BuildContext context, (String, String, String) m) {
    final (qn, title, desc) = m;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.crim100, borderRadius: BorderRadius.circular(11)),
              child: Text(qn, style: const TextStyle(color: AppColors.crim600, fontSize: 12.5, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(desc, style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                ],
              ),
            ),
            SmallButton(
              label: 'Comprendre',
              icon: Icons.track_changes_rounded,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CorrectionScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
