import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import 'ai_explain_text_screen.dart';

class CorrectionScreen extends StatelessWidget {
  const CorrectionScreen({super.key});

  static const _tracker = [
    (1, true), (2, true), (3, false), (4, true), (5, true), (6, true),
    (7, false), (8, true), (9, true), (10, true), (11, false), (12, true),
  ];

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
                    title: 'Correction',
                    subtitle: 'Mathématiques · BEPC 2024 · 13/20',
                    actions: [CircleIconButton(icon: Icons.format_list_bulleted_rounded, ghost: true, onPressed: () {})],
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      children: _tracker.map((t) {
                        final (n, ok) = t;
                        final active = n == 3;
                        Color bg = ok ? AppColors.ok100 : AppColors.crim100;
                        Color fg = ok ? AppColors.ok600 : AppColors.crim600;
                        if (active) {
                          bg = AppColors.crim600;
                          fg = Colors.white;
                        }
                        return Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: active ? [BoxShadow(color: AppColors.crim600.withValues(alpha: .22), blurRadius: 0, spreadRadius: 3)] : null,
                          ),
                          child: Text('$n', style: TextStyle(fontSize: 11.5, fontWeight: active ? FontWeight.w800 : FontWeight.w700, color: fg)),
                        );
                      }).toList(),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppChip(label: 'Réponse fausse', icon: Icons.cancel_outlined, tone: ChipTone.crim, height: 28),
                      const SizedBox(width: 8),
                      const AppChip(label: '0 / 2 pt', tone: ChipTone.line, height: 28),
                      const Spacer(),
                      const Text('Question 3', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 13),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.55, color: AppColors.ink, letterSpacing: -0.15),
                      children: [
                        TextSpan(text: 'Dans la figure, (MN) est parallèle à (BC). AM = 3 cm, AB = 9 cm et AN = 4 cm. '),
                        TextSpan(text: 'Calcule AC.', style: TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                    decoration: BoxDecoration(color: AppColors.crim100, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFF3C9C4))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Icon(Icons.cancel_outlined, color: AppColors.crim600, size: 16),
                          SizedBox(width: 8),
                          Text('TA RÉPONSE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.crim700, letterSpacing: .5)),
                        ]),
                        const SizedBox(height: 8),
                        const Text('AC = 4 × 3 ÷ 9 = 1,33 cm', style: TextStyle(fontSize: 14.5, height: 1.5, color: Color(0xFF7A1B14), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 11),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                    decoration: BoxDecoration(color: AppColors.ok100, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFB9E3CE))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [
                          Icon(Icons.check_circle_outline_rounded, color: AppColors.ok600, size: 16),
                          SizedBox(width: 8),
                          Text('RÉPONSE ATTENDUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0E5C3E), letterSpacing: .5)),
                        ]),
                        const SizedBox(height: 8),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14.5, height: 1.7, color: Color(0xFF0E5C3E), fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(text: 'D\'après le théorème de Thalès : AM / AB = AN / AC\ndonc AC = (AB × AN) / AM = (9 × 4) / 3 = '),
                              TextSpan(text: '12 cm', style: TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
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
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tu as inversé le rapport', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF5E4200))),
                                  SizedBox(height: 4),
                                  Text('Examo peut t\'expliquer ton erreur pas à pas', style: TextStyle(fontSize: 11, color: Color(0xFF7A5400), height: 1.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        AppButton(
                          label: 'Comprendre mon erreur',
                          icon: Icons.track_changes_rounded,
                          variant: AppButtonVariant.gold,
                          height: 46,
                          fontSize: 14,
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiExplainTextScreen())),
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
              Expanded(child: AppButton(label: 'Question 2', icon: Icons.arrow_back_rounded, variant: AppButtonVariant.outline, height: 50, fontSize: 13.5, onPressed: () {})),
              const SizedBox(width: 11),
              Expanded(child: AppButton(label: 'Question 4', icon: Icons.arrow_forward_rounded, iconTrailing: true, height: 50, fontSize: 13.5, onPressed: () {})),
            ],
          ),
        ),
      ),
    );
  }
}
