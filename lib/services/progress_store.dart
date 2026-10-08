import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exam.dart';
import '../models/exam_session.dart';

/// Résumé d'une épreuve terminée, gardé pour calculer la progression de
/// l'élève. Aucun compte ni serveur ne suit encore cet historique : il vit
/// sur l'appareil (mémoire + préférences locales), par design tant qu'il n'y
/// a pas d'authentification côté backend.
class CompletedExam {
  final String submissionId;
  final int examId;
  final String level;
  final String subjectCode;
  final String subjectName;
  final int? sessionYear;
  final num totalPoints;
  final int? durationSeconds;
  final DateTime completedAt;
  final bool gradedByAi;
  num score;
  int pendingSelfChecks;

  CompletedExam({
    required this.submissionId,
    required this.examId,
    required this.level,
    required this.subjectCode,
    required this.subjectName,
    required this.sessionYear,
    required this.totalPoints,
    required this.durationSeconds,
    required this.completedAt,
    required this.gradedByAi,
    required this.score,
    required this.pendingSelfChecks,
  });

  factory CompletedExam.fromSession(ExamSession session) => CompletedExam(
        submissionId: session.result.submissionId,
        examId: session.exam.id,
        level: session.exam.level,
        subjectCode: session.exam.subjectCode,
        subjectName: session.exam.subjectName,
        sessionYear: session.exam.sessionYear,
        totalPoints: session.content.totalPoints,
        durationSeconds: session.result.durationSeconds,
        completedAt: DateTime.now(),
        gradedByAi: session.result.gradedByAi,
        score: session.score,
        pendingSelfChecks: session.pendingSelfChecks,
      );

  /// Note ramenée sur 20, pour affichage et calcul de moyenne uniforme
  /// malgré des barèmes différents selon la matière.
  double get scoreOn20 => totalPoints > 0 ? (score / totalPoints) * 20 : 0;

  double get percent => totalPoints > 0 ? (score / totalPoints).clamp(0, 1).toDouble() : 0;

  Color get color => subjectColor(subjectCode);
  IconData get icon => subjectIcon(subjectCode);

  Map<String, dynamic> toJson() => {
        'submissionId': submissionId,
        'examId': examId,
        'level': level,
        'subjectCode': subjectCode,
        'subjectName': subjectName,
        'sessionYear': sessionYear,
        'totalPoints': totalPoints,
        'durationSeconds': durationSeconds,
        'completedAt': completedAt.toIso8601String(),
        'gradedByAi': gradedByAi,
        'score': score,
        'pendingSelfChecks': pendingSelfChecks,
      };

  factory CompletedExam.fromJson(Map<String, dynamic> json) => CompletedExam(
        submissionId: json['submissionId'] as String,
        examId: json['examId'] as int,
        level: json['level'] as String,
        subjectCode: json['subjectCode'] as String,
        subjectName: json['subjectName'] as String,
        sessionYear: json['sessionYear'] as int?,
        totalPoints: json['totalPoints'] as num,
        durationSeconds: json['durationSeconds'] as int?,
        completedAt: DateTime.parse(json['completedAt'] as String),
        gradedByAi: json['gradedByAi'] as bool,
        score: json['score'] as num,
        pendingSelfChecks: (json['pendingSelfChecks'] as int?) ?? 0,
      );
}

/// Progression calculée par matière (moyenne, nombre d'épreuves traitées).
class SubjectProgress {
  final String code;
  final String name;
  final List<CompletedExam> exams;

  SubjectProgress(this.code, this.name, this.exams);

  Color get color => subjectColor(code);
  IconData get icon => subjectIcon(code);
  int get count => exams.length;
  double get averagePercent => exams.isEmpty ? 0 : exams.map((e) => e.percent).reduce((a, b) => a + b) / exams.length;
}

enum Badge { firstExam, fiveDayStreak, tenExams, averageAbove12, allSubjectsTried }

class BadgeInfo {
  final Badge badge;
  final String label;
  final IconData icon;
  final Color color;
  const BadgeInfo(this.badge, this.label, this.icon, this.color);
}

const badgeCatalog = <BadgeInfo>[
  BadgeInfo(Badge.firstExam, 'Première épreuve', Icons.emoji_events_outlined, Color(0xFFF5A623)),
  BadgeInfo(Badge.fiveDayStreak, '5 jours d\'affilée', Icons.local_fire_department_rounded, Color(0xFFC2372C)),
  BadgeInfo(Badge.tenExams, '10 épreuves', Icons.import_contacts_rounded, Color(0xFF1C3B72)),
  BadgeInfo(Badge.averageAbove12, 'Moyenne > 12', Icons.track_changes_rounded, Color(0xFF17845A)),
  BadgeInfo(Badge.allSubjectsTried, 'Toutes les matières CEPD', Icons.school_outlined, Color(0xFF7A2E8E)),
];

/// Historique local des épreuves terminées + statistiques dérivées
/// (moyenne, régularité, matières) pour les écrans Accueil/Progression/
/// Profil/Révisions. Persisté sur l'appareil via `shared_preferences` ;
/// aucune donnée n'est envoyée ni partagée entre appareils.
class ProgressStore extends ChangeNotifier {
  ProgressStore._();
  static final ProgressStore instance = ProgressStore._();

  static const _prefsKey = 'examo_progress_v1';
  static const _goalKey = 'examo_weekly_goal_v1';
  static const defaultWeeklyGoal = 3;

  final List<CompletedExam> _items = [];
  int _weeklyGoal = defaultWeeklyGoal;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  int get weeklyGoal => _weeklyGoal;

