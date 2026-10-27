/// Épreuve interactive telle que servie par le backend (sans corrigé).
class ExamContent {
  final int id;
  final String subjectName;
  final String? title;
  final int? durationMinutes;
  final num totalPoints;
  final List<ExamPassage> passages;
  final List<ExamQuestion> questions;

  const ExamContent({
    required this.id,
    required this.subjectName,
    required this.title,
    required this.durationMinutes,
    required this.totalPoints,
    required this.passages,
    required this.questions,
  });

  factory ExamContent.fromJson(Map<String, dynamic> json) => ExamContent(
        id: json['id'] as int,
        subjectName: json['subjectName'] as String,
        title: json['title'] as String?,
        durationMinutes: json['durationMinutes'] as int?,
        totalPoints: json['totalPoints'] as num,
        passages: [for (final p in json['passages'] as List) ExamPassage.fromJson(p as Map<String, dynamic>)],
        questions: [for (final q in json['questions'] as List) ExamQuestion.fromJson(q as Map<String, dynamic>)],
      );

  ExamPassage? passage(String? id) {
    if (id == null) return null;
    for (final p in passages) {
      if (p.id == id) return p;
    }
    return null;
  }

  bool get hasPhotoQuestions => questions.any((q) => q.type.usesPhoto);
  bool get hasDictation => questions.any((q) => q.type == QuestionType.dictation);
}

enum PassageKind { text, statement, dictation }

class ExamPassage {
  final String id;
  final PassageKind kind;
  final String? title;
  final String? text;

  /// Pour une dictée : les phrases à lire à voix haute (le titre en premier).
  final List<String> sentences;

  const ExamPassage({required this.id, required this.kind, this.title, this.text, this.sentences = const []});

  factory ExamPassage.fromJson(Map<String, dynamic> json) => ExamPassage(
        id: json['id'] as String,
        kind: switch (json['kind']) {
          'DICTATION' => PassageKind.dictation,
          'STATEMENT' => PassageKind.statement,
          _ => PassageKind.text,
        },
        title: json['title'] as String?,
        text: json['text'] as String?,
        sentences: [for (final s in (json['sentences'] as List?) ?? const []) s as String],
      );

  /// Texte de la dictée, montré seulement une fois la dictée rendue.
  String get revealedDictation => sentences.length > 1 ? sentences.skip(1).join(' ') : sentences.join(' ');
}

enum QuestionType {
  shortText,
  longText,
  choice,
  fillBlanks,
  table,
  photo,
  dictation;

  static QuestionType parse(String s) => switch (s) {
        'LONG_TEXT' => longText,
        'CHOICE' => choice,
        'FILL_BLANKS' => fillBlanks,
        'TABLE' => table,
        'PHOTO' => photo,
        'DICTATION' => dictation,
        _ => shortText,
      };

  bool get usesPhoto => this == photo || this == dictation || this == longText;
}

class ExamQuestion {
  final String id;
  final String? section;
  final String? stem;
  final String? label;
  final String prompt;
  final num points;
  final QuestionType type;
  final String? passage;
  final List<String> options;
  final List<String>? tableHeader;
  final List<List<String?>> tableRows;
  final int blankCount;

  const ExamQuestion({
    required this.id,
    required this.section,
    required this.stem,
    required this.label,
    required this.prompt,
    required this.points,
    required this.type,
    required this.passage,
    required this.options,
    required this.tableHeader,
    required this.tableRows,
    required this.blankCount,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    final table = json['table'] as Map<String, dynamic>?;
    return ExamQuestion(
      id: json['id'] as String,
      section: json['section'] as String?,
      stem: json['stem'] as String?,
      label: json['label'] as String?,
      prompt: json['prompt'] as String,
      points: json['points'] as num,
      type: QuestionType.parse(json['type'] as String),
      passage: json['passage'] as String?,
      options: [for (final o in (json['options'] as List?) ?? const []) o as String],
      tableHeader: (table?['header'] as List?)?.map((h) => h as String).toList(),
      tableRows: [
        for (final row in (table?['rows'] as List?) ?? const []) [for (final c in row as List) c as String?],
      ],
      blankCount: (json['blankCount'] as int?) ?? 0,
    );
  }

  /// Énoncé complet, sans balises, pour la lecture à voix haute.
  String get spokenText {
    final parts = [
      ?stem,
      [?label, prompt].join(' '),
      if (options.isNotEmpty) options.join(' ; '),
    ];
    return stripMarkup(parts.join('. ')).replaceAll(blankMarker, ' … ');
  }

  static const blankMarker = '___';
}

/// Retire les balises de mise en forme (<u>…</u>) d'un texte du sujet.
String stripMarkup(String s) => s.replaceAll(RegExp(r'<[^>]+>'), '');

String formatPoints(num p) {
  final s = p == p.roundToDouble() ? p.toInt().toString() : p.toString().replaceAll('.', ',');
  return '$s ${p > 1 ? 'points' : 'point'}';
}

String formatScore(num p) => p == p.roundToDouble() ? p.toInt().toString() : p.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll('.', ',');
