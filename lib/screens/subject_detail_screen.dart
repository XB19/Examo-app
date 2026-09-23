import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import 'remediation_screen.dart';

class SubjectDetailScreen extends StatefulWidget {
  const SubjectDetailScreen({super.key});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  int tab = 0;

  static const _chapters = [
    ('Théorème de Thalès', 38, AppColors.crim600, '4 erreurs'),
    ('Théorème de Pythagore', 76, AppColors.ok600, '1 erreurs'),
    ('Équations du 1er degré', 64, AppColors.kx700, '2 erreurs'),
    ('Statistiques', 81, AppColors.ok600, 'Maîtrisé'),
    ('Volumes et aires', 55, Color(0xFFE8A33C), '3 erreurs'),
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
                  const HeaderNavBar(title: 'Mathématiques', subtitle: 'BEPC · coefficient 4'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 2, 22, 0),
                    child: Row(
                      children: [
                        _statChip('12,6', 'Moyenne'),
                        const SizedBox(width: 9),
                        _statChip('72 %', 'Maîtrise', color: const Color(0xFFFFD79A)),
                        const SizedBox(width: 9),
                        _statChip('6 / 9', 'Annales'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.gold500.withValues(alpha: .16),
                        border: Border.all(color: AppColors.gold500.withValues(alpha: .35)),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.track_changes_rounded, color: Color(0xFFFFD79A), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(fontSize: 11, color: Colors.white, height: 1.5),
                                children: [
                                  TextSpan(text: 'Travaille '),
                                  TextSpan(text: 'Thalès', style: TextStyle(fontWeight: FontWeight.w800)),
                                  TextSpan(text: ' en priorité : c\'est tombé aux 4 dernières sessions.'),
                                ],
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(11)),
                        child: Row(children: [
                          _tab('Chapitres', 0),
                          _tab('Épreuves', 1),
                        ]),
                      ),
                      const Text('Les plus faibles', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.kx700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final c in _chapters) _chapterTile(c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String value, String label, {Color color = Colors.white}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), border: Border.all(color: Colors.white.withValues(alpha: .18)), borderRadius: BorderRadius.circular(13)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: .76), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int i) {
    final active = tab == i;
    return GestureDetector(
      onTap: () => setState(() => tab = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: active ? AppColors.kx700 : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.muted)),
      ),
    );
  }

  Widget _chapterTile((String, int, Color, String) c) {
    final (title, pct, color, errLabel) = c;
    final mastered = errLabel == 'Maîtrisé';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RemediationScreen())),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                Text('$pct%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
              ],
            ),
            const SizedBox(height: 9),
            LinearBar(percent: pct / 100, color: color),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(errLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: mastered ? AppColors.ok600 : AppColors.crim600)),
                const Row(children: [
                  Text('Réviser', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.kx700)),
                  Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.kx700),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
