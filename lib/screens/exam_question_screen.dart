import 'dart:async';

import 'package:flutter/material.dart';
import '../models/exam.dart';
import '../models/exam_content.dart';
import '../models/exam_session.dart';
import '../models/student_answer.dart';
import '../services/exam_api.dart';
import '../services/voice.dart';
import '../theme/app_colors.dart';
import '../widgets/answer_inputs.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/passage_card.dart';
import '../widgets/rich_prompt.dart';
import 'result_screen.dart';

/// L'épreuve, une question à la fois : énoncé en haut, réponse en dessous.
class ExamQuestionScreen extends StatefulWidget {
  final Exam exam;
  final ExamContent content;
  const ExamQuestionScreen({super.key, required this.exam, required this.content});

  @override
  State<ExamQuestionScreen> createState() => _ExamQuestionScreenState();
}

class _ExamQuestionScreenState extends State<ExamQuestionScreen> {
  late final Map<String, StudentAnswer> answers = {for (final q in widget.content.questions) q.id: StudentAnswer(q)};
  final Set<String> lockedDictations = {};
  final ScrollController scroll = ScrollController();
  final DateTime startedAt = DateTime.now();
  late final Timer ticker;
  int index = 0;
  bool submitting = false;

  List<ExamQuestion> get questions => widget.content.questions;
  ExamQuestion get question => questions[index];
  int get elapsedSeconds => DateTime.now().difference(startedAt).inSeconds;

  @override
  void initState() {
    super.initState();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    ticker.cancel();
    scroll.dispose();
    Voice.instance.stop();
    super.dispose();
  }

  bool get dictationRevealed => lockedDictations.isNotEmpty;

