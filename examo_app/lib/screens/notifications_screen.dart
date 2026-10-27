import 'package:flutter/material.dart';
import '../services/progress_store.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';

/// Générées à partir de l'historique local des épreuves (pas de flux de
/// notifications côté serveur pour l'instant) : "correction prête" dès
/// qu'une copie est notée, et un rappel d'objectif s'il reste du chemin.
class _Notif {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final DateTime at;
  const _Notif(this.icon, this.color, this.title, this.desc, this.at);
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ProgressStore.instance;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final notifs = _build(store);
            final now = DateTime.now();
            final today = notifs.where((n) => _isSameDay(n.at, now)).toList();
            final earlier = notifs.where((n) => !_isSameDay(n.at, now)).toList();

            return Column(
              children: [
                GradientHeaderShell(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
                  child: Column(
                    children: [
                      HeaderNavBar(
                        title: 'Notifications',
                        actions: [CircleIconButton(icon: Icons.settings_outlined, ghost: true, onPressed: () {})],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Row(children: [
                          AppChip(label: 'Toutes · ${notifs.length}', tone: ChipTone.darkOn, height: 32),
                        ]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: notifs.isEmpty
                      ? _empty()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          children: [
                            if (today.isNotEmpty) ...[
                              const Text('AUJOURD\'HUI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: .7)),
                              const SizedBox(height: 12),
                              for (final n in today) _tile(n, unread: true),
                            ],
                            if (earlier.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text('PLUS TÔT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: .7)),
                              ),
                              for (final n in earlier) _tile(n, unread: false),
                            ],
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

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  List<_Notif> _build(ProgressStore store) {
    final notifs = <_Notif>[];
    final recent = store.items.take(8);
    for (final e in recent) {
      final pending = e.pendingSelfChecks > 0;
      notifs.add(_Notif(
        pending ? Icons.fact_check_outlined : Icons.check_circle_outline_rounded,
        pending ? AppColors.warn600 : AppColors.ok600,
        pending ? 'À vérifier toi-même' : 'Correction prête',
        pending
            ? 'Ton épreuve de ${e.subjectName} attend que tu pointes tes réponses.'
            : 'Ton épreuve de ${e.subjectName}${e.sessionYear != null ? ' (${e.sessionYear})' : ''} est corrigée : ${e.scoreOn20.toStringAsFixed(1).replaceAll('.', ',')}/20.',
        e.completedAt,
      ));
    }
    if (store.examCount > 0 && store.examsThisWeek < store.weeklyGoal) {
      final remaining = store.weeklyGoal - store.examsThisWeek;
      notifs.add(_Notif(
        Icons.track_changes_rounded,
        AppColors.gold600,
        'Objectif de la semaine',
        'Encore $remaining épreuve${remaining > 1 ? 's' : ''} pour atteindre ton objectif hebdomadaire.',
        DateTime.now(),
      ));
    }
    notifs.sort((a, b) => b.at.compareTo(a.at));
    return notifs;
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none_rounded, size: 40, color: AppColors.kx300),
            const SizedBox(height: 12),
            const Text('Aucune notification', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Tu seras prévenu(e) ici dès qu\'une copie sera corrigée.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _tile(_Notif n, {required bool unread}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        color: unread ? AppColors.kx50 : Colors.white,
        borderColor: unread ? AppColors.kx100 : AppColors.line,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: n.color.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
              child: Icon(n.icon, color: n.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(n.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700))),
                      if (unread)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 6),
                          child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.gold500, shape: BoxShape.circle)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.desc, style: const TextStyle(fontSize: 11, color: AppColors.ink2, height: 1.5)),
                  const SizedBox(height: 6),
                  Text(_relativeTime(n.at), style: const TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime at) {
    final diff = DateTime.now().difference(at);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    return 'il y a ${diff.inDays} j';
  }
}