  List<CompletedExam> get items {
    final sorted = [..._items]..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return List.unmodifiable(sorted);
  }

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefsKey) ?? const [];
      for (final s in raw) {
        try {
          _items.add(CompletedExam.fromJson(jsonDecode(s) as Map<String, dynamic>));
        } catch (_) {
          // Entrée corrompue : on l'ignore plutôt que de bloquer le chargement.
        }
      }
      _weeklyGoal = prefs.getInt(_goalKey) ?? defaultWeeklyGoal;
    } catch (_) {
      // Préférences indisponibles (ex. premier lancement sans permission) :
      // on continue avec un historique vide plutôt que de planter l'appli.
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, _items.map((e) => jsonEncode(e.toJson())).toList());
    } catch (_) {}
  }

  /// Enregistre une copie qui vient d'être corrigée. En autocorrection,
  /// le score évolue tant que l'élève pointe ses réponses : on écoute
  /// [ExamSession.selfMarks] pour garder l'historique synchronisé.
  void record(ExamSession session) {
    final entry = CompletedExam.fromSession(session);
    _items.removeWhere((e) => e.submissionId == entry.submissionId);
    _items.add(entry);
    notifyListeners();
    _persist();

    if (!session.aiAvailable) {
      session.selfMarks.addListener(() {
        entry.score = session.score;
        entry.pendingSelfChecks = session.pendingSelfChecks;
        notifyListeners();
        _persist();
      });
    }
  }

  Future<void> setWeeklyGoal(int goal) async {
    _weeklyGoal = goal;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_goalKey, goal);
    } catch (_) {}
  }

  int get examCount => _items.length;

  double get averageOn20 {
    if (_items.isEmpty) return 0;
    return _items.map((e) => e.scoreOn20).reduce((a, b) => a + b) / _items.length;
  }

  /// Taux de réussite global (0..1), utilisé pour l'anneau de progression.
  double get overallPercent {
    if (_items.isEmpty) return 0;
    return _items.map((e) => e.percent).reduce((a, b) => a + b) / _items.length;
  }

  Duration get totalPracticeTime =>
      Duration(seconds: _items.fold<int>(0, (sum, e) => sum + (e.durationSeconds ?? 0)));

  List<SubjectProgress> get bySubject {
    final map = <String, List<CompletedExam>>{};
    for (final e in _items) {
      map.putIfAbsent(e.subjectCode, () => []).add(e);
    }
    return [for (final entry in map.entries) SubjectProgress(entry.key, entry.value.first.subjectName, entry.value)];
  }

  /// Matières les plus faibles en premier (au moins une épreuve traitée).
  List<SubjectProgress> get weakestSubjects => bySubject..sort((a, b) => a.averagePercent.compareTo(b.averagePercent));

  /// Scores des [n] dernières épreuves, du plus ancien au plus récent (0..1),
  /// pour la mini-courbe d'évolution.
  List<double> recentScores([int n = 8]) {
    final chronological = [..._items]..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    return chronological.reversed.take(n).toList().reversed.map((e) => e.percent).toList();
  }

  /// Jours consécutifs (jusqu'à aujourd'hui ou hier) avec au moins une épreuve.
  int get streakDays {
    if (_items.isEmpty) return 0;
    final days = _items.map((e) => DateTime(e.completedAt.year, e.completedAt.month, e.completedAt.day)).toSet();
    var cursor = DateTime.now();
    var today = DateTime(cursor.year, cursor.month, cursor.day);
    if (!days.contains(today)) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (!days.contains(yesterday)) return 0;
      today = yesterday;
    }
    var streak = 0;
    var day = today;
    while (days.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Jours (Lun..Dim) de la semaine en cours où l'élève s'est entraîné.
  List<bool> get weekActivity {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final days = _items.map((e) => DateTime(e.completedAt.year, e.completedAt.month, e.completedAt.day)).toSet();
    return [for (int i = 0; i < 7; i++) days.contains(monday.add(Duration(days: i)))];
  }

  int get examsThisWeek {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return _items.where((e) {
      final day = DateTime(e.completedAt.year, e.completedAt.month, e.completedAt.day);
      return !day.isBefore(monday);
    }).length;
  }

  int get bestStreak {
    if (_items.isEmpty) return 0;
    final days = (_items.map((e) => DateTime(e.completedAt.year, e.completedAt.month, e.completedAt.day)).toSet().toList()
      ..sort());
    var best = 1, current = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        current++;
        best = current > best ? current : best;
      } else {
        current = 1;
      }
    }
    return best;
  }

  Set<Badge> get unlockedBadges {
    final unlocked = <Badge>{};
    if (examCount >= 1) unlocked.add(Badge.firstExam);
    if (bestStreak >= 5) unlocked.add(Badge.fiveDayStreak);
    if (examCount >= 10) unlocked.add(Badge.tenExams);
    if (examCount > 0 && averageOn20 > 12) unlocked.add(Badge.averageAbove12);
    if (bySubject.length >= cepdSubjectCodes.length) unlocked.add(Badge.allSubjectsTried);
    return unlocked;
  }
}

/// Toutes les matières interactives proposées au CEPD par le backend,
/// utilisé pour savoir si l'élève a essayé "toutes les matières".
const cepdSubjectCodes = [
  'CALCUL_MENTAL', 'CALCUL_ECRIT', 'PROBLEME', 'DICTEE_QUESTIONS', 'ETUDE_TEXTE',
  'REDACTION', 'PRODUCTION_TEXTE', 'SCIENCES_TECHNO', 'EDUSIVIP', 'HISTOIRE_GEO',
  'SCIENCES_HUMAINES', 'EDUCATION_CIVIQUE', 'EDUCATION_SOCIALE', 'DESSIN',
];
