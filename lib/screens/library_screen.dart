import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart' show CircleIconButton;
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import 'exam_intro_screen.dart';
import 'offline_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String subjectFilter = 'Toutes matières';
  String yearFilter = '2024';

  static const _exams = [
    ('Mathématiques', AppColors.mathBlue, '12 questions', '2 h 00', null, Icons.check_circle, AppColors.ok600),
    ('Français', AppColors.frenchPurple, '8 questions', '3 h 00', '14/20', null, null),
    ('SVT', AppColors.svtGreen, '15 questions', '1 h 30', null, Icons.play_circle_outline, AppColors.kx600),
  ];

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
                    title: 'Annales BEPC',
                    showBack: false,
                    actions: [
                      CircleIconButton(
                          icon: Icons.grid_view_rounded,
                          ghost: true,
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OfflineScreen()))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .14),
                            border: Border.all(color: Colors.white.withValues(alpha: .22)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: .8), size: 19),
                              const SizedBox(width: 10),
                              Text('Matière, année, chapitre…', style: TextStyle(color: Colors.white.withValues(alpha: .68), fontSize: 14)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 13),
                        SizedBox(
                          height: 32,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: ['Toutes matières', 'Maths', 'Français', 'SVT']
                                .map((s) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: AppChip(
                                        label: s,
                                        height: 32,
                                        tone: s == subjectFilter ? ChipTone.darkOn : ChipTone.darkOff,
                                        onTap: () => setState(() => subjectFilter = s),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                children: [
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['Toutes', '2025', '2024', '2023', '2022', '2021']
                          .map((y) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: AppChip(label: y, height: 32, tone: y == yearFilter ? ChipTone.on : ChipTone.line, onTap: () => setState(() => yearFilter = y)),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink),
                          children: [
                            TextSpan(text: '42 annales ', style: TextStyle(color: AppColors.kx700)),
                            TextSpan(text: 'disponibles', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.filter_list_rounded, size: 13, color: AppColors.kx700),
                          SizedBox(width: 5),
                          Text('Plus récentes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.kx700)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final e in _exams) _examTile(e),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _examTile((String, Color, String, String, String?, IconData?, Color?) e) {
    final (name, color, q, dur, score, statusIcon, statusColor) = e;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: AppCard(
        padding: const EdgeInsets.all(11),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExamIntroScreen())),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExamCover(width: 60, height: 78, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      if (score != null)
                        Pill(label: 'Traitée · $score', bg: AppColors.ok100, fg: AppColors.ok600)
                      else if (statusIcon != null)
                        Icon(statusIcon, color: statusColor, size: 17),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('BEPC · Session 2024', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.format_list_bulleted_rounded, size: 13, color: AppColors.ink2),
                      const SizedBox(width: 5),
                      Text(q, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink2)),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded, size: 13, color: AppColors.ink2),
                      const SizedBox(width: 5),
                      Text(dur, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink2)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8C4D8)),
          ],
        ),
      ),
    );
  }
}
