import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/app_field.dart';
import '../widgets/buttons.dart';
import '../widgets/gradient_header.dart';
import 'subjects_screen.dart';

/// Niveau d'examen préparé. Seul le CEPD a des annales réelles pour
/// l'instant : les autres sont affichés pour la feuille de route, mais
/// désactivés, plutôt que de mener à un écran suivant incohérent.
class ExamLevelScreen extends StatefulWidget {
  const ExamLevelScreen({super.key});

  @override
  State<ExamLevelScreen> createState() => _ExamLevelScreenState();
}

class _ExamLevelScreenState extends State<ExamLevelScreen> {
  int selected = 0; // CEPD

  static const _levels = [
    ('CEPD', 'Fin du primaire · CM2', Icons.school_outlined, true),
    ('BEPC', 'Fin du collège · 3ᵉ', Icons.import_contacts_rounded, false),
    ('BAC', 'Fin du lycée · Terminale', Icons.workspace_premium_outlined, false),
  ];

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
                  const HeaderNavBar(title: 'Mon examen', subtitle: 'Étape 1 sur 2'),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Row(
                      children: [
                        Expanded(child: _dash(true)),
                        const SizedBox(width: 6),
                        Expanded(child: _dash(false)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 22, 26, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quel examen prépares-tu ?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 7),
                    Text('Examo te proposera uniquement les annales de cet examen.',
                        style: TextStyle(fontSize: 13.5, color: AppColors.muted, height: 1.5)),
                    const SizedBox(height: 16),
                    for (int i = 0; i < _levels.length; i++) _levelTile(i),
                    const SizedBox(height: 20),
                    const Text('Année de l\'examen', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    const AppField(
                      icon: Icons.calendar_today_outlined,
                      value: 'Session de juin 2027',
                      trailing: Icon(Icons.expand_more_rounded, color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      color: AppColors.kx50,
                      borderColor: AppColors.kx100,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.kx700, size: 20),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              'Examo se concentre sur le CEPD pour l\'instant. Le BEPC et le BAC arrivent bientôt.',
                              style: TextStyle(fontSize: 11, color: AppColors.ink2, height: 1.55),
                            ),
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
          decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.line)), boxShadow: [
            BoxShadow(color: AppColors.kx900.withValues(alpha: .1), blurRadius: 26, offset: const Offset(0, -8)),
          ]),
          child: AppButton(
            label: 'Continuer',
            icon: Icons.arrow_forward_rounded,
            iconTrailing: true,
            height: 50,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => SubjectsScreen(level: _levels[selected].$1))),
          ),
        ),
      ),
    );
  }

  Widget _dash(bool on) => Container(height: 4, decoration: BoxDecoration(color: on ? AppColors.gold500 : Colors.white.withValues(alpha: .3), borderRadius: BorderRadius.circular(9)));

  Widget _levelTile(int i) {
    final (name, desc, icon, available) = _levels[i];
    final active = selected == i;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: available ? 1 : 0.55,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: available
              ? () => setState(() => selected = i)
              : () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$name arrive bientôt sur Examo.'), duration: const Duration(seconds: 2)),
                  ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: active ? AppColors.kx50 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: active ? AppColors.kx700 : AppColors.line, width: active ? 1.8 : 1.4),
              boxShadow: active ? [BoxShadow(color: AppColors.kx700.withValues(alpha: .07), blurRadius: 0, spreadRadius: 4)] : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: AppColors.kx100, borderRadius: BorderRadius.circular(13)),
                  child: Icon(icon, color: AppColors.kx700, size: 23),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                      const SizedBox(height: 3),
                      Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
                if (!available)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.muted.withValues(alpha: .12), borderRadius: BorderRadius.circular(8)),
                    child: const Text('Bientôt', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.muted)),
                  )
                else
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: active ? AppColors.kx700 : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: active ? AppColors.kx700 : const Color(0xFFCBD5E6), width: 1.8),
                    ),
                    child: active ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
