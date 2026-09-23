import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/gradient_header.dart';
import '../widgets/section_header.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int expanded = 1;

  static const _faq = [
    'Comment Examo lit-il mon écriture manuscrite ?',
    'Puis-je utiliser Examo sans connexion internet ?',
    'Examo est-il payant ?',
    'Puis-je répondre en photographiant mon cahier ?',
    'Comment changer d\'examen ou de série ?',
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
                  const HeaderNavBar(title: 'Aide'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Une question ?\nOn est là.', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.3)),
                        const SizedBox(height: 14),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), border: Border.all(color: Colors.white.withValues(alpha: .22)), borderRadius: BorderRadius.circular(14)),
                          child: Row(children: [
                            Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: .8), size: 19),
                            const SizedBox(width: 10),
                            Text('Rechercher dans l\'aide…', style: TextStyle(color: Colors.white.withValues(alpha: .68), fontSize: 14)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  Row(children: [
                    Expanded(child: _quickCard('Demander à Examo', 'Réponse immédiate', Icons.track_changes_rounded, primary: true)),
                    const SizedBox(width: 11),
                    Expanded(child: _quickCard('Nous écrire', '+228 90 00 12', Icons.chat_bubble_outline_rounded)),
                    const SizedBox(width: 11),
                    Expanded(child: _quickCard('Tutoriel', '2 min', Icons.play_circle_outline_rounded)),
                  ]),
                  const SectionHeader(title: 'Questions fréquentes'),
                  for (int i = 0; i < _faq.length; i++) _faqTile(i),
                  const SizedBox(height: 6),
                  AppCard(
                    color: AppColors.kx50,
                    borderColor: AppColors.kx100,
                    child: Row(
                      children: [
                        const Icon(Icons.flag_outlined, color: AppColors.kx700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Signaler une erreur dans une épreuve', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              SizedBox(height: 3),
                              Text('Énoncé, corrigé ou explication', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
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
    );
  }

  Widget _quickCard(String title, String sub, IconData icon, {bool primary = false}) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      color: primary ? AppColors.kx700 : Colors.white,
      borderColor: primary ? AppColors.kx700 : AppColors.line,
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: primary ? Colors.white.withValues(alpha: .16) : AppColors.kx50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: primary ? Colors.white : AppColors.kx700, size: 19),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary ? Colors.white : AppColors.ink)),
          const SizedBox(height: 2),
          Text(sub, textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, color: primary ? Colors.white.withValues(alpha: .76) : AppColors.muted)),
        ],
      ),
    );
  }

  Widget _faqTile(int i) {
    final open = expanded == i;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: EdgeInsets.zero,
        color: open ? AppColors.kx50 : Colors.white,
        borderColor: open ? AppColors.kx100 : AppColors.line,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() => expanded = open ? -1 : i),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(_faq[i], style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.4))),
                    Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.kx600, size: 18),
                  ],
                ),
                if (open) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Oui. Télécharge tes annales quand tu as du réseau. Tu peux ensuite composer, recevoir ta note et lire les explications sans réseau. Tes résultats sont envoyés automatiquement à la prochaine connexion.',
                    style: TextStyle(fontSize: 11, color: AppColors.ink2, height: 1.6),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
