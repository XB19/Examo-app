import 'package:flutter/material.dart';
import '../models/exam_session.dart';
import '../services/voice.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import '../widgets/misc.dart';
import '../widgets/section_header.dart';
import 'ai_explain_text_screen.dart';

/// Explication orale : Examo lit sa réponse à voix haute ; l'élève peut lui parler au micro.
class AiExplainVoiceScreen extends StatefulWidget {
  final ExamSession session;
  final String questionId;
  const AiExplainVoiceScreen({super.key, required this.session, required this.questionId});

  @override
  State<AiExplainVoiceScreen> createState() => _AiExplainVoiceScreenState();
}

class _AiExplainVoiceScreenState extends State<AiExplainVoiceScreen> {
  late final ExplanationThread thread = widget.session.thread(widget.questionId);
  bool slow = false;
  bool listening = false;
  String heard = '';
  int spokenReplies = 0;

  @override
  void initState() {
    super.initState();
    // Les réponses déjà lues à l'écrit ne sont pas relues automatiquement, sauf la dernière.
    spokenReplies = thread.turns.where((t) => !t.fromStudent).length - 1;
    thread.addListener(_onThread);
    if (thread.turns.isEmpty) {
      thread.start();
    } else {
      _onThread();
    }
  }

  @override
  void dispose() {
    thread.removeListener(_onThread);
    Voice.instance.stop();
    Voice.instance.stopListening();
    super.dispose();
  }

  void _onThread() {
    if (!mounted) return;
    setState(() {});
    final replies = thread.turns.where((t) => !t.fromStudent).length;
    if (replies > spokenReplies && !thread.loading) {
      spokenReplies = replies;
      _play();
    }
  }

  Future<void> _play() async {
    final text = thread.lastReply;
    if (text == null) return;
    await Voice.instance.speakOrExplain(context, text, rate: slow ? Voice.slowRate : Voice.normalRate);
  }

