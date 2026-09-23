import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/section_header.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  static const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  static const _done = [true, true, true, true, true, false, false];

  static const _badges = [
    ('Première annale', Icons.emoji_events_outlined, AppColors.gold500, true),
    ('5 jours d\'affilée', Icons.local_fire_department_rounded, AppColors.crim600, true),
    ('10 épreuves', Icons.import_contacts_rounded, AppColors.mathBlue, true),
    ('Moyenne > 12', Icons.track_changes_rounded, AppColors.svtGreen, false),
    ('Toutes les matières', Icons.school_outlined, AppColors.frenchPurple, false),
    ('30 jours', Icons.calendar_today_outlined, AppColors.muted, false),
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
                    title: 'Mes objectifs',
                    showBack: false,
                    actions: [CircleIconButton(icon: Icons.settings_outlined, ghost: true, onPressed: () {})],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.gold500.withValues(alpha: .2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold500.withValues(alpha: .45), width: 1.5),
                        ),
                        child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFFD79A), size: 36),
                      ),
                      const SizedBox(height: 11),
                      const Text('5 jours', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1.2)),
                      Text('d\'entraînement sans interruption', style: TextStyle(color: Colors.white.withValues(alpha: .84), fontSize: 13)),
                      const SizedBox(height: 7),
                      Text('Ton record : 12 jours', style: TextStyle(color: Colors.white.withValues(alpha: .7), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Cette semaine', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            Text('22 – 28 sept.', style: TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(7, (i) {
                            final done = _done[i];
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: done ? AppColors.kx700 : Colors.white,
                                        borderRadius: BorderRadius.circular(13),
                                        border: done ? null : Border.all(color: AppColors.line, width: 1.4),
                                      ),
                                      child: done ? const Icon(Icons.local_fire_department_rounded, color: AppColors.gold500, size: 20) : null,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(_days[i], style: TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: done ? FontWeight.w700 : FontWeight.w600)),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Objectif hebdomadaire', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            Text('2 / 3 épreuves', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.kx700)),
                          ],
                        ),
                        const SizedBox(height: 11),
                        const LinearBar(percent: 0.67, color: AppColors.gold500, height: 9),
                        const SizedBox(height: 9),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.5),
                            children: [
                              TextSpan(text: 'Encore '),
                              TextSpan(text: 'une épreuve', style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
                              TextSpan(text: ' avant dimanche pour tenir ton objectif.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppButton(label: 'Modifier mon objectif', variant: AppButtonVariant.outline, height: 42, fontSize: 13, onPressed: () {}),
                      ],
                    ),
                  ),
                  const SectionHeader(title: 'Tes distinctions', action: '3 / 6'),
                  Wrap(
                    spacing: 12,
                    runSpacing: 16,
                    children: _badges.map((b) {
                      final (label, icon, color, unlocked) = b;
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 40 - 24) / 3,
                        child: Opacity(
                          opacity: unlocked ? 1 : 0.42,
                          child: Column(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(17)),
                                child: Icon(icon, color: color, size: 25),
                              ),
                              const SizedBox(height: 7),
                              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, height: 1.35)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
