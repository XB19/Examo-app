import 'package:flutter/material.dart';
import '../root_shell.dart';
import '../services/progress_store.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_header.dart';
import 'notifications_screen.dart';
import 'offline_screen.dart';
import 'subject_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final hasHistory = store.examCount > 0;
          final subjects = store.bySubject..sort((a, b) => b.count.compareTo(a.count));
          return SingleChildScrollView(
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
                                  const Text('Prêt(e) à t\'entraîner ?', style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                                ],
                              ),
                            ),
                            CircleIconButton(
                              icon: Icons.notifications_none_rounded,
                              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
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
                              percent: store.overallPercent,
                              center: Text(
                                hasHistory ? '${(store.overallPercent * 100).round()}%' : '–',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Ta préparation au CEPD', style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    hasHistory ? 'Tu es à ${(store.overallPercent * 100).round()} % de réussite' : 'Commence ta première épreuve',
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      hasHistory
                                          ? '${store.examCount} épreuve${store.examCount > 1 ? 's' : ''} traitée${store.examCount > 1 ? 's' : ''} · moyenne ${store.averageOn20.toStringAsFixed(1).replaceAll('.', ',')} / 20'
                                          : 'Choisis une annale dans l\'onglet Annales pour commencer.',
                                      style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 11, height: 1.5),
                                    ),
                                  ),
                                  if (store.streakDays > 0) ...[
                                    const SizedBox(height: 9),
                                    Pill(
                                      label: '${store.streakDays} jour${store.streakDays > 1 ? 's' : ''} d\'affilée',
                                      icon: Icons.local_fire_department_rounded,
                                      bg: AppColors.gold500.withValues(alpha: .22),
                                      fg: const Color(0xFFFFD79A),
                                    ),
                                  ],
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
                              Text('T\'ENTRAÎNER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: .6)),
                              Pill(label: 'CEPD', bg: AppColors.warn100, fg: AppColors.warn600),
                            ],
                          ),
                          const SizedBox(height: 11),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ExamCover(width: 56, height: 72, color: AppColors.mathBlue, year: '2025'),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Épreuves officielles du CEPD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 4),
                                    Text('Questions une par une, note et correction à la fin', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          AppButton(
                            label: 'Choisir une épreuve',
                            icon: Icons.play_arrow_rounded,
                            height: 46,
                            fontSize: 14,
                            onPressed: () => RootShell.openTab(context, RootShell.annalesTab),
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
                                onTap: () => RootShell.openTab(context, RootShell.progressTab),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(color: AppColors.gold100, borderRadius: BorderRadius.circular(11)),
                                      child: const Icon(Icons.bar_chart_rounded, color: AppColors.gold600, size: 19),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text('Ma progression', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(
                                      hasHistory ? '${subjects.length} matière${subjects.length > 1 ? 's' : ''} suivie${subjects.length > 1 ? 's' : ''}' : 'Pas encore de résultats',
                                      style: TextStyle(fontSize: 10.5, color: AppColors.muted),
                                    ),
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
                                    Text('Bientôt disponible', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SectionHeader(title: 'Tes matières', action: hasHistory ? 'Tout voir' : null, onAction: () => RootShell.openTab(context, RootShell.progressTab)),
                        if (!hasHistory)
                          AppCard(
                            color: AppColors.kx50,
                            borderColor: AppColors.kx100,
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: AppColors.kx700),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Tes matières apparaîtront ici dès que tu auras terminé une première épreuve.',
                                    style: TextStyle(fontSize: 12, color: AppColors.ink2, height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          for (final s in subjects.take(4)) ...[
                            _subjectRow(context, s),
                            const SizedBox(height: 10),
                          ],
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _subjectRow(BuildContext context, SubjectProgress s) {
    final pct = (s.averagePercent * 100).round();
    return AppCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SubjectDetailScreen(subjectCode: s.code, subjectName: s.name))),
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
                LinearBar(percent: s.averagePercent, color: s.color),
                const SizedBox(height: 6),
                Text('${s.count} épreuve${s.count > 1 ? 's' : ''} traitée${s.count > 1 ? 's' : ''}', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