  Future<void> _goTo(int target) async {
    if (target < 0 || target >= questions.length || target == index) return;
    if (target > index && question.type == QuestionType.dictation && !lockedDictations.contains(question.id)) {
      final ok = answers[question.id]!.photoPath != null || await _confirmSkipDictation();
      if (!ok) return;
      lockedDictations.add(question.id);
    }
    await Voice.instance.stop();
    setState(() => index = target);
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  Future<bool> _confirmSkipDictation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passer la dictée ?'),
        content: const Text('Tu n\'as pas encore pris ta dictée en photo. Si tu continues, tu ne pourras plus la faire et le texte de la dictée sera affiché pour les questions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Rester')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Passer la dictée')),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _confirmQuit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitter l\'épreuve ?'),
        content: const Text('Tes réponses ne seront pas gardées.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continuer l\'épreuve')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Quitter')),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _finish() async {
    if (question.type == QuestionType.dictation && !lockedDictations.contains(question.id)) {
      final ok = answers[question.id]!.photoPath != null || await _confirmSkipDictation();
      if (!ok) return;
      lockedDictations.add(question.id);
    }
    final unanswered = questions.where((q) => !answers[q.id]!.isAnswered(q)).length;
    if (!mounted) return;
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Valider ta copie ?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              unanswered == 0
                  ? 'Tu as répondu à toutes les questions. Après la validation, tu ne pourras plus changer tes réponses.'
                  : '$unanswered question${unanswered > 1 ? 's' : ''} sans réponse. Tu peux encore revenir en arrière, ou valider maintenant.',
              style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.ink2),
            ),
            const SizedBox(height: 18),
            AppButton(label: 'Valider ma copie', icon: Icons.check_rounded, height: 50, onPressed: () => Navigator.pop(context, true)),
            const SizedBox(height: 8),
            AppButton(label: 'Revoir mes réponses', variant: AppButtonVariant.outline, height: 46, onPressed: () => Navigator.pop(context, false)),
          ]),
        ),
      ),
    );
    if (confirm == true) await _submit();
  }

  Future<void> _submit() async {
    setState(() => submitting = true);
    await Voice.instance.stop();
    try {
      final aiStatus = ExamApi.aiAvailable();
      final result = await ExamApi.submit(widget.content, answers, elapsedSeconds);
      final aiAvailable = await aiStatus;
      if (!mounted) return;
      final session = ExamSession(
        exam: widget.exam,
        content: widget.content,
        answers: answers,
        result: result,
        aiAvailable: aiAvailable,
      );
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ResultScreen(session: session)));
    } catch (e) {
      if (!mounted) return;
      setState(() => submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e is ExamApiException ? e.message : 'Envoi impossible : vérifie ta connexion internet.'),
        action: SnackBarAction(label: 'Réessayer', onPressed: _submit),
        duration: const Duration(seconds: 8),
      ));
    }
  }

  String _timerLabel() {
    final limit = widget.content.durationMinutes;
    final elapsed = elapsedSeconds;
    final shown = limit == null ? elapsed : limit * 60 - elapsed;
    if (shown < 0) return 'Temps écoulé';
    final m = shown ~/ 60, s = shown % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final q = question;
    final passage = widget.content.passage(q.passage);
    final last = index == questions.length - 1;
    final timeUp = widget.content.durationMinutes != null && elapsedSeconds > widget.content.durationMinutes! * 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || submitting) return;
        if (await _confirmQuit() && context.mounted) Navigator.of(context).pop();
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.bg,
            body: SafeArea(
              child: Column(
                children: [
                  GradientHeaderShell(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    child: Column(
                      children: [
                        HeaderNavBar(
                          title: 'Question ${index + 1} sur ${questions.length}',
                          subtitle: '${widget.exam.subjectName} · ${widget.exam.shortLabel}',
                          actions: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: (timeUp ? AppColors.crim600 : AppColors.gold500).withValues(alpha: .22),
                                border: Border.all(color: (timeUp ? AppColors.crim600 : AppColors.gold500).withValues(alpha: .45)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(children: [
                                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFFFFD79A)),
                                const SizedBox(width: 5),
                                Text(_timerLabel(), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFFFFD79A))),
                              ]),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: List.generate(questions.length, (i) {
                              final Color c;
                              if (i == index) {
                                c = Colors.white;
                              } else if (answers[questions[i].id]!.isAnswered(questions[i])) {
                                c = AppColors.gold500;
                              } else {
                                c = Colors.white.withValues(alpha: .26);
                              }
                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _goTo(i),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                      height: 5,
                                      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(9)),
                                    ),
                                  ),
                                ),
                              );
                            }),
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
                            Flexible(
                              child: AppChip(
                                label: q.section != null ? stripMarkup(q.section!) : (q.type == QuestionType.dictation ? 'Dictée' : 'Question'),
                                height: 28,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(formatPoints(q.points), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.muted)),
                          ],
                        ),
                        if (passage != null && q.type != QuestionType.dictation) ...[
                          const SizedBox(height: 12),
                          PassageCard(passage: passage, dictationRevealed: dictationRevealed),
                        ],
                        const SizedBox(height: 14),
                        if (q.stem != null) ...[
                          Text.rich(TextSpan(children: markupSpans(q.stem!, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.ink2, fontWeight: FontWeight.w600)))),
                          const SizedBox(height: 6),
                        ],
                        RichPrompt(
                            [?q.label, q.prompt].join(' '),
                            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, height: 1.55, color: AppColors.ink, letterSpacing: -0.2),
                          ),
                        if (q.type != QuestionType.dictation) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ValueListenableBuilder<bool>(
                              valueListenable: Voice.instance.speaking,
                              builder: (context, speaking, _) => SmallButton(
                                label: speaking ? 'Arrêter' : 'Écouter la question',
                                icon: speaking ? Icons.stop_rounded : Icons.volume_up_outlined,
                                onPressed: () => speaking ? Voice.instance.stop() : Voice.instance.speakOrExplain(context, q.spokenText),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Text('TA RÉPONSE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: .6)),
                        const SizedBox(height: 10),
                        AnswerInput(
                          question: q,
                          passage: passage,
                          answer: answers[q.id]!,
                          dictationLocked: lockedDictations.contains(q.id),
                          onChanged: () => setState(() {}),
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
                child: Row(
                  children: [
                    SizedBox(
                      width: 124,
                      child: AppButton(
                        label: 'Précédent',
                        icon: Icons.arrow_back_rounded,
                        variant: AppButtonVariant.outline,
                        height: 50,
                        fontSize: 13.5,
                        onPressed: index == 0 ? null : () => _goTo(index - 1),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: AppButton(
                        label: last ? 'Terminer l\'épreuve' : 'Suivant',
                        icon: last ? Icons.check_rounded : Icons.arrow_forward_rounded,
                        iconTrailing: !last,
                        variant: last ? AppButtonVariant.gold : AppButtonVariant.primary,
                        height: 50,
                        onPressed: last ? _finish : () => _goTo(index + 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (submitting) const _GradingOverlay(),
        ],
      ),
    );
  }
}

class _GradingOverlay extends StatelessWidget {
  const _GradingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: AppColors.kx900.withValues(alpha: .86),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: 56, height: 56, child: CircularProgressIndicator(color: AppColors.gold500, strokeWidth: 5)),
              SizedBox(height: 22),
              Text('Examo corrige ta copie…', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              SizedBox(height: 8),
              Text('Cela peut prendre jusqu\'à une minute.\nNe ferme pas l\'application.',
                  textAlign: TextAlign.center, style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13, height: 1.5)),
            ]),
          ),
        ),
      ),
    );
  }
}
