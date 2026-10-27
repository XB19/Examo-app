import 'package:flutter/material.dart';
import '../models/exam.dart';
import '../services/exam_api.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import 'exam_intro_screen.dart';
import 'exam_paper_screen.dart';
import 'offline_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const _allSubjects = 'Toutes matières';
  static const _allYears = 'Toutes';

  List<Exam>? exams;
  bool loading = true;
  bool failed = false;
  String subjectFilter = _allSubjects;
  String yearFilter = _allYears;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      failed = false;
    });
    try {
      final result = await ExamApi.fetchExams(level: 'CEPD');
      if (!mounted) return;
      setState(() {
        exams = result;
        loading = false;
        if (yearFilter == _allYears && result.isNotEmpty) yearFilter = '${result.first.sessionYear}';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        failed = true;
      });
    }
  }

  List<String> get _years => {for (final e in exams ?? <Exam>[]) '${e.sessionYear}'}.toList();

  List<Exam> get _examsOfYear =>
      (exams ?? []).where((e) => yearFilter == _allYears || '${e.sessionYear}' == yearFilter).toList();

  List<String> get _subjects => ({for (final e in _examsOfYear) e.subjectName}.toList()..sort());

  List<Exam> get _filtered =>
      _examsOfYear.where((e) => subjectFilter == _allSubjects || e.subjectName == subjectFilter).toList();

  void _selectYear(String year) {
    setState(() {
      yearFilter = year;
      if (!_subjects.contains(subjectFilter)) subjectFilter = _allSubjects;
    });
  }

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
                  HeaderNavBar(
                    title: 'Annales CEPD',
                    showBack: false,
                    actions: [
                      CircleIconButton(
                          icon: Icons.grid_view_rounded,
                          ghost: true,
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OfflineScreen()))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .14),
                            border: Border.all(color: Colors.white.withValues(alpha: .22)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: .8), size: 19),
                              const SizedBox(width: 10),
                              Text('Matière, année, chapitre…', style: TextStyle(color: Colors.white.withValues(alpha: .68), fontSize: 14)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 13),
                        SizedBox(
                          height: 32,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [_allSubjects, ..._subjects]
                                .map((s) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: AppChip(
                                        label: s,
                                        height: 32,
                                        tone: s == subjectFilter ? ChipTone.darkOn : ChipTone.darkOff,
                                        onTap: () => setState(() => subjectFilter = s),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (loading && exams == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.kx700),
            SizedBox(height: 14),
            Text('Chargement des annales…', style: TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    if (failed && exams == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 42, color: AppColors.kx300),
              const SizedBox(height: 12),
              const Text('Impossible de charger les annales', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Vérifie ta connexion internet puis réessaie.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.5)),
              const SizedBox(height: 18),
              SizedBox(width: 200, child: AppButton(label: 'Réessayer', icon: Icons.refresh_rounded, height: 46, onPressed: _load)),
            ],
          ),
        ),
      );
    }

    final filtered = _filtered;
    return RefreshIndicator(
      color: AppColors.kx700,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
        children: [
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [_allYears, ..._years]
                  .map((y) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AppChip(label: y, height: 32, tone: y == yearFilter ? ChipTone.on : ChipTone.line, onTap: () => _selectYear(y)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink),
                  children: [
                    TextSpan(text: '${filtered.length} ${filtered.length > 1 ? 'annales' : 'annale'} ', style: const TextStyle(color: AppColors.kx700)),
                    TextSpan(text: filtered.length > 1 ? 'disponibles' : 'disponible', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.muted)),
                  ],
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.filter_list_rounded, size: 13, color: AppColors.kx700),
                  SizedBox(width: 5),
                  Text('Plus récentes', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.kx700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final e in filtered) _examTile(e),
        ],
      ),
    );
  }

  static String _duration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final m = minutes % 60;
    return m == 0 ? '${minutes ~/ 60} h' : '${minutes ~/ 60} h ${m.toString().padLeft(2, '0')}';
  }

  Widget _examTile(Exam e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: AppCard(
        padding: const EdgeInsets.all(11),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => e.interactive ? ExamIntroScreen(exam: e) : ExamPaperScreen(exam: e),
        )),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExamCover(width: 60, height: 78, color: e.color, year: '${e.sessionYear}'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(e.subjectName, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700))),
                      if (!e.available) const Pill(label: 'Bientôt', bg: AppColors.warn100, fg: AppColors.warn600),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${e.level} · ${e.sessionLabel}', style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(e.icon, size: 13, color: e.color),
                      const SizedBox(width: 5),
                      if (e.interactive) ...[
                        Text('${e.questionCount} question${(e.questionCount ?? 0) > 1 ? 's' : ''}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink2)),
                        if (e.durationMinutes != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time_rounded, size: 13, color: AppColors.ink2),
                          const SizedBox(width: 5),
                          Text(_duration(e.durationMinutes!), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink2)),
                        ],
                      ] else
                        const Text('Sujet à lire', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink2)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8C4D8)),
          ],
        ),
      ),
    );
  }
}
