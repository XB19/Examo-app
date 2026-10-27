import 'exam_content.dart';

/// Brouillon de réponse pour une question, gardé en mémoire pendant l'épreuve.
class StudentAnswer {
  String text = '';
  int? choice;
  List<String> blanks;
  List<List<String>> table;

  /// Chemin local de la photo prise (dessin, schéma, dictée, copie).
  String? photoPath;

  StudentAnswer(ExamQuestion q)
      : blanks = List.filled(q.blankCount, '', growable: false),
        table = [for (final row in q.tableRows) List.filled(row.length, '', growable: false)];

  bool isAnswered(ExamQuestion q) => switch (q.type) {
        QuestionType.choice => choice != null,
        QuestionType.photo || QuestionType.dictation => photoPath != null,
        QuestionType.fillBlanks => blanks.any((b) => b.trim().isNotEmpty),
        QuestionType.table => table.expand((r) => r).any((c) => c.trim().isNotEmpty),
        QuestionType.longText => text.trim().isNotEmpty || photoPath != null,
        QuestionType.shortText => text.trim().isNotEmpty,
      };

  Map<String, dynamic> toJson(ExamQuestion q) => switch (q.type) {
        QuestionType.choice => {'choice': choice},
        QuestionType.photo || QuestionType.dictation => {'photo': photoPath != null},
        QuestionType.fillBlanks => {'blanks': blanks},
        QuestionType.table => {'table': table},
        QuestionType.longText => {'text': text, 'photo': photoPath != null},
        QuestionType.shortText => {'text': text},
      };
}
