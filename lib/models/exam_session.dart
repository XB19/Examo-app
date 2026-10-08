import 'package:flutter/foundation.dart';

import '../services/exam_api.dart';
import 'exam.dart';
import 'exam_content.dart';
import 'grading_result.dart';
import 'student_answer.dart';

/// Une copie corrigée : l'épreuve, les réponses, la correction et les explications demandées.
class ExamSession {
  final Exam exam;
  final ExamContent content;
  final Map<String, StudentAnswer> answers;
  final GradingResult result;
  final bool aiAvailable;

  /// Mode autocorrection (IA indisponible) : l'élève indique s'il avait juste.
  final ValueNotifier<Map<String, bool>> selfMarks = ValueNotifier(const {});

  final Map<String, ExplanationThread> _threads = {};

  ExamSession({
    required this.exam,
    required this.content,
    required this.answers,
    required this.result,
    required this.aiAvailable,
  });

  ExamQuestion question(String id) => content.questions.firstWhere((q) => q.id == id);

  int indexOf(String id) => content.questions.indexWhere((q) => q.id == id);

  GradeStatus statusOf(QuestionResult r) {
    if (r.status != GradeStatus.toCheck) return r.status;
    final mark = selfMarks.value[r.id];
    if (mark == null) return GradeStatus.toCheck;
    return mark ? GradeStatus.correct : GradeStatus.wrong;
  }

  num awardedOf(QuestionResult r) => r.awarded ?? (selfMarks.value[r.id] == true ? r.points : 0);

  num get score => result.questions.fold<num>(0, (sum, r) => sum + awardedOf(r));

  int get pendingSelfChecks => result.questions.where((r) => statusOf(r) == GradeStatus.toCheck).length;

  void mark(String questionId, bool correct) {
    selfMarks.value = {...selfMarks.value, questionId: correct};
  }

  ExplanationThread thread(String questionId) =>
      _threads.putIfAbsent(questionId, () => ExplanationThread(result.submissionId, questionId));
}

/// Conversation avec le tuteur à propos d'une question ; partagée entre l'écran écrit et l'écran oral.
class ExplanationThread extends ChangeNotifier {
  static const firstQuestion = 'Je n\'ai pas compris cette question. Explique-moi, s\'il te plaît.';

  final String submissionId;
  final String questionId;
  final List<ChatTurn> turns = [];
  bool loading = false;
  String? error;

  ExplanationThread(this.submissionId, this.questionId);

  String? get lastReply {
    for (final t in turns.reversed) {
      if (!t.fromStudent) return t.text;
    }
    return null;
  }

  /// Démarre l'explication si elle n'a pas encore été demandée.
  Future<void> start() async {
    if (turns.isEmpty && !loading) await ask(firstQuestion);
  }

  Future<void> ask(String text) async {
    final question = text.trim();
    if (question.isEmpty || loading) return;
    turns.add(ChatTurn(true, question));
    await _send();
  }

  /// Renvoie la dernière question après une erreur réseau.
  Future<void> retry() async {
    if (turns.isNotEmpty && turns.last.fromStudent && !loading) await _send();
  }

  Future<void> _send() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final reply = await ExamApi.explain(submissionId, questionId, turns);
      turns.add(ChatTurn(false, reply));
    } catch (e) {
      error = e is ExamApiException ? e.message : 'Pas de connexion. Vérifie ton internet puis réessaie.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
