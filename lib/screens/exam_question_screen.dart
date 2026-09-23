import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/diagrams.dart';
import '../widgets/gradient_header.dart';
import 'photo_capture_screen.dart';
import 'result_screen.dart';

class ExamQuestionScreen extends StatefulWidget {
  const ExamQuestionScreen({super.key});

  @override
  State<ExamQuestionScreen> createState() => _ExamQuestionScreenState();
}

class _ExamQuestionScreenState extends State<ExamQuestionScreen> {
  static const _symbols = ['√', 'x²', 'π', '≠', '≤', '⊥'];

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
                    title: 'Question 7 sur 12',
                    subtitle: 'Mathématiques · BEPC 2024',
                    showBack: true,
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
                          Text('24:18', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFFFFD79A))),
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
                        return Expanded(
                          child: Container(margin: const EdgeInsets.symmetric(horizontal: 1.5), height: 4, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(9))),
                        );
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppChip(label: 'Activités géométriques', height: 28),
                      const Text('2 points', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.55, color: AppColors.ink, letterSpacing: -0.2),
                      children: [
                        TextSpan(text: 'ABC est un triangle rectangle en A tel que AB = 8 cm et AC = 6 cm.\n'),
                        TextSpan(text: 'Calcule la longueur BC', style: TextStyle(fontWeight: FontWeight.w800)),
                        TextSpan(text: ' et justifie ta réponse.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
                    child: const Center(child: RightTriangleDiagram()),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TA RÉPONSE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: .6)),
                      Row(children: [
                        const AppChip(label: 'Taper', icon: Icons.keyboard_alt_outlined, tone: ChipTone.on, height: 30),
                        const SizedBox(width: 7),
                        AppChip(
                          label: 'Photo',
                          icon: Icons.camera_alt_outlined,
                          tone: ChipTone.line,
                          height: 30,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PhotoCaptureScreen())),
                        ),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 118),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.kx300),
                      boxShadow: [BoxShadow(color: AppColors.kx700.withValues(alpha: .06), blurRadius: 0, spreadRadius: 4)],
                    ),
                    child: const Text(
                      'D\'après le théorème de Pythagore :\nBC² = AB² + AC² = 64 + 36 = 100\nDonc BC = 10 cm',
                      style: TextStyle(fontSize: 14, height: 1.65, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: _symbols
                        .map((s) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: Container(
                                  height: 34,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), border: Border.all(color: AppColors.line)),
                                  child: Text(s, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 13),
                  AppCard(
                    color: AppColors.kx50,
                    borderColor: AppColors.kx100,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PhotoCaptureScreen())),
                    child: Row(
                      children: [
                        const Icon(Icons.camera_alt_outlined, color: AppColors.kx700, size: 19),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Tu préfères écrire dans ton cahier ?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              SizedBox(height: 3),
                              Text('Prends ta page en photo, Examo la lira', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8C4D8)),
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
              SizedBox(width: 112, child: AppButton(label: 'Passer', variant: AppButtonVariant.outline, height: 50, fontSize: 13.5, onPressed: () {})),
              const SizedBox(width: 11),
              Expanded(
                child: AppButton(
                  label: 'Valider ma réponse',
                  height: 50,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResultScreen())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
