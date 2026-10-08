import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Exam {
  final int id;
  final String level;
  final int sessionYear;
  final String sessionMonth;
  final String subjectCode;
  final String subjectName;
  final bool available;
  final int pageCount;
  final bool interactive;
  final int? questionCount;
  final int? durationMinutes;
  final num? totalPoints;

  const Exam({
    required this.id,
    required this.level,
    required this.sessionYear,
    required this.sessionMonth,
    required this.subjectCode,
    required this.subjectName,
    required this.available,
    required this.pageCount,
    this.interactive = false,
    this.questionCount,
    this.durationMinutes,
    this.totalPoints,
  });

  factory Exam.fromJson(Map<String, dynamic> json) => Exam(
        id: json['id'] as int,
        level: json['level'] as String,
        sessionYear: json['sessionYear'] as int,
        sessionMonth: json['sessionMonth'] as String,
        subjectCode: json['subjectCode'] as String,
        subjectName: json['subjectName'] as String,
        available: json['available'] as bool,
        pageCount: (json['pageCount'] as int?) ?? 0,
        interactive: (json['interactive'] as bool?) ?? false,
        questionCount: json['questionCount'] as int?,
        durationMinutes: json['durationMinutes'] as int?,
        totalPoints: json['totalPoints'] as num?,
      );

  String get sessionLabel => 'Session de ${sessionMonth == 'AOUT' ? 'août' : 'juin'} $sessionYear';

  String get shortLabel => '$level ${sessionMonth == 'AOUT' ? 'août ' : ''}$sessionYear';

  Color get color => subjectColor(subjectCode);

  IconData get icon => subjectIcon(subjectCode);
}

/// Couleur/icône d'une matière à partir de son code backend (ex. CALCUL_MENTAL),
/// partagées entre l'écran d'annales et les écrans de progression/profil.
Color subjectColor(String code) => _subjectColors[code] ?? AppColors.kx700;

IconData subjectIcon(String code) => _subjectIcons[code] ?? Icons.description_outlined;

const _subjectColors = <String, Color>{
  'PROBLEME': AppColors.mathBlue,
  'CALCUL_ECRIT': AppColors.mathBlue,
  'CALCUL_MENTAL': AppColors.mathBlue,
  'DICTEE': AppColors.frenchPurple,
  'DICTEE_QUESTIONS': AppColors.frenchPurple,
  'ETUDE_TEXTE': AppColors.frenchPurple,
  'REDACTION': AppColors.frenchPurple,
  'PRODUCTION_TEXTE': AppColors.frenchPurple,
  'SCIENCES_TECHNO': AppColors.physicsTeal,
  'EDUSIVIP': AppColors.svtGreen,
  'HISTOIRE_GEO': AppColors.historyBrown,
  'SCIENCES_HUMAINES': AppColors.historyBrown,
  'EDUCATION_CIVIQUE': AppColors.englishPink,
  'EDUCATION_SOCIALE': AppColors.englishPink,
  'DESSIN': AppColors.gold600,
};

const _subjectIcons = <String, IconData>{
  'PROBLEME': Icons.calculate_rounded,
  'CALCUL_ECRIT': Icons.calculate_rounded,
  'CALCUL_MENTAL': Icons.psychology_outlined,
  'DICTEE': Icons.record_voice_over_outlined,
  'DICTEE_QUESTIONS': Icons.record_voice_over_outlined,
  'ETUDE_TEXTE': Icons.import_contacts_rounded,
  'REDACTION': Icons.edit_note_rounded,
  'PRODUCTION_TEXTE': Icons.edit_note_rounded,
  'SCIENCES_TECHNO': Icons.science_rounded,
  'EDUSIVIP': Icons.eco_rounded,
  'HISTOIRE_GEO': Icons.public_rounded,
  'SCIENCES_HUMAINES': Icons.public_rounded,
  'EDUCATION_CIVIQUE': Icons.groups_outlined,
  'EDUCATION_SOCIALE': Icons.groups_outlined,
  'DESSIN': Icons.brush_outlined,
};
