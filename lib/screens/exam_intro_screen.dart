import 'package:flutter/material.dart';
import '../models/exam.dart';
import '../models/exam_content.dart';
import '../services/exam_api.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/section_header.dart';
import 'exam_paper_screen.dart';
import 'exam_question_screen.dart';

class ExamIntroScreen extends StatefulWidget {
  final Exam exam;
  const ExamIntroScreen({super.key, required this.exam});

  @override
  State<ExamIntroScreen> createState() => _ExamIntroScreenState();
}

class _ExamIntroScreenState extends State<ExamIntroScreen> {
  late Future<ExamContent> content = ExamApi.fetchContent(widget.exam.id);

  String _duration(int? minutes) {
    if (minutes == null) return 'Libre';
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60, m = minutes % 60;
    return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: Column(
                children: [
                  const HeaderNavBar(title: 'Épreuve'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 2, 22, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: .28), blurRadius: 22, offset: const Offset(0, 10)),
                          ]),
                          child: ExamCover(width: 88, height: 112, color: exam.color, year: '${exam.sessionYear}'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Pill(label: '${exam.level} · ${exam.sessionLabel.toUpperCase()}', bg: Colors.white.withValues(alpha: .18), fg: Colors.white),
                              const SizedBox(height: 10),
                              Text('${exam.subjectName}\nÉpreuve complète',
                                  style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.6, height: 1.25)),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('Sujet officiel de l\'examen,\nrecopié mot pour mot',
                                    style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 11, height: 1.5)),
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
              child: FutureBuilder<ExamContent>(
                future: content,
                builder: (context, snap) {
                  if (snap.hasError) return _error();
                  final c = snap.data;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    children: [
                      Row(children: [
                        StatTile(value: '${c?.questions.length ?? exam.questionCount ?? '–'}', label: 'Questions', valueColor: AppColors.kx700),
                        const SizedBox(width: 9),
                        StatTile(value: _duration(c?.durationMinutes ?? exam.durationMinutes), label: 'Durée'),
                        const SizedBox(width: 9),
                        StatTile(value: formatScore(c?.totalPoints ?? exam.totalPoints ?? 0), label: 'Points', valueColor: AppColors.ok600),
                      ]),
                      const SectionHeader(title: 'Comment ça se passe'),
                      AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(children: _steps(c)),
                      ),
                      const SizedBox(height: 14),
                      AppCard(
                        color: AppColors.gold100,
                        borderColor: const Color(0xFFF3DFB4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded, color: AppColors.gold600, size: 20),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                'Lis bien chaque question avant de répondre. Tu peux revenir en arrière tant que tu n\'as pas validé ta copie.',
                                style: TextStyle(fontSize: 11, color: const Color(0xFF7A5400), height: 1.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (c == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Center(child: CircularProgressIndicator(color: AppColors.kx700)),
                        ),
                    ],
                  );
                },
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
                width: 112,
                child: AppButton(
                  label: 'Sujet',
                  icon: Icons.description_outlined,
                  variant: AppButtonVariant.outline,
                  height: 50,
                  fontSize: 13.5,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ExamPaperScreen(exam: exam))),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: FutureBuilder<ExamContent>(
                  future: content,
                  builder: (context, snap) => AppButton(
                    label: 'Commencer l\'épreuve',
                    icon: Icons.play_arrow_rounded,
                    height: 50,
                    onPressed: snap.hasData
                        ? () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ExamQuestionScreen(exam: exam, content: snap.data!),
                            ))
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _steps(ExamContent? c) {
    final steps = <(IconData, String, String)>[
      (Icons.format_list_bulleted_rounded, 'Une question à la fois', 'Les questions arrivent une par une, dans l\'ordre du sujet'),
      if (c?.durationMinutes != null)
        (Icons.access_time_rounded, 'Chrono de ${_duration(c!.durationMinutes)}', 'Il t\'aide à gérer ton temps comme le jour de l\'examen'),
      if (c?.hasDictation ?? false)
        (Icons.record_voice_over_outlined, 'Dictée lue à voix haute', 'Écris sur ton cahier, puis prends ta page en photo'),
      if ((c?.hasPhotoQuestions ?? false) && !(c?.hasDictation ?? false))
        (Icons.camera_alt_outlined, 'Clavier ou photo', 'Tape tes réponses ; pour un dessin, prends-le en photo'),
      (Icons.volume_up_outlined, 'Écoute les questions', 'Touche « Écouter » pour entendre l\'énoncé'),
      (Icons.fact_check_outlined, 'Ta note et la correction', 'À la fin, tu vois ta note et la bonne réponse à chaque question'),
    ];
    return [
      for (int i = 0; i < steps.length; i++) ...[
        _stepRow(steps[i]),
        if (i != steps.length - 1) const Divider(height: 1, color: AppColors.line),
      ],
    ];
  }

  Widget _error() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off_rounded, size: 42, color: AppColors.kx300),
          const SizedBox(height: 12),
          const Text('Impossible de charger l\'épreuve', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Vérifie ta connexion internet puis réessaie.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: AppButton(
              label: 'Réessayer',
              icon: Icons.refresh_rounded,
              height: 46,
              onPressed: () => setState(() => content = ExamApi.fetchContent(widget.exam.id)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _stepRow((IconData, String, String) s) {
    final (icon, title, desc) = s;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.kx50, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: AppColors.kx700, size: 19),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
