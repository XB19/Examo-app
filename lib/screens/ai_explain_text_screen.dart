import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/app_field.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import 'ai_explain_voice_screen.dart';

class AiExplainTextScreen extends StatelessWidget {
  const AiExplainTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
              child: Column(
                children: [
                  HeaderNavBar(
                    title: 'Examo t\'explique',
                    actions: [CircleIconButton(icon: Icons.bookmark_border_rounded, ghost: true, onPressed: () {})],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.gold500.withValues(alpha: .2),
                            border: Border.all(color: AppColors.gold500.withValues(alpha: .4)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.track_changes_rounded, color: Color(0xFFFFD79A), size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Question 3 · Théorème de Thalès', style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)),
                              SizedBox(height: 3),
                              Text('Explication adaptée à ton niveau · 3ᵉ', style: TextStyle(color: Color(0xC7FFFFFF), fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Expanded(
                          child: Container(
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.menu_book_rounded, size: 15, color: AppColors.kx700),
                              SizedBox(width: 7),
                              Text('Lire', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.kx700)),
                            ]),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AiExplainVoiceScreen())),
                            child: Container(
                              height: 34,
                              alignment: Alignment.center,
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.graphic_eq_rounded, size: 15, color: Colors.white70),
                                const SizedBox(width: 7),
                                Text('Écouter', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: .84))),
                              ]),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  _bubble('Salut Koffi. Ton erreur est courante, et elle se corrige vite.\n\nTu as écrit 4 × 3 ÷ 9 : tu as multiplié par le petit côté et divisé par le grand. C\'est l\'inverse.'),
                  const SizedBox(height: 12),
                  _bubble('Regarde : AB = 9 cm est trois fois plus grand que AM = 3 cm. Donc AC doit être trois fois plus grand que AN = 4 cm, soit 12 cm.'),
                  Padding(
                    padding: const EdgeInsets.only(left: 42, top: 9),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LA BONNE MÉTHODE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: .5)),
                          const SizedBox(height: 9),
                          _step('1', 'J\'écris le rapport : AM / AB = AN / AC'),
                          _step('2', 'Je remplace : 3 / 9 = 4 / AC'),
                          _step('3', 'Je fais le produit en croix : 3 × AC = 9 × 4'),
                          _step('4', 'Je divise : AC = 36 / 3 = 12 cm'),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 42, top: 12),
                    child: Wrap(spacing: 9, runSpacing: 9, children: const [
                      AppChip(label: 'Réexplique autrement', icon: Icons.refresh_rounded, tone: ChipTone.line, height: 34),
                      AppChip(label: 'Exercice similaire', icon: Icons.track_changes_rounded, tone: ChipTone.line, height: 34),
                      AppChip(label: 'Rappel du cours', icon: Icons.import_contacts_rounded, tone: ChipTone.line, height: 34),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Text('Tu as compris cette explication ?', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 11),
                        Row(children: [
                          Expanded(
                            child: SmallButton(label: 'Oui, c\'est clair', icon: Icons.check_rounded, color: AppColors.ok600, onPressed: () {}),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SmallButton(label: 'Pas encore', icon: Icons.help_outline_rounded, onPressed: () {}),
                          ),
                        ]),
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
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
          decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: AppColors.line)), boxShadow: [
            BoxShadow(color: AppColors.kx900.withValues(alpha: .1), blurRadius: 26, offset: const Offset(0, -8)),
          ]),
          child: Row(
            children: [
              const Expanded(
                child: AppField(icon: Icons.mic_none_rounded, isPlaceholder: true, value: 'Pose ta question à Examo…', height: 48),
              ),
              const SizedBox(width: 10),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppColors.kx700, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubble(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: AppColors.kx700, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.track_changes_rounded, color: AppColors.gold500, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.kx50,
              border: Border.all(color: AppColors.kx100),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(text, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.ink)),
          ),
        ),
      ],
    );
  }

  Widget _step(String n, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, height: 1.7, color: AppColors.ink),
          children: [
            TextSpan(text: '$n. ', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
            TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
