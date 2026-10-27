import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/exam.dart';
import '../models/exam_content.dart';
import '../models/grading_result.dart';
import '../models/student_answer.dart';

class ExamApi {
  ExamApi._();

  // Surchargeable au build : flutter run --dart-define=API_BASE_URL=https://api.examo.tg
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// 10.0.2.2 désigne l'ordinateur hôte depuis l'émulateur Android.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  static Future<List<Exam>> fetchExams({String level = 'CEPD'}) async {
    final uri = Uri.parse('$baseUrl/api/exams').replace(queryParameters: {'level': level});
    final list = await _getJson(uri) as List<dynamic>;
    return list.map((e) => Exam.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<ExamContent> fetchContent(int examId) async {
    final json = await _getJson(Uri.parse('$baseUrl/api/exams/$examId/content'));
    return ExamContent.fromJson(json as Map<String, dynamic>);
  }

  static Future<bool> aiAvailable() async {
    try {
      final json = await _getJson(Uri.parse('$baseUrl/api/ai/status'));
      return (json as Map<String, dynamic>)['available'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Envoie la copie : réponses en JSON + une photo par question qui en a une.
  static Future<GradingResult> submit(
    ExamContent content,
    Map<String, StudentAnswer> answers,
    int durationSeconds,
  ) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/exams/${content.id}/submissions'));
    final payload = <String, dynamic>{};
    for (final q in content.questions) {
      final a = answers[q.id];
      if (a == null || !a.isAnswered(q)) continue;
      payload[q.id] = a.toJson(q);
      if (a.photoPath != null) {
        request.files.add(await http.MultipartFile.fromPath('photo_${q.id}', a.photoPath!));
      }
    }
    request.files.add(http.MultipartFile.fromString(
      'answers',
      jsonEncode({'durationSeconds': durationSeconds, 'answers': payload}),
      contentType: http.MediaType('application', 'json'),
    ));
    // La correction par l'IA d'une copie entière peut prendre jusqu'à une minute.
    final streamed = await request.send().timeout(const Duration(minutes: 3));
    final response = await http.Response.fromStream(streamed);
    _check(response);
    return GradingResult.fromJson(jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
  }

  /// [turns] : la conversation (role "student" ou "tutor"), le dernier message venant de l'élève.
  static Future<String> explain(String submissionId, String questionId, List<ChatTurn> turns) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/explanations'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'submissionId': submissionId,
            'questionId': questionId,
            'messages': [for (final t in turns) {'role': t.fromStudent ? 'student' : 'tutor', 'text': t.text}],
          }),
        )
        .timeout(const Duration(seconds: 90));
    _check(response);
    return (jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>)['reply'] as String;
  }

  static Future<bool> voiceAvailable() async {
    try {
      final json = await _getJson(Uri.parse('$baseUrl/api/voice/status'));
      return (json as Map<String, dynamic>)['available'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Audio (ElevenLabs, mis en cache côté serveur) d'une phrase de dictée,
  /// [index] correspondant à sa position dans `ExamPassage.sentences`.
  static String dictationAudioUrl(int examId, int index) => '$baseUrl/api/exams/$examId/dictation-audio/$index';

  /// Audio (ElevenLabs, mis en cache côté serveur) de l'énoncé d'une question
  /// quelconque (`ExamQuestion.spokenText`), pour le bouton « Écouter la question ».
  static String questionAudioUrl(int examId, String questionId) =>
      '$baseUrl/api/exams/$examId/questions/$questionId/audio';

  static String pageImageUrl(Exam exam, int page) => '$baseUrl/api/exams/${exam.id}/pages/$page';

  static String photoUrl(String submissionId, String questionId) => '$baseUrl/api/submissions/$submissionId/photos/$questionId';

  static Future<dynamic> _getJson(Uri uri) async {
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    _check(response);
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static void _check(http.Response response) {
    if (response.statusCode == 200) return;
    String? message;
    try {
      message = (jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>)['message'] as String?;
    } catch (_) {}
    throw ExamApiException(message ?? 'Erreur ${response.statusCode}', statusCode: response.statusCode);
  }
}

class ChatTurn {
  final bool fromStudent;
  final String text;
  const ChatTurn(this.fromStudent, this.text);
}

class ExamApiException implements Exception {
  final String message;
  final int? statusCode;
  const ExamApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
