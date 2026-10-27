import 'package:flutter/material.dart';
import '../models/exam.dart';
import '../services/progress_store.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/gradient_header.dart';
import '../widgets/section_header.dart';
import '../root_shell.dart';

class SubjectDetailScreen extends StatelessWidget {
  final String subjectCode;
  final String subjectName;
  const SubjectDetailScreen({super.key, required this.subjectCode, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    final color = subjectColor(subjectCode);
    final icon = subjectIcon(subjectCode);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final exams = [...store.bySubject.firstWhere((s) => s.code == subjectCode, orElse: () => SubjectProgress(subjectCode, subjectName, const [])).exams]
            ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
          final avgOn20 = exams.isEmpty ? 0.0 : exams.map((e) => e.scoreOn20).reduce((a, b) => a + b) / exams.length;
          final avgPercent = exams.isEmpty ? 0.0 : exams.map((e) => e.percent).reduce((a, b) => a + b) / exams.length;
          final isWeakest = store.weakestSubjects.isNotEmpty && store.weakestSubjects.first.code == subjectCode && store.bySubject.length > 1;

          return SafeArea(
            child: Column(
              children: [
                GradientHeaderShell(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                  child: Column(
                    children: [
                      HeaderNavBar(title: subjectName, subtitle: 'CEPD'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 2, 22, 0),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(color: color.withValues(alpha: .3), borderRadius: BorderRadius.circular(16)),
                              child: Icon(icon, color: Colors.white, size: 27),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Row(
                                children: [
                                  _statChip('${exams.length}', 'Épreuves'),
                                  const SizedBox(width: 9),
                                  _statChip(exams.isEmpty ? '–' : avgOn20.toStringAsFixed(1).replaceAll('.', ','), 'Moyenne', color: const Color(0xFFFFD79A)),
                                  const SizedBox(width: 9),
                                  _statChip(exams.isEmpty ? '–' : '${(avgPercent * 100).round()}%', 'Réussite'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isWeakest) ...[
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
                            child: const Row(children: [
                              Icon(Icons.track_changes_rounded, color: Color(0xFFFFD79A), size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text('C\'est ta matière la moins avancée pour l\'instant : un bon prochain choix.',
                                    style: TextStyle(fontSize: 11, color: Colors.white, height: 1.5)),
                              ),
                            ]),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
                Expanded(
                  child: exams.isEmpty
                      ? _empty(context)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          children: [
                            const SectionHeader(title: 'Tes épreuves'),
                            for (final e in exams) _examTile(e),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_edu_outlined, size: 40, color: AppColors.kx300),
            const SizedBox(height: 12),
            const Text('Aucune épreuve traitée', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Choisis une annale de $subjectName dans l\'onglet Annales pour commencer.',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => RootShell.openTab(context, RootShell.annalesTab),
              child: const Text('Voir les annales', style: TextStyle(color: AppColors.kx700, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String value, String label, {Color color = Colors.white}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 11),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), border: Border.all(color: Colors.white.withValues(alpha: .18)), borderRadius: BorderRadius.circular(13)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .76), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _examTile(CompletedExam e) {
    final pct = (e.percent * 100).round();
    final color = pct >= 70 ? AppColors.ok600 : (pct >= 40 ? const Color(0xFFE8A33C) : AppColors.crim600);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.sessionYear?.toString() ?? '—', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Text(_dateLabel(e.completedAt), style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
              ],
            ),
            const Spacer(),
            if (e.pendingSelfChecks > 0)
              const Chip(label: Text('À vérifier', style: TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact, backgroundColor: AppColors.warn100)
            else
              Text('${e.scoreOn20.toStringAsFixed(1).replaceAll('.', ',')} / 20',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime d) {
    const months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return '${d.day} ${months[d.month - 1]}';
  }
}
