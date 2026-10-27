import 'package:flutter/material.dart';

import '../services/exam_api.dart';
import '../services/voice.dart';
import '../theme/app_colors.dart';
import 'chip_widgets.dart';

/// Lit la dictée à voix haute, en entier ou phrase par phrase. Le texte n'est jamais affiché.
/// Utilise la voix ElevenLabs du serveur quand elle est disponible (meilleure qualité,
/// générée une fois puis mise en cache), sinon la voix du téléphone.
class DictationPlayer extends StatefulWidget {
  final int examId;
  final List<String> sentences;
  const DictationPlayer({super.key, required this.examId, required this.sentences});

  @override
  State<DictationPlayer> createState() => _DictationPlayerState();
}

class _DictationPlayerState extends State<DictationPlayer> {
  int current = 0;
  bool playingAll = false;
  bool slow = true;
  bool? voiceAvailable;
  bool useElevenLabs = false;
  int _run = 0;

  double get _rate => slow ? Voice.slowRate : Voice.normalRate;
  double get _speed => slow ? 0.75 : 1.0;

  @override
  void initState() {
    super.initState();
    _checkVoices();
  }

  Future<void> _checkVoices() async {
    final results = await Future.wait([ExamApi.voiceAvailable(), Voice.instance.ttsAvailable]);
    if (!mounted) return;
    final elevenLabs = results[0];
    final tts = results[1];
    setState(() {
      useElevenLabs = elevenLabs;
      voiceAvailable = elevenLabs || tts;
    });
  }

  Future<void> _speak(String sentence, int index) async {
    final ok = useElevenLabs
        ? await Voice.instance.playUrl(ExamApi.dictationAudioUrl(widget.examId, index), speed: _speed)
        : await Voice.instance.speak(sentence, rate: _rate);
    if (ok || !mounted) return;
    if (useElevenLabs) {
      // Le serveur audio n'a pas répondu (réseau coupé) : on retombe sur la voix
      // du téléphone pour le reste de la dictée, plutôt que d'abandonner.
      setState(() => useElevenLabs = false);
      final fallback = await Voice.instance.speak(sentence, rate: _rate);
      if (fallback || !mounted) return;
    }
    _run++;
    setState(() {
      voiceAvailable = false;
      playingAll = false;
    });
  }

  /// Sans voix sur le téléphone : une autre personne lit la dictée à l'élève.
  Future<void> _showForReader() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Texte pour la personne qui lit'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.gold100, borderRadius: BorderRadius.circular(10)),
              child: const Text('Élève, ne regarde pas ! Donne le téléphone à la personne qui va te lire la dictée.',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF7A5400))),
            ),
            const SizedBox(height: 12),
            Text(widget.sentences.join(' '), style: const TextStyle(fontSize: 15, height: 1.6)),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('J\'ai fini de lire'))],
      ),
    );
  }

  @override
  void dispose() {
    _run++;
    Voice.instance.stop();
    super.dispose();
  }

  Future<void> _playAll() async {
    final run = ++_run;
    setState(() => playingAll = true);
    for (int i = current; i < widget.sentences.length; i++) {
      if (run != _run || !mounted) return;
      setState(() => current = i);
      await _speak(widget.sentences[i], i);
      if (run != _run || !mounted) return;
      // Laisse à l'élève le temps d'écrire avant la phrase suivante.
      await Future.delayed(Duration(milliseconds: slow ? 2500 : 1200));
    }
    if (run == _run && mounted) setState(() => playingAll = false);
  }

  Future<void> _stop() async {
    _run++;
    await Voice.instance.stop();
    if (mounted) setState(() => playingAll = false);
  }

  Future<void> _playOne(int index) async {
    await _stop();
    setState(() => current = index.clamp(0, widget.sentences.length - 1));
    await _speak(widget.sentences[current], current);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.sentences.length;
    if (voiceAvailable == false) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.gold100, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF1DDB0))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.volume_off_outlined, color: AppColors.gold600),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ton téléphone ne peut pas lire la dictée à voix haute. Demande à un parent, un frère, une sœur ou un ami de te la lire.',
                style: TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600, color: Color(0xFF5E4200)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _showForReader,
            icon: const Icon(Icons.record_voice_over_outlined),
            label: const Text('Quelqu\'un va me la lire'),
          ),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [BoxShadow(color: AppColors.kx900.withValues(alpha: .06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: AppColors.gold100, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.record_voice_over_outlined, color: AppColors.gold600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Écoute la dictée', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('Phrase ${current + 1} sur $total', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ]),
            ),
            AppChip(
              label: slow ? 'Lent' : 'Normal',
              icon: Icons.speed_rounded,
              tone: slow ? ChipTone.gold : ChipTone.line,
              height: 30,
              onTap: () => setState(() => slow = !slow),
            ),
          ]),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : (current + 1) / total,
              minHeight: 6,
              color: AppColors.gold500,
              backgroundColor: AppColors.line,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _round(Icons.skip_previous_rounded, 'Précédente', current > 0 ? () => _playOne(current - 1) : null),
              _round(Icons.replay_rounded, 'Répéter', total > 0 ? () => _playOne(current) : null),
              _round(
                playingAll ? Icons.pause_rounded : Icons.play_arrow_rounded,
                playingAll ? 'Pause' : 'Tout lire',
                total > 0 ? (playingAll ? _stop : _playAll) : null,
                primary: true,
              ),
              _round(Icons.skip_next_rounded, 'Suivante', current < total - 1 ? () => _playOne(current + 1) : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _round(IconData icon, String label, VoidCallback? onTap, {bool primary = false}) {
    final size = primary ? 62.0 : 46.0;
    return Column(children: [
      Material(
        color: primary ? AppColors.kx700 : AppColors.bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: primary ? Colors.white : (onTap == null ? AppColors.line : AppColors.ink2), size: primary ? 30 : 22),
          ),
        ),
      ),
      const SizedBox(height: 5),
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted)),
    ]);
  }
}
