import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/section_header.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  bool wifiOnly = true;

  static const _subjects = [
    ('Mathématiques', AppColors.mathBlue, '9 annales · 48 Mo', true, null),
    ('Français', AppColors.frenchPurple, '9 annales · 62 Mo', true, null),
    ('SVT', AppColors.svtGreen, '8 annales · 39 Mo', null, 64),
    ('Histoire-Géo', AppColors.historyBrown, '8 annales · 44 Mo', null, null),
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
                    title: 'Hors connexion',
                    actions: [CircleIconButton(icon: Icons.settings_outlined, ghost: true, onPressed: () {})],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), border: Border.all(color: Colors.white.withValues(alpha: .22)), borderRadius: BorderRadius.circular(22)),
                        child: const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 13),
                      const Text('Travaille sans internet', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 7),
                        child: Text('Télécharge tes annales quand tu as du réseau, puis entraîne-toi partout, même hors connexion.',
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: .82), fontSize: 12, height: 1.5)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Pill(label: '18 annales prêtes', bg: AppColors.ok600.withValues(alpha: .3), fg: const Color(0xFFA7E7C9)),
                          const SizedBox(width: 8),
                          Pill(label: '149 Mo utilisés', bg: Colors.white.withValues(alpha: .16), fg: Colors.white),
                        ]),
                      ),
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
                    color: AppColors.kx50,
                    borderColor: AppColors.kx100,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: AppColors.kx700, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.sync_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Synchroniser mes résultats', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                              SizedBox(height: 3),
                              Text('3 épreuves en attente d\'envoi', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                            ],
                          ),
                        ),
                        SmallButton(label: 'Envoyer', filled: true, onPressed: () {}),
                      ],
                    ),
                  ),
                  SectionHeader(title: 'Mes téléchargements', action: 'Gérer'),
                  for (final s in _subjects) _subjectDownload(s),
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: AppColors.gold100, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.file_download_outlined, color: AppColors.gold600, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Télécharger en Wi-Fi uniquement', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                              SizedBox(height: 3),
                              Text('Économise tes données mobiles', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                            ],
                          ),
                        ),
                        Switch(value: wifiOnly, activeTrackColor: AppColors.kx700, onChanged: (v) => setState(() => wifiOnly = v)),
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

  Widget _subjectDownload((String, Color, String, bool?, int?) s) {
    final (name, color, sub, done, pct) = s;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: color.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.import_contacts_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      if (done == true)
                        const Icon(Icons.check_circle, color: AppColors.ok600, size: 19)
                      else if (pct != null)
                        Text('$pct%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.kx700))
                      else
                        SmallButton(label: 'Charger', icon: Icons.file_download_outlined, onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(sub, style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                  if (pct != null) ...[
                    const SizedBox(height: 8),
                    LinearBar(percent: pct / 100),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
