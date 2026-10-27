import 'package:flutter/material.dart';
import '../models/exam_content.dart';
import '../models/exam_session.dart';
import '../models/grading_result.dart';
import '../services/exam_api.dart';
import '../theme/app_colors.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/passage_card.dart';
import '../widgets/rich_prompt.dart';
import 'ai_explain_text_screen.dart';
import 'ai_explain_voice_screen.dart';

/// Relecture de toute l'épreuve, question par question.
class CorrectionScreen extends StatefulWidget {
  final ExamSession session;
  final int initialIndex;
  const CorrectionScreen({super.key, required this.session, this.initialIndex = 0});

  @override
  State<CorrectionScreen> createState() => _CorrectionScreenState();
}

class _CorrectionScreenState extends State<CorrectionScreen> {
  late int index = widget.initialIndex;
  final ScrollController scroll = ScrollController();
  final ScrollController tracker = ScrollController();

  ExamSession get session => widget.session;

  @override
  void dispose() {
    scroll.dispose();
    tracker.dispose();
    super.dispose();
  }

  void _goTo(int i) {
    if (i < 0 || i >= session.result.questions.length) return;
    setState(() => index = i);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, bool>>(
      valueListenable: session.selfMarks,
      builder: (context, _, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final results = session.result.questions;
    final r = results[index];
    final q = session.question(r.id);
    final status = session.statusOf(r);
    final passage = session.content.passage(q.passage);
    final count = results.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Column(
                children: [
                  HeaderNavBar(
                    title: 'Correction',
                    subtitle: '${session.exam.subjectName} · ${session.exam.shortLabel} · ${formatScore(session.score)}/${formatScore(session.result.total)}',
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      controller: tracker,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      children: [
                        for (int i = 0; i < count; i++) _trackerChip(i, session.statusOf(results[i])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  Row(
                    children: [
                      _statusChip(status),
                      const SizedBox(width: 8),
                      AppChip(
                        label: status == GradeStatus.toCheck
                            ? '${formatScore(r.points)} pt'
                            : '${formatScore(session.awardedOf(r))} / ${formatScore(r.points)} pt',
                        tone: ChipTone.line,
                        height: 28,
                      ),
                      const Spacer(),
                      Text('Question ${index + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted)),
                    ],
                  ),
                  if (passage != null && q.type != QuestionType.dictation) ...[
                    const SizedBox(height: 12),
                    PassageCard(key: ValueKey('p-${q.id}'), passage: passage, dictationRevealed: true),
                  ],
                  const SizedBox(height: 13),
                  if (q.stem != null) ...[
                    Text.rich(TextSpan(children: markupSpans(q.stem!, style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.ink2, fontWeight: FontWeight.w600)))),
                    const SizedBox(height: 5),
                  ],
                  RichPrompt(
                    [?q.label, q.prompt].join(' '),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.55, color: AppColors.ink, letterSpacing: -0.15),
                  ),
                  if (q.options.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    for (final o in q.options)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text('– ${stripMarkup(o)}', style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.ink2)),
                      ),
                  ],
                  const SizedBox(height: 14),
                  _studentAnswer(r, status),
                  if (status != GradeStatus.correct || r.status == GradeStatus.toCheck) ...[
                    const SizedBox(height: 11),
                    _expected(r, q),
                  ],
                  if (r.status == GradeStatus.toCheck) ...[
                    const SizedBox(height: 12),
                    _selfCheck(r),
                  ],
                  if (r.feedback != null) ...[
                    const SizedBox(height: 12),
                    _feedback(r.feedback!),
                  ],
                  const SizedBox(height: 16),
                  _explainCard(r, status),
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
              Expanded(
                child: AppButton(
                  label: index == 0 ? 'Résultat' : 'Question $index',
                  icon: Icons.arrow_back_rounded,
                  variant: AppButtonVariant.outline,
                  height: 50,
                  fontSize: 13.5,
                  onPressed: index == 0 ? () => Navigator.of(context).maybePop() : () => _goTo(index - 1),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: index == count - 1
                    ? AppButton(label: 'Terminer', icon: Icons.check_rounded, height: 50, fontSize: 13.5, onPressed: () => Navigator.of(context).maybePop())
                    : AppButton(
                        label: 'Question ${index + 2}',
                        icon: Icons.arrow_forward_rounded,
                        iconTrailing: true,
                        height: 50,
                        fontSize: 13.5,
                        onPressed: () => _goTo(index + 1),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trackerChip(int i, GradeStatus s) {
    final active = i == index;
    var (bg, fg) = switch (s) {
      GradeStatus.correct => (AppColors.ok100, AppColors.ok600),
      GradeStatus.partial => (AppColors.gold100, AppColors.gold600),
      GradeStatus.toCheck => (Colors.white.withValues(alpha: .9), AppColors.kx700),
      _ => (AppColors.crim100, AppColors.crim600),
    };
    if (active) {
      bg = fg;
      fg = Colors.white;
    }
    return GestureDetector(
      onTap: () => _goTo(i),
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active ? [BoxShadow(color: Colors.white.withValues(alpha: .4), blurRadius: 0, spreadRadius: 2.5)] : null,
        ),
        child: Text('${i + 1}', style: TextStyle(fontSize: 11.5, fontWeight: active ? FontWeight.w800 : FontWeight.w700, color: fg)),
      ),
    );
  }

  Widget _statusChip(GradeStatus s) => switch (s) {
        GradeStatus.correct => const AppChip(label: 'Bonne réponse', icon: Icons.check_circle_outline_rounded, tone: ChipTone.ok, height: 28),
        GradeStatus.partial => const AppChip(label: 'Réponse incomplète', icon: Icons.adjust_rounded, tone: ChipTone.gold, height: 28),
        GradeStatus.unanswered => const AppChip(label: 'Sans réponse', icon: Icons.remove_circle_outline_rounded, tone: ChipTone.neutral, height: 28),
        GradeStatus.toCheck => const AppChip(label: 'À vérifier', icon: Icons.help_outline_rounded, tone: ChipTone.neutral, height: 28),
        GradeStatus.wrong => const AppChip(label: 'Réponse fausse', icon: Icons.cancel_outlined, tone: ChipTone.crim, height: 28),
      };

  Widget _studentAnswer(QuestionResult r, GradeStatus s) {
    final (bg, border, fg, icon, label) = switch (s) {
      GradeStatus.correct => (AppColors.ok100, const Color(0xFFB9E3CE), const Color(0xFF0E5C3E), Icons.check_circle_outline_rounded, 'TA RÉPONSE EST JUSTE'),
      GradeStatus.partial => (AppColors.gold100, const Color(0xFFF1DDB0), const Color(0xFF5E4200), Icons.adjust_rounded, 'TA RÉPONSE'),
      GradeStatus.toCheck || GradeStatus.unanswered => (Colors.white, AppColors.line, AppColors.ink, Icons.edit_note_rounded, 'TA RÉPONSE'),
      GradeStatus.wrong => (AppColors.crim100, const Color(0xFFF3C9C4), const Color(0xFF7A1B14), Icons.cancel_outlined, 'TA RÉPONSE'),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: fg, size: 16),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg, letterSpacing: .5)),
          ]),
          const SizedBox(height: 8),
          if (r.hasPhoto)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                ExamApi.photoUrl(session.result.submissionId, r.id),
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Text('Photo indisponible', style: TextStyle(color: AppColors.muted)),
              ),
            ),
          if (r.studentAnswer != null && !(r.hasPhoto && r.studentAnswer == 'Réponse en photo'))
            Padding(
              padding: EdgeInsets.only(top: r.hasPhoto ? 8 : 0),
              child: Text(r.studentAnswer!, style: TextStyle(fontSize: 14.5, height: 1.5, color: fg, fontWeight: FontWeight.w600)),
            ),
          if (r.studentAnswer == null && !r.hasPhoto)
            const Text('Tu n\'as pas répondu à cette question.', style: TextStyle(fontSize: 14, color: AppColors.muted, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _expected(QuestionResult r, ExamQuestion q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(color: AppColors.ok100, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFB9E3CE))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.ok600, size: 16),
            const SizedBox(width: 8),
            Text(q.type == QuestionType.dictation ? 'TEXTE DE LA DICTÉE' : 'RÉPONSE ATTENDUE',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0E5C3E), letterSpacing: .5)),
          ]),
          const SizedBox(height: 8),
          Text(r.expected, style: const TextStyle(fontSize: 14.5, height: 1.65, color: Color(0xFF0E5C3E), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _selfCheck(QuestionResult r) {
    final mark = session.selfMarks.value[r.id];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.kx300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Compare avec la réponse attendue. Avais-tu juste ?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 11),
          Row(children: [
            Expanded(
              child: SmallButton(
                label: 'J\'avais juste',
                icon: Icons.check_rounded,
                color: AppColors.ok600,
                filled: mark == true,
                onPressed: () => session.mark(r.id, true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SmallButton(
                label: 'Je me suis trompé',
                icon: Icons.close_rounded,
                color: AppColors.crim600,
                filled: mark == false,
                onPressed: () => session.mark(r.id, false),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _feedback(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.kx50, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.kx100)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: AppColors.kx700, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.track_changes_rounded, color: AppColors.gold500, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.55, color: AppColors.ink))),
        ],
      ),
    );
  }

  Widget _explainCard(QuestionResult r, GradeStatus s) {
    final wrong = s == GradeStatus.wrong || s == GradeStatus.partial || s == GradeStatus.unanswered;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppColors.gold100, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1DDB0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppColors.kx700, borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.track_changes_rounded, color: AppColors.gold500, size: 22),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wrong ? 'Tu n\'as pas compris ?' : 'Tu veux en savoir plus ?',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF5E4200))),
                    const SizedBox(height: 4),
                    Text(
                      session.aiAvailable
                          ? 'Examo t\'explique cette question pas à pas, à l\'écrit ou à voix haute.'
                          : 'Les explications d\'Examo seront bientôt disponibles.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF7A5400), height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (session.aiAvailable) ...[
            const SizedBox(height: 13),
            Row(children: [
              Expanded(
                child: AppButton(
                  label: 'À l\'écrit',
                  icon: Icons.menu_book_rounded,
                  variant: AppButtonVariant.gold,
                  height: 46,
                  fontSize: 13.5,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AiExplainTextScreen(session: session, questionId: r.id))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'À l\'oral',
                  icon: Icons.graphic_eq_rounded,
                  variant: AppButtonVariant.outline,
                  height: 46,
                  fontSize: 13.5,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AiExplainVoiceScreen(session: session, questionId: r.id))),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}
