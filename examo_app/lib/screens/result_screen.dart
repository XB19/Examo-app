import 'package:flutter/material.dart';
import '../models/exam_content.dart';
import '../models/exam_session.dart';
import '../models/grading_result.dart';
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
  final ExamSession session;
  const ResultScreen({super.key, required this.session});

  void _openCorrection(BuildContext context, int index) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CorrectionScreen(session: session, initialIndex: index)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, bool>>(
      valueListenable: session.selfMarks,
      builder: (context, _, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final result = session.result;
    final score = session.score;
    final total = result.total;
    final percent = total == 0 ? 0.0 : (score / total).toDouble();
    final pending = session.pendingSelfChecks;
    final statuses = [for (final r in result.questions) session.statusOf(r)];
    final correct = statuses.where((s) => s == GradeStatus.correct).length;
    final toReview = [
      for (int i = 0; i < result.questions.length; i++)
        if (statuses[i] != GradeStatus.correct) i,
    ];

    final String title;
    final String subtitle;
    if (pending > 0) {
      title = 'À toi de vérifier !';
      subtitle = result.notice ?? 'Compare tes réponses avec le corrigé pour obtenir ta note.';
    } else {
      title = percent >= .8
          ? 'Excellent travail !'
          : percent >= .5
              ? 'Bien joué !'
              : 'Courage, tu vas progresser !';
      subtitle = 'Tu as obtenu ${formatScore(score)} ${score > 1 ? 'points' : 'point'} sur ${formatScore(total)} à l\'épreuve de ${session.exam.subjectName.toLowerCase()}.';
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: Column(
                children: [
                  const HeaderNavBar(title: 'Résultat', showBack: false),
                  const SizedBox(height: 4),
                  ProgressRing(
                    size: 132,
                    percent: percent,
                    strokeWidth: 12,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formatScore(score), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
                        Text('sur ${formatScore(total)}', style: const TextStyle(color: Color(0xC7FFFFFF), fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                    child: Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: .84), fontSize: 13, height: 1.5)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (pending > 0)
                          Pill(label: 'Note provisoire', icon: Icons.hourglass_top_rounded, bg: AppColors.gold500.withValues(alpha: .26), fg: const Color(0xFFFFD79A))
                        else
                          Pill(
                            label: result.gradedByAi ? 'Corrigé par Examo' : 'Corrigé par toi',
                            icon: Icons.verified_outlined,
                            bg: AppColors.ok600.withValues(alpha: .3),
                            fg: const Color(0xFFA7E7C9),
                          ),
                        Pill(label: '${session.exam.subjectName} · ${session.exam.shortLabel}', bg: Colors.white.withValues(alpha: .16), fg: Colors.white),
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
                  Row(children: [
                    StatTile(value: '$correct', label: 'Bonnes réponses', valueColor: AppColors.ok600),
                    const SizedBox(width: 9),
                    StatTile(value: '${toReview.length - pending}', label: 'À revoir', valueColor: AppColors.crim600),
                    const SizedBox(width: 9),
                    StatTile(value: _duration(result.durationSeconds), label: 'Temps utilisé'),
                  ]),
                  ..._sections(),
                  if (toReview.isNotEmpty) ...[
                    SectionHeader(title: pending > 0 ? 'Questions à vérifier' : 'Ce que tu dois revoir', action: '${toReview.length}'),
                    for (final i in toReview) _reviewTile(context, i, statuses[i]),
                  ] else ...[
                    const SizedBox(height: 18),
                    AppCard(
                      color: AppColors.ok100,
                      borderColor: const Color(0xFFB9E3CE),
                      child: const Row(children: [
                        Icon(Icons.emoji_events_outlined, color: AppColors.ok600),
                        SizedBox(width: 11),
                        Expanded(child: Text('Toutes tes réponses sont justes. Bravo !', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ok600))),
                      ]),
                    ),
                  ],
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
              SizedBox(
                width: 104,
                child: AppButton(label: 'Refaire', icon: Icons.refresh_rounded, variant: AppButtonVariant.outline, height: 50, fontSize: 13.5, onPressed: () => Navigator.of(context).maybePop()),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: AppButton(
                  label: pending > 0 ? 'Vérifier mes réponses' : 'Voir la correction',
                  height: 50,
                  fontSize: 14,
                  onPressed: () => _openCorrection(context, toReview.isNotEmpty && pending > 0 ? toReview.first : 0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _sections() {
    final order = <String>[];
    final scores = <String, (num, num)>{};
    for (final r in session.result.questions) {
      final section = session.question(r.id).section;
      if (section == null) continue;
      if (!scores.containsKey(section)) order.add(section);
      final (got, max) = scores[section] ?? (0, 0);
      scores[section] = (got + session.awardedOf(r), max + r.points);
    }
    if (order.length < 2) return const [];
    return [
      const SectionHeader(title: 'Par partie d\'épreuve'),
      for (final s in order) _partRow(s, scores[s]!.$1, scores[s]!.$2),
    ];
  }

  Widget _partRow(String name, num got, num max) {
    final pct = max == 0 ? 0.0 : (got / max).toDouble();
    final color = pct >= .75 ? AppColors.ok600 : (pct >= .5 ? AppColors.kx700 : AppColors.crim600);
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(stripMarkup(name), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
              Text('${formatScore(got)} / ${formatScore(max)}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 7),
          LinearBar(percent: pct, color: color, height: 8),
        ],
      ),
    );
  }

  Widget _reviewTile(BuildContext context, int index, GradeStatus status) {
    final r = session.result.questions[index];
    final q = session.question(r.id);
    final prompt = stripMarkup([?q.label, q.prompt].join(' ')).replaceAll(ExamQuestion.blankMarker, '…');
    final (desc, bg, fg) = switch (status) {
      GradeStatus.partial => ('Réponse incomplète · ${formatScore(session.awardedOf(r))} / ${formatScore(r.points)}', AppColors.gold100, AppColors.gold600),
      GradeStatus.unanswered => ('Sans réponse', AppColors.bg, AppColors.ink2),
      GradeStatus.toCheck => ('À vérifier avec le corrigé', AppColors.kx50, AppColors.kx700),
      _ => ('Réponse fausse', AppColors.crim100, AppColors.crim600),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: AppCard(
        onTap: () => _openCorrection(context, index),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
              child: Text('Q${index + 1}', style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prompt, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(desc, style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SmallButton(
              label: status == GradeStatus.toCheck ? 'Vérifier' : 'Comprendre',
              icon: Icons.track_changes_rounded,
              onPressed: () => _openCorrection(context, index),
            ),
          ],
        ),
      ),
    );
  }

  static String _duration(int? seconds) {
    if (seconds == null) return '–';
    final m = (seconds / 60).round();
    if (m < 60) return '$m min';
    return '${m ~/ 60} h ${(m % 60).toString().padLeft(2, '0')}';
  }
}
