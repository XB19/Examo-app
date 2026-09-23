import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/gradient_header.dart';
import '../root_shell.dart';
import '../widgets/subject_icon.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final Set<int> selected = {0, 1, 2, 3};
  bool reminder = true;

  static const _coefs = [4, 3, 2, 2, 2, 2];

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 22, 26, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Que veux-tu travailler ?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 7),
                    Text('Choisis au moins trois matières. Examo te proposera les annales et les révisions correspondantes.',
                        style: TextStyle(fontSize: 13.5, color: AppColors.muted, height: 1.5)),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(kSubjects.length, (i) => _subjectTile(i)),
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 14),
                    AppCard(
                      color: AppColors.kx50,
                      borderColor: AppColors.kx100,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.kx700, size: 20),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text('Tu pourras ajouter ou retirer des matières à tout moment depuis ton profil.',
                                style: TextStyle(fontSize: 11, color: AppColors.ink2, height: 1.55)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

  Widget _subjectTile(int i) {
    final s = kSubjects[i];
    final active = selected.contains(i);
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 26 * 2 - 12) / 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => setState(() => active ? selected.remove(i) : selected.add(i)),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: active ? s.color.withValues(alpha: .055) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: active ? s.color : AppColors.line, width: active ? 1.8 : 1.4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: s.color.withValues(alpha: .1), borderRadius: BorderRadius.circular(11)),
                    child: Icon(s.icon, color: s.color, size: 18),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: active ? s.color : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: active ? s.color : const Color(0xFFCBD5E6), width: 1.8),
                    ),
                    child: active ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.3)),
              const SizedBox(height: 3),
              Text('coef. ${_coefs[i]}', style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}
