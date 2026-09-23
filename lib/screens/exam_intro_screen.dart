import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/section_header.dart';
import 'exam_question_screen.dart';

class ExamIntroScreen extends StatelessWidget {
  const ExamIntroScreen({super.key});

  static const _steps = [
    (Icons.format_list_bulleted_rounded, '12 questions', 'Réponses courtes, calculs et 2 problèmes'),
    (Icons.access_time_rounded, '2 heures', 'Chrono visible, pause possible une fois'),
    (Icons.edit_note_rounded, 'Clavier ou cahier', 'Tape ta réponse ou photographie ta page'),
    (Icons.wifi_off_rounded, 'Sans connexion', 'L\'épreuve est déjà téléchargée sur ton appareil'),
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
                    title: 'Épreuve',
                    actions: [
                      CircleIconButton(icon: Icons.bookmark_border_rounded, ghost: true, onPressed: () {}),
                      const SizedBox(width: 4),
                      CircleIconButton(icon: Icons.favorite_border_rounded, ghost: true, onPressed: () {}),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 2, 22, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: .28), blurRadius: 22, offset: const Offset(0, 10)),
                          ]),
                          child: const ExamCover(width: 88, height: 112, color: AppColors.mathBlue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Pill(label: 'BEPC · SESSION 2024', bg: Colors.white.withValues(alpha: .18), fg: Colors.white),
                              const SizedBox(height: 10),
                              const Text('Mathématiques\nÉpreuve complète',
                                  style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -0.6, height: 1.25)),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('Coefficient 4 · Office du Baccalauréat\net des examens du Togo',
                                    style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 11, height: 1.5)),
                              ),
                              const SizedBox(height: 11),
                              Pill(label: 'Difficulté moyenne', bg: AppColors.gold500.withValues(alpha: .22), fg: const Color(0xFFFFD79A)),
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  Row(children: const [
                    StatTile(value: '12', label: 'Questions', valueColor: AppColors.kx700),
                    SizedBox(width: 9),
                    StatTile(value: '2 h', label: 'Durée'),
                    SizedBox(width: 9),
                    StatTile(value: '11,2', label: 'Moy. des élèves', valueColor: AppColors.ok600),
                  ]),
                  const SectionHeader(title: 'Comment ça se passe'),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        for (int i = 0; i < _steps.length; i++) ...[
                          _stepRow(_steps[i]),
                          if (i != _steps.length - 1) const Divider(height: 1, color: AppColors.line),
                        ],
                      ],
                    ),
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
                            'Compose dans les conditions de l\'examen : chrono lancé, sans revenir en arrière. Tu auras la correction expliquée à la fin.',
                            style: TextStyle(fontSize: 11, color: const Color(0xFF7A5400), height: 1.55),
                          ),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: AppColors.line)), boxShadow: [
            BoxShadow(color: AppColors.kx900.withValues(alpha: .1), blurRadius: 26, offset: const Offset(0, -8)),
          ]),
          child: Row(
            children: [
              SizedBox(width: 112, child: AppButton(label: 'Aperçu', icon: Icons.visibility_outlined, variant: AppButtonVariant.outline, height: 50, fontSize: 13.5, onPressed: () {})),
              const SizedBox(width: 11),
              Expanded(
                child: AppButton(
                  label: 'Commencer l\'épreuve',
                  icon: Icons.play_arrow_rounded,
                  height: 50,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExamQuestionScreen())),
                ),
              ),
            ],
          ),
        ),
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
