import 'package:flutter/material.dart';
import '../services/progress_store.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_header.dart';
import 'subject_detail_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final hasHistory = store.examCount > 0;
            final subjects = store.bySubject..sort((a, b) => a.name.compareTo(b.name));
            final weakest = store.weakestSubjects;
            final scores = store.recentScores();

            return Column(
              children: [
                GradientHeaderShell(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                  child: Column(
                    children: [
                      HeaderNavBar(
                        title: 'Ma progression',
                        showBack: false,
                        actions: [CircleIconButton(icon: Icons.calendar_today_outlined, ghost: true, onPressed: () {})],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 2, 22, 0),
                        child: Row(
                          children: [
                            ProgressRing(
                              size: 104,
                              percent: store.overallPercent,
                              center: Text(
                                hasHistory ? '${(store.overallPercent * 100).round()}%' : '–',
                                style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -1),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Préparation au CEPD', style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    hasHistory ? 'Moyenne ${store.averageOn20.toStringAsFixed(1).replaceAll('.', ',')} / 20' : 'Pas encore de résultats',
                                    style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      hasHistory
                                          ? '${store.examCount} épreuve${store.examCount > 1 ? 's' : ''} · ${_hours(store.totalPracticeTime)} d\'entraînement'
                                          : 'Termine une épreuve pour voir ta progression ici.',
                                      style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 11, height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Expanded(
                  child: hasHistory
                      ? ListView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          children: [
                            if (scores.length >= 2)
                              AppCard(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Évolution de ta réussite', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                        Text('${scores.length} dernières épreuves', style: const TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('${(scores.last * 100).round()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.8)),
                                        const SizedBox(width: 12),
                                        Expanded(child: Sparkline(values: scores)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            const SectionHeader(title: 'Niveau par matière'),
                            AppCard(
                              padding: const EdgeInsets.fromLTRB(14, 16, 14, 4),
                              child: MiniBarChart(
                                data: [
                                  for (final s in subjects)
                                    (_shortLabel(s.name), (s.averagePercent * 100).round(), s.averagePercent >= .7 ? AppColors.ok600 : s.color),
                                ],
                              ),
                            ),
                            const SectionHeader(title: 'À travailler en priorité'),
                            for (final s in weakest.take(3)) _priorityTile(context, s),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.all(28),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bar_chart_rounded, size: 40, color: AppColors.kx300),
                                const SizedBox(height: 12),
                                const Text('Rien à afficher pour l\'instant', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 6),
                                const Text('Termine ta première épreuve pour voir ta moyenne, ton niveau par matière et tes priorités de révision.',
                                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _shortLabel(String name) => name.length > 9 ? '${name.substring(0, 8)}…' : name;

  String _hours(Duration d) {
    if (d.inMinutes < 1) return '< 1 min';
    if (d.inHours < 1) return '${d.inMinutes} min';
    return '${d.inHours} h ${(d.inMinutes % 60).toString().padLeft(2, '0')}';
  }

  Widget _priorityTile(BuildContext context, SubjectProgress s) {
    final pct = (s.averagePercent * 100).round();
    final color = pct >= 70 ? AppColors.ok600 : (pct >= 40 ? const Color(0xFFE8A33C) : AppColors.crim600);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SubjectDetailScreen(subjectCode: s.code, subjectName: s.name))),
        child: Row(
          children: [
            MiniRing(percent: s.averagePercent, color: color, label: '$pct'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('${s.count} épreuve${s.count > 1 ? 's' : ''} traitée${s.count > 1 ? 's' : ''}', style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8C4D8)),
          ],
        ),
      ),
    );
  }
}
