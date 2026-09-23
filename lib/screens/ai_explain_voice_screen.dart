import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/section_header.dart';
import 'ai_explain_text_screen.dart';

class AiExplainVoiceScreen extends StatelessWidget {
  const AiExplainVoiceScreen({super.key});

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
                    title: 'Examo t\'explique',
                    actions: [CircleIconButton(icon: Icons.bookmark_border_rounded, ghost: true, onPressed: () {})],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AiExplainTextScreen())),
                            child: Container(
                              height: 34,
                              alignment: Alignment.center,
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.menu_book_rounded, size: 15, color: Colors.white70),
                                const SizedBox(width: 7),
                                Text('Lire', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: .84))),
                              ]),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.graphic_eq_rounded, size: 15, color: AppColors.kx700),
                              SizedBox(width: 7),
                              Text('Écouter', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.kx700)),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: AppColors.gold500.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.gold500.withValues(alpha: .42)),
                    ),
                    child: const Icon(Icons.track_changes_rounded, color: Color(0xFFFFD79A), size: 46),
                  ),
                  const SizedBox(height: 14),
                  const Text('Examo t\'explique à voix haute', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 18),
                    child: Text('Question 3 · Théorème de Thalès · 1 min 18', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 11)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Waveform(progress: 0.55),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 6, 22, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0:42', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 11)),
                        Text('1:18', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 11)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _round('0.8×', 46),
                      _round(null, 46, icon: Icons.replay_rounded),
                      _round(null, 68, icon: Icons.pause_rounded, primary: true),
                      _round(null, 46, icon: Icons.menu_book_rounded),
                      _round(null, 46, icon: Icons.file_download_outlined),
                    ],
                  ),
                  const SectionHeader(title: 'Transcription', action: 'Suivre'),
                  AppCard(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Salut Koffi. Ton erreur est courante, et elle se corrige vite.',
                            style: TextStyle(fontSize: 14, height: 1.75, color: AppColors.muted)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(color: AppColors.gold100, borderRadius: BorderRadius.circular(7)),
                          child: const Text('Tu as multiplié par le petit côté et divisé par le grand. C\'est l\'inverse.',
                              style: TextStyle(fontSize: 14, height: 1.75, color: AppColors.ink, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 10),
                        Text('AB est trois fois plus grand que AM, donc AC doit être trois fois plus grand que AN.',
                            style: TextStyle(fontSize: 14, height: 1.75, color: AppColors.muted)),
                        const SizedBox(height: 10),
                        Text('Cela donne douze centimètres, et pas un virgule trente-trois.',
                            style: TextStyle(fontSize: 14, height: 1.75, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  Wrap(spacing: 9, runSpacing: 9, children: const [
                    AppChip(label: 'Poser une question à l\'oral', icon: Icons.mic_none_rounded, tone: ChipTone.line, height: 34),
                    AppChip(label: 'Exercice similaire', icon: Icons.track_changes_rounded, tone: ChipTone.line, height: 34),
                  ]),
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
              SizedBox(width: 116, child: AppButton(label: 'Refaire', icon: Icons.refresh_rounded, variant: AppButtonVariant.outline, height: 50, fontSize: 13.5, onPressed: () {})),
              const SizedBox(width: 11),
              Expanded(child: AppButton(label: 'J\'ai compris, question suivante', height: 50, fontSize: 13.5, onPressed: () => Navigator.of(context).maybePop())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _round(String? text, double size, {IconData? icon, bool primary = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primary ? AppColors.kx700 : AppColors.bg,
        shape: BoxShape.circle,
        boxShadow: primary ? [BoxShadow(color: AppColors.kx700.withValues(alpha: .3), blurRadius: 22, offset: const Offset(0, 8))] : null,
      ),
      alignment: Alignment.center,
      child: text != null
          ? Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.ink2))
          : Icon(icon, color: primary ? Colors.white : AppColors.ink2, size: primary ? 28 : 21),
    );
  }
}
