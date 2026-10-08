import 'package:flutter/material.dart';
import '../services/progress_store.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/section_header.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  static const _dayLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final unlocked = store.unlockedBadges;
            final activity = store.weekActivity;
            final weekRange = _weekRangeLabel();
            return Column(
              children: [
                GradientHeaderShell(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                  child: Column(
                    children: [
                      const HeaderNavBar(title: 'Mes objectifs', showBack: false),
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
                          Text(
                            store.streakDays > 0 ? '${store.streakDays} jour${store.streakDays > 1 ? 's' : ''}' : '0 jour',
                            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1.2),
                          ),
                          Text(
                            store.streakDays > 0 ? 'd\'entraînement sans interruption' : 'Termine une épreuve pour démarrer ta série',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withValues(alpha: .84), fontSize: 13),
                          ),
                          if (store.bestStreak > 0) ...[
                            const SizedBox(height: 7),
                            Text('Ton record : ${store.bestStreak} jour${store.bestStreak > 1 ? 's' : ''}', style: TextStyle(color: Colors.white.withValues(alpha: .7), fontSize: 11)),
                          ],
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
                              children: [
                                const Text('Cette semaine', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                Text(weekRange, style: const TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: List.generate(7, (i) {
                                final done = activity[i];
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
                                        Text(_dayLetters[i], style: TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: done ? FontWeight.w700 : FontWeight.w600)),
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
                              children: [
                                const Text('Objectif hebdomadaire', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                Text('${store.examsThisWeek} / ${store.weeklyGoal} épreuves', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.kx700)),
                              ],
                            ),
                            const SizedBox(height: 11),
                            LinearBar(percent: store.weeklyGoal == 0 ? 0 : store.examsThisWeek / store.weeklyGoal, color: AppColors.gold500, height: 9),
                            const SizedBox(height: 9),
                            Text(
                              store.examsThisWeek >= store.weeklyGoal
                                  ? 'Objectif de la semaine atteint, bravo !'
                                  : 'Encore ${store.weeklyGoal - store.examsThisWeek} épreuve${(store.weeklyGoal - store.examsThisWeek) > 1 ? 's' : ''} pour tenir ton objectif.',
                              style: const TextStyle(fontSize: 11, color: AppColors.muted, height: 1.5),
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'Modifier mon objectif',
                              variant: AppButtonVariant.outline,
                              height: 42,
                              fontSize: 13,
                              onPressed: () => _editGoal(context, store),
                            ),
                          ],
                        ),
                      ),
                      SectionHeader(title: 'Tes distinctions', action: '${unlocked.length} / ${badgeCatalog.length}'),
                      Wrap(
                        spacing: 12,
                        runSpacing: 16,
                        children: badgeCatalog.map((b) {
                          final isUnlocked = unlocked.contains(b.badge);
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 40 - 24) / 3,
                            child: Opacity(
                              opacity: isUnlocked ? 1 : 0.42,
                              child: Column(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: isUnlocked ? b.color.withValues(alpha: .1) : AppColors.muted.withValues(alpha: .1),
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    child: Icon(b.icon, color: isUnlocked ? b.color : AppColors.muted, size: 25),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(b.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, height: 1.35)),
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
            );
          },
        ),
      ),
    );
  }

  String _weekRangeLabel() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    const months = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    return '${monday.day} – ${sunday.day} ${months[sunday.month - 1]}';
  }

  Future<void> _editGoal(BuildContext context, ProgressStore store) async {
    final choice = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Combien d\'épreuves par semaine ?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              for (final n in [2, 3, 5, 7])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppButton(
                    label: '$n épreuve${n > 1 ? 's' : ''} / semaine',
                    variant: n == store.weeklyGoal ? AppButtonVariant.primary : AppButtonVariant.outline,
                    height: 48,
                    onPressed: () => Navigator.pop(context, n),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (choice != null) await store.setWeeklyGoal(choice);
  }
}
