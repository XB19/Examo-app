import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_header.dart';
import '../widgets/subject_icon.dart';
import 'exam_intro_screen.dart';
import 'notifications_screen.dart';
import 'offline_screen.dart';
import 'subject_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
                    child: Row(
                      children: [
                        CircleIconButton(icon: Icons.menu_rounded, ghost: true, size: 30, onPressed: () {}),
                        const SizedBox(width: 12),
                        const StudentAvatar(size: 42),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bonjour,', style: TextStyle(color: Colors.white.withValues(alpha: .74), fontSize: 11.5, fontWeight: FontWeight.w600)),
                              const Text('Koffi ADJOVI', style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                            ],
                          ),
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleIconButton(
                              icon: Icons.notifications_none_rounded,
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.gold500, shape: BoxShape.circle, border: Border.all(color: AppColors.kx700, width: 1.5))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        ProgressRing(
                          size: 100,
                          percent: 0.64,
                          center: const Text('64%', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -1)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ta préparation au BEPC', style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              const Text('Tu es prêt à 64 %', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('18 épreuves traitées · moyenne 11,4 / 20', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 11, height: 1.5)),
                              ),
                              const SizedBox(height: 9),
                              Pill(label: '5 jours d\'affilée', icon: Icons.local_fire_department_rounded, bg: AppColors.gold500.withValues(alpha: .22), fg: const Color(0xFFFFD79A)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  shadow: [BoxShadow(color: AppColors.kx900.withValues(alpha: .12), blurRadius: 26, offset: const Offset(0, 10))],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('REPRENDRE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: .6)),
                          Pill(label: 'EN COURS', bg: AppColors.warn100, fg: AppColors.warn600),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ExamCover(width: 56, height: 72, color: AppColors.mathBlue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mathématiques — BEPC 2024', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text('Question 7 sur 12 · 24 min restantes', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                                const SizedBox(height: 9),
                                const LinearBar(percent: 0.58),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      AppButton(
                        label: 'Continuer l\'épreuve',
                        icon: Icons.play_arrow_rounded,
                        height: 46,
                        fontSize: 14,
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExamIntroScreen())),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -36),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppCard(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubjectDetailScreen())),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(color: AppColors.gold100, borderRadius: BorderRadius.circular(11)),
                                  child: const Icon(Icons.track_changes_rounded, color: AppColors.gold600, size: 19),
                                ),
                                const SizedBox(height: 10),
                                const Text('Révision ciblée', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text('3 chapitres faibles', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppCard(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OfflineScreen())),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(color: AppColors.kx100, borderRadius: BorderRadius.circular(11)),
                                  child: const Icon(Icons.wifi_off_rounded, color: AppColors.kx700, size: 19),
                                ),
                                const SizedBox(height: 10),
                                const Text('Hors connexion', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text('6 annales prêtes', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SectionHeader(title: 'Tes matières', action: 'Tout voir', onAction: () {}),
                    _subjectRow(context, kSubjects[0], 72, '6 / 9 épreuves traitées'),
                    const SizedBox(height: 10),
                    _subjectRow(context, kSubjects[1], 52, '4 / 9 épreuves traitées'),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subjectRow(BuildContext context, SubjectMeta s, int pct, String sub) {
    return AppCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubjectDetailScreen())),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: s.color.withValues(alpha: .08), borderRadius: BorderRadius.circular(13)),
            child: Icon(s.icon, color: s.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    Text('$pct%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: s.color)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearBar(percent: pct / 100, color: s.color),
                const SizedBox(height: 6),
                Text(sub, style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
