enum GradeStatus { correct, partial, wrong, unanswered, toCheck }

class QuestionResult {
  final String id;
  final num points;
  final num? awarded;
  final GradeStatus status;
  final String? feedback;
  final String expected;
  final String? studentAnswer;
  final bool hasPhoto;

  const QuestionResult({
    required this.id,
    required this.points,
    required this.awarded,
    required this.status,
    required this.feedback,
    required this.expected,
    required this.studentAnswer,
    required this.hasPhoto,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) => QuestionResult(
        id: json['id'] as String,
        points: json['points'] as num,
        awarded: json['awarded'] as num?,
        status: switch (json['status']) {
          'CORRECT' => GradeStatus.correct,
          'PARTIAL' => GradeStatus.partial,
          'WRONG' => GradeStatus.wrong,
          'UNANSWERED' => GradeStatus.unanswered,
          _ => GradeStatus.toCheck,
        },
        feedback: json['feedback'] as String?,
        expected: json['expected'] as String,
        studentAnswer: json['studentAnswer'] as String?,
        hasPhoto: (json['hasPhoto'] as bool?) ?? false,
      );
}

class GradingResult {
  final String submissionId;

  /// true : corrigé par l'IA ; false : l'élève compare avec le corrigé et se note.
  final bool gradedByAi;
  final num total;
  final int? durationSeconds;
  final String? notice;
  final List<QuestionResult> questions;

  const GradingResult({
    required this.submissionId,
    required this.gradedByAi,
    required this.total,
    required this.durationSeconds,
    required this.notice,
    required this.questions,
  });

  factory GradingResult.fromJson(Map<String, dynamic> json) => GradingResult(
        submissionId: json['submissionId'] as String,
        gradedByAi: json['gradedBy'] == 'AI',
        total: json['total'] as num,
        durationSeconds: json['durationSeconds'] as int?,
        notice: json['notice'] as String?,
        questions: [for (final q in json['questions'] as List) QuestionResult.fromJson(q as Map<String, dynamic>)],
      );
}
