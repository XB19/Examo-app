import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/section_header.dart';
import 'exam_level_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'offline_screen.dart';
import 'progress_screen.dart';
import 'subjects_screen.dart';
import 'support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool dailyReminder = true;
  bool audioReadout = true;

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
                  const HeaderNavBar(title: 'Mon profil', showBack: false),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const StudentAvatar(size: 72),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(color: AppColors.gold500, shape: BoxShape.circle, border: Border.all(color: AppColors.kx700, width: 2.5)),
                                child: const Icon(Icons.school_outlined, color: Colors.white, size: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Koffi ADJOVI', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text('Classe de 3ᵉ · +228 90 42 18 07', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 12)),
                              ),
                              const SizedBox(height: 8),
                              Row(children: [
                                Pill(label: 'BEPC 2027', icon: Icons.school_outlined, bg: AppColors.gold500.withValues(alpha: .24), fg: const Color(0xFFFFD79A)),
                                const SizedBox(width: 7),
                                Pill(label: '5 j', icon: Icons.local_fire_department_rounded, bg: Colors.white.withValues(alpha: .16), fg: Colors.white),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        _statChip(context, '18', 'Épreuves'),
                        const SizedBox(width: 9),
                        _statChip(context, '11,4', 'Moyenne', color: const Color(0xFFFFD79A)),
                        const SizedBox(width: 9),
                        _statChip(context, '5 j', 'Régularité'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  const SectionHeader(title: 'Ma scolarité'),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(children: [
                      _row(Icons.school_outlined, 'Examen préparé', 'BEPC · session de juin 2027',
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExamLevelScreen()))),
                      _divider(),
                      _row(Icons.import_contacts_rounded, 'Mes matières', '6 matières suivies',
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubjectsScreen()))),
                      _divider(),
                      _row(Icons.person_outline_rounded, 'Informations personnelles', 'Nom, classe, téléphone', last: true),
                    ]),
                  ),
                  const SectionHeader(title: 'Mon travail'),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(children: [
                      _row(Icons.bar_chart_rounded, 'Ma progression', 'Moyenne, matières, chapitres',
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProgressScreen()))),
                      _divider(),
                      _row(Icons.import_contacts_rounded, 'Mes épreuves traitées', '18 épreuves · 3 en cours'),
                      _divider(),
                      _row(Icons.wifi_off_rounded, 'Téléchargements', '18 annales · 149 Mo', last: true,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OfflineScreen()))),
                    ]),
                  ),
                  const SectionHeader(title: 'Réglages'),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Row(
                          children: [
                            _iconBadge(Icons.notifications_none_rounded),
                            const SizedBox(width: 13),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rappel quotidien', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                  SizedBox(height: 2),
                                  Text('Tous les jours à 18 h', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            Switch(value: dailyReminder, activeTrackColor: AppColors.kx700, onChanged: (v) => setState(() => dailyReminder = v)),
                          ],
                        ),
                      ),
                      _divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Row(
                          children: [
                            _iconBadge(Icons.record_voice_over_outlined),
                            const SizedBox(width: 13),
                            const Expanded(
                              child: Text('Lecture audio des explications', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                            ),
                            Switch(value: audioReadout, activeTrackColor: AppColors.kx700, onChanged: (v) => setState(() => audioReadout = v)),
                          ],
                        ),
                      ),
                      _divider(),
                      _row(Icons.support_agent_rounded, 'Aide et contact', null, last: true,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportScreen()))),
                    ]),
                  ),
                  const SectionHeader(title: 'Notifications', margin: EdgeInsets.only(top: 22, bottom: 0)),
                  const SizedBox(height: 4),
                  AppCard(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    child: const Row(children: [
                      Icon(Icons.notifications_none_rounded, color: AppColors.kx700),
                      SizedBox(width: 12),
                      Expanded(child: Text('Voir mes notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                      Icon(Icons.chevron_right_rounded, color: Color(0xFFB8C4D8)),
                    ]),
                  ),
                  const SizedBox(height: 22),
                  InkWell(
                    onTap: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout_rounded, color: AppColors.crim600, size: 18),
                          SizedBox(width: 9),
                          Text('Se déconnecter', style: TextStyle(color: AppColors.crim600, fontSize: 13.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
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

  Widget _statChip(BuildContext context, String value, String label, {Color color = Colors.white}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 11),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), border: Border.all(color: Colors.white.withValues(alpha: .18)), borderRadius: BorderRadius.circular(13)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: .76), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _iconBadge(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: AppColors.kx50, borderRadius: BorderRadius.circular(11)),
      child: Icon(icon, color: AppColors.kx700, size: 19),
    );
  }

  Widget _row(IconData icon, String title, String? subtitle, {bool last = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            _iconBadge(icon),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                  ],
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8C4D8), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.line);
}
