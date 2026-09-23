import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/diagrams.dart';
import '../widgets/gradient_header.dart';
import 'result_screen.dart';

class PhotoReviewScreen extends StatelessWidget {
  const PhotoReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    title: 'Ta réponse photographiée',
                    subtitle: 'Question 7 sur 12 · Mathématiques',
                    actions: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold500.withValues(alpha: .22),
                          border: Border.all(color: AppColors.gold500.withValues(alpha: .45)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(children: [
                          Icon(Icons.access_time_rounded, size: 14, color: Color(0xFFFFD79A)),
                          SizedBox(width: 5),
                          Text('21:46', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFFFFD79A))),
                        ]),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: List.generate(12, (i) {
                        Color c;
                        if (i < 6) {
                          c = AppColors.gold500;
                        } else if (i == 6) {
                          c = Colors.white;
                        } else {
                          c = Colors.white.withValues(alpha: .26);
                        }
                        return Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 1.5), height: 4, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(9))));
                      }),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: const NotebookPage(width: 118, height: 152),
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: .55), borderRadius: BorderRadius.circular(7)),
                              child: const Text('1 / 1', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppChip(label: 'Page lue', icon: Icons.check_circle_outline, tone: ChipTone.ok, height: 28),
                            const SizedBox(height: 11),
                            const Text('Examo a reconnu ton écriture', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, height: 1.4)),
                            const SizedBox(height: 6),
                            Text('Vérifie la transcription avant d\'envoyer. Tu peux corriger un mot si la lecture est fausse.',
                                style: TextStyle(fontSize: 10.5, color: AppColors.muted, height: 1.55)),
                            const SizedBox(height: 11),
                            Row(children: [
                              const AppChip(label: 'Reprendre', icon: Icons.refresh_rounded, tone: ChipTone.line, height: 30),
                              const SizedBox(width: 7),
                              const AppChip(label: 'Page', icon: Icons.add, tone: ChipTone.line, height: 30),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TRANSCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: .6)),
                      const Row(children: [
                        Icon(Icons.verified_rounded, size: 13, color: AppColors.ok600),
                        SizedBox(width: 5),
                        Text('Lecture sûre à 96 %', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.ok600)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.kx300),
                      boxShadow: [BoxShadow(color: AppColors.kx700.withValues(alpha: .06), blurRadius: 0, spreadRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14.5, height: 1.85, color: AppColors.ink),
                            children: [
                              const TextSpan(text: 'D\'après le théorème de Pythagore :\nBC² = 8² + 6²\n= 64 + 36 = 100\nBC = √100 = '),
                              TextSpan(
                                text: '10 cm',
                                style: TextStyle(backgroundColor: AppColors.gold100, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppColors.line),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.warn600, size: 16),
                            const SizedBox(width: 9),
                            Expanded(
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 11, color: AppColors.ink2, height: 1.5),
                                  children: [
                                    TextSpan(text: 'Un mot a été lu avec hésitation : '),
                                    TextSpan(text: '« 10 cm »', style: TextStyle(fontWeight: FontWeight.w800)),
                                    TextSpan(text: '. Touche-le pour le corriger.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(children: [
                    Expanded(child: AppButton(label: 'Corriger le texte', icon: Icons.edit_outlined, variant: AppButtonVariant.outline, height: 44, fontSize: 13, onPressed: () {})),
                    const SizedBox(width: 10),
                    Expanded(child: AppButton(label: 'Voir la photo', icon: Icons.visibility_outlined, variant: AppButtonVariant.outline, height: 44, fontSize: 13, onPressed: () {})),
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
          child: AppButton(
            label: 'Envoyer ma réponse',
            icon: Icons.send_rounded,
            height: 50,
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ResultScreen())),
          ),
        ),
      ),
    );
  }
}
