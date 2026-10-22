import 'package:flutter/material.dart';
import '../models/exam.dart';
import '../services/exam_api.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/gradient_header.dart';
import '../root_shell.dart';

class _SubjectOption {
  final String code;
  final String name;
  final int examCount;
  const _SubjectOption(this.code, this.name, this.examCount);

  Color get color => subjectColor(code);
  IconData get icon => subjectIcon(code);
}

/// Le programme d'un examen national a un contenu fixe (pas de "choix" comme
/// une série de lycée) : on affiche les vraies épreuves du niveau choisi,
/// toutes pré-sélectionnées, plutôt qu'une liste de matières de collège
/// sans rapport avec le niveau que l'élève vient de choisir.
class SubjectsScreen extends StatefulWidget {
  final String level;
  const SubjectsScreen({super.key, this.level = 'CEPD'});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  bool reminder = true;
  late Future<List<_SubjectOption>> _future;
  Set<String> selected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ExamApi.fetchExams(level: widget.level).then((exams) {
      final byCode = <String, List<Exam>>{};
      for (final e in exams) {
        byCode.putIfAbsent(e.subjectCode, () => []).add(e);
      }
      final options = [
        for (final entry in byCode.entries) _SubjectOption(entry.key, entry.value.first.subjectName, entry.value.length),
      ];
      options.sort((a, b) {
        final ia = cepdSubjectCodes.indexOf(a.code);
        final ib = cepdSubjectCodes.indexOf(b.code);
        if (ia == -1 || ib == -1) return a.name.compareTo(b.name);
        return ia.compareTo(ib);
      });
      selected = options.map((o) => o.code).toSet();
      return options;
    });
  }

  void _finish(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const RootShell()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: Column(
                children: [
                  const HeaderNavBar(title: 'Mes matières', subtitle: 'Étape 2 sur 2'),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Row(
                      children: [
                        Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.gold500, borderRadius: BorderRadius.circular(9)))),
                        const SizedBox(width: 6),
                        Expanded(child: Container(height: 4, decoration: BoxDecoration(color: AppColors.gold500, borderRadius: BorderRadius.circular(9)))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<_SubjectOption>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.kx700));
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(28),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.kx300),
                            const SizedBox(height: 12),
                            const Text('Impossible de charger le programme', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            const Text('Vérifie ta connexion internet puis réessaie.',
                                textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
                            const SizedBox(height: 14),
                            AppButton(label: 'Réessayer', icon: Icons.refresh_rounded, height: 44, onPressed: () => setState(_load)),
                          ],
                        ),
                      ),
                    );
                  }
                  final options = snapshot.data ?? const [];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(26, 22, 26, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Le programme du ${widget.level}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                        const SizedBox(height: 7),
                        Text(
                          'Voici les épreuves officielles. Elles sont toutes incluses : décoche celles que tu veux réviser plus tard.',
                          style: TextStyle(fontSize: 13.5, color: AppColors.muted, height: 1.5),
                        ),
                        const SizedBox(height: 18),
                        for (final o in options) _subjectRow(o),
                        const SizedBox(height: 6),
                        const Text('Rappel d\'entraînement', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        AppCard(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(color: AppColors.gold100, borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.notifications_active_outlined, color: AppColors.gold600, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Me rappeler chaque jour', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                    SizedBox(height: 3),
                                    Text('Tous les jours à 18 h', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                                  ],
                                ),
                              ),
                              Switch(value: reminder, activeTrackColor: AppColors.kx700, onChanged: (v) => setState(() => reminder = v)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
              SizedBox(width: 110, child: AppButton(label: 'Plus tard', variant: AppButtonVariant.outline, height: 50, onPressed: () => _finish(context))),
              const SizedBox(width: 11),
              Expanded(child: AppButton(label: 'Commencer', height: 50, onPressed: () => _finish(context))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subjectRow(_SubjectOption o) {
    final active = selected.contains(o.code);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => setState(() => active ? selected.remove(o.code) : selected.add(o.code)),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: active ? o.color.withValues(alpha: .055) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: active ? o.color : AppColors.line, width: active ? 1.8 : 1.4),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: o.color.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
                child: Icon(o.icon, color: o.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${o.examCount} annale${o.examCount > 1 ? 's' : ''}', style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: active ? o.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: active ? o.color : const Color(0xFFCBD5E6), width: 1.8),
                ),
                child: active ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