  Future<void> _listen() async {
    if (listening) {
      await Voice.instance.stopListening();
      setState(() => listening = false);
      return;
    }
    setState(() => heard = '');
    final ok = await Voice.instance.listen(onResult: (words, isFinal) {
      if (!mounted) return;
      setState(() => heard = words);
      if (isFinal) {
        setState(() => listening = false);
        if (words.trim().isNotEmpty) thread.ask(words);
      }
    });
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le micro n\'est pas disponible sur ce téléphone.')));
      return;
    }
    setState(() => listening = true);
  }

  @override
  Widget build(BuildContext context) {
    final number = widget.session.indexOf(widget.questionId) + 1;
    final reply = thread.lastReply;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              child: Column(
                children: [
                  const HeaderNavBar(title: 'Examo t\'explique'),
                  _modeToggle(context),
                  const SizedBox(height: 20),
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: AppColors.gold500.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.gold500.withValues(alpha: .42)),
                    ),
                    child: Icon(listening ? Icons.mic_rounded : Icons.track_changes_rounded, color: const Color(0xFFFFD79A), size: 46),
                  ),
                  const SizedBox(height: 14),
                  Text(listening ? 'Je t\'écoute…' : 'Examo t\'explique à voix haute',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 18),
                    child: Text('Question $number · ${widget.session.exam.subjectName}', style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 11)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                    child: ValueListenableBuilder<(int, int)?>(
                      valueListenable: Voice.instance.spokenRange,
                      builder: (context, range, _) => Waveform(
                        progress: reply == null || range == null ? 0 : (range.$2 / reply.length).clamp(0.0, 1.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: Voice.instance.speaking,
                    builder: (context, speaking, _) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _round(onTap: () => setState(() => slow = !slow), text: slow ? '0.8×' : '1×'),
                        _round(icon: Icons.replay_rounded, onTap: reply == null ? null : _play),
                        _round(
                          icon: speaking ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 68,
                          primary: true,
                          onTap: reply == null ? null : (speaking ? Voice.instance.stop : _play),
                        ),
                        _round(icon: listening ? Icons.stop_rounded : Icons.mic_none_rounded, onTap: thread.loading ? null : _listen, active: listening),
                      ],
                    ),
                  ),
                  if (listening || heard.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    AppCard(
                      color: AppColors.kx50,
                      borderColor: AppColors.kx100,
                      child: Row(children: [
                        const Icon(Icons.record_voice_over_outlined, color: AppColors.kx700, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(heard.isEmpty ? 'Parle maintenant…' : '« $heard »', style: const TextStyle(fontSize: 13.5, height: 1.5))),
                      ]),
                    ),
                  ],
                  const SectionHeader(title: 'Ce que dit Examo'),
                  if (thread.loading)
                    const AppCard(child: Text('Examo réfléchit…', style: TextStyle(fontSize: 14, color: AppColors.muted, fontStyle: FontStyle.italic)))
                  else if (thread.error != null)
                    AppCard(
                      color: AppColors.crim100,
                      borderColor: const Color(0xFFF3C9C4),
                      child: Row(children: [
                        Expanded(child: Text(thread.error!, style: const TextStyle(fontSize: 12.5, color: AppColors.crim700))),
                        SmallButton(label: 'Réessayer', icon: Icons.refresh_rounded, color: AppColors.crim600, onPressed: thread.retry),
                      ]),
                    )
                  else if (reply != null)
                    AppCard(
                      padding: const EdgeInsets.all(15),
                      child: ValueListenableBuilder<(int, int)?>(
                        valueListenable: Voice.instance.spokenRange,
                        builder: (context, range, _) => _transcript(reply, range),
                      ),
                    ),
                  const SizedBox(height: 13),
                  Wrap(spacing: 9, runSpacing: 9, children: [
                    AppChip(label: 'Poser une question à l\'oral', icon: Icons.mic_none_rounded, tone: ChipTone.line, height: 34, onTap: thread.loading ? null : _listen),
                    AppChip(
                      label: 'Réexplique autrement',
                      icon: Icons.refresh_rounded,
                      tone: ChipTone.line,
                      height: 34,
                      onTap: thread.loading ? null : () => thread.ask('Réexplique-moi autrement, s\'il te plaît.'),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: AppColors.line)), boxShadow: [
            BoxShadow(color: AppColors.kx900.withValues(alpha: .1), blurRadius: 26, offset: const Offset(0, -8)),
          ]),
          child: Row(
            children: [
              SizedBox(width: 116, child: AppButton(label: 'Réécouter', icon: Icons.replay_rounded, variant: AppButtonVariant.outline, height: 50, fontSize: 13.5, onPressed: reply == null ? null : _play)),
              const SizedBox(width: 11),
              Expanded(child: AppButton(label: 'J\'ai compris', icon: Icons.check_rounded, height: 50, fontSize: 13.5, onPressed: () => Navigator.of(context).maybePop())),
            ],
          ),
        ),
      ),
    );
  }

  /// Surligne la phrase en cours de lecture.
  Widget _transcript(String text, (int, int)? range) {
    final sentences = RegExp(r'[^.!?\n]+[.!?]*\s*').allMatches(text).toList();
    final at = range?.$1;
    return Text.rich(TextSpan(children: [
      for (final m in sentences)
        TextSpan(
          text: m.group(0),
          style: at != null && at >= m.start && at < m.end
              ? const TextStyle(fontSize: 14.5, height: 1.75, color: AppColors.ink, fontWeight: FontWeight.w700, backgroundColor: AppColors.gold100)
              : TextStyle(fontSize: 14.5, height: 1.75, color: at == null ? AppColors.ink : AppColors.muted),
        ),
    ]));
  }

  Widget _modeToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Expanded(
            child: InkWell(
              onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => AiExplainTextScreen(session: widget.session, questionId: widget.questionId),
              )),
              child: SizedBox(
                height: 34,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.menu_book_rounded, size: 15, color: Colors.white70),
                  const SizedBox(width: 7),
                  Text('Lire', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: .84))),
                ]),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.graphic_eq_rounded, size: 15, color: AppColors.kx700),
                SizedBox(width: 7),
                Text('Écouter', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.kx700)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _round({IconData? icon, String? text, VoidCallback? onTap, double size = 46, bool primary = false, bool active = false}) {
    final bg = primary ? AppColors.kx700 : (active ? AppColors.crim100 : AppColors.bg);
    final fg = primary ? Colors.white : (active ? AppColors.crim600 : (onTap == null ? AppColors.line : AppColors.ink2));
    return Material(
      color: bg,
      shape: const CircleBorder(),
      elevation: primary ? 6 : 0,
      shadowColor: AppColors.kx700.withValues(alpha: .4),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: text != null
                ? Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.ink2))
                : Icon(icon, color: fg, size: primary ? 30 : 21),
          ),
        ),
      ),
    );
  }
}
