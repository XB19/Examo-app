import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Lecture à voix haute (français) et reconnaissance de la voix de l'élève.
class Voice {
  Voice._();
  static final Voice instance = Voice._();

  static const normalRate = 0.48;
  static const slowRate = 0.34;

  static const unavailableMessage =
      'La lecture à voix haute n\'est pas disponible sur ce téléphone. Installe « Synthèse vocale Google » depuis le Play Store.';

  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  final AudioPlayer _player = AudioPlayer();
  Future<bool>? _ttsReady;
  bool _sttReady = false;

  /// Position (début, fin) du mot en cours de lecture, pour le surlignage.
  final ValueNotifier<(int, int)?> spokenRange = ValueNotifier(null);
  final ValueNotifier<bool> speaking = ValueNotifier(false);

  /// true si un moteur de synthèse vocale est installé et prêt.
  Future<bool> get ttsAvailable => _ttsReady ??= _initTts();

  Future<bool> _initTts() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        // Le moteur Android se connecte de façon asynchrone : on attend qu'il soit là.
        var engines = <dynamic>[];
        for (int i = 0; i < 10 && engines.isEmpty; i++) {
          engines = (await _tts.getEngines as List?) ?? const [];
          if (engines.isEmpty) await Future.delayed(const Duration(milliseconds: 300));
        }
        if (engines.isEmpty) return false;
      }
      await _tts.setLanguage('fr-FR');
      await _tts.awaitSpeakCompletion(true);
      _tts.setStartHandler(() => speaking.value = true);
      _tts.setCompletionHandler(_done);
      _tts.setCancelHandler(_done);
      _tts.setErrorHandler((_) => _done());
      _tts.setProgressHandler((text, start, end, word) => spokenRange.value = (start, end));
      return true;
    } catch (_) {
      return false;
    }
  }

  void _done() {
    speaking.value = false;
    spokenRange.value = null;
  }

  /// Lit [text] et attend la fin de la lecture. Renvoie false si la lecture est impossible.
  Future<bool> speak(String text, {double rate = normalRate}) async {
    if (!await ttsAvailable) return false;
    try {
      await _tts.stop();
      await _tts.setSpeechRate(rate);
      speaking.value = true;
      // Garde-fou : on n'attend jamais indéfiniment la fin d'une lecture.
      final limit = Duration(seconds: 5 + (text.length * (rate < normalRate ? 0.16 : 0.1)).round());
      final result = await _tts.speak(text).timeout(limit, onTimeout: () => 0);
      return result == 1;
    } catch (_) {
      return false;
    } finally {
      _done();
    }
  }

  /// Lit [text] et prévient l'élève si son téléphone ne sait pas lire à voix haute.
  Future<void> speakOrExplain(BuildContext context, String text, {double rate = normalRate}) async {
    final ok = await speak(text, rate: rate);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(unavailableMessage), duration: Duration(seconds: 6)));
    }
  }

  /// Joue un fichier audio distant (ElevenLabs) et attend la fin de la lecture.
  /// Renvoie false si la lecture échoue (réseau coupé, etc.) — l'appelant peut
  /// alors se rabattre sur [speak].
  Future<bool> playUrl(String url, {double speed = 1.0}) async {
    await stop();
    try {
      speaking.value = true;
      final done = Completer<void>();
      late final StreamSubscription sub;
      sub = _player.onPlayerComplete.listen((_) {
        sub.cancel();
        if (!done.isCompleted) done.complete();
      });
      await _player.setPlaybackRate(speed);
      await _player.play(UrlSource(url));
      // Garde-fou : une dictée dure rarement plus de deux minutes.
      await done.future.timeout(const Duration(minutes: 2), onTimeout: () {});
      return true;
    } catch (_) {
      return false;
    } finally {
      _done();
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    if (_ttsReady != null) {
      try {
        await _tts.stop();
      } catch (_) {}
    }
    _done();
  }

  /// Écoute l'élève ; renvoie false si le micro ou la reconnaissance vocale ne sont pas disponibles.
  Future<bool> listen({required void Function(String words, bool isFinal) onResult}) async {
    await stop();
    try {
      if (!_sttReady) _sttReady = await _stt.initialize();
      if (!_sttReady) return false;
      await _stt.listen(
        onResult: (r) => onResult(r.recognizedWords, r.finalResult),
        listenOptions: SpeechListenOptions(
          localeId: 'fr_FR',
          partialResults: true,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopListening() async {
    if (_sttReady) await _stt.stop();
  }

  bool get isListening => _stt.isListening;
}
