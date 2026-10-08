import 'package:flutter/material.dart';
import '../models/exam_content.dart';
import '../models/exam_session.dart';
import '../services/voice.dart';
import '../theme/app_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/buttons.dart';
import '../widgets/chip_widgets.dart';
import '../widgets/gradient_header.dart';
import 'ai_explain_voice_screen.dart';

/// Explication écrite : une conversation avec Examo à propos d'une question.
class AiExplainTextScreen extends StatefulWidget {
  final ExamSession session;
  final String questionId;
  const AiExplainTextScreen({super.key, required this.session, required this.questionId});

  @override
  State<AiExplainTextScreen> createState() => _AiExplainTextScreenState();
}

class _AiExplainTextScreenState extends State<AiExplainTextScreen> {
  late final ExplanationThread thread = widget.session.thread(widget.questionId);
  final TextEditingController input = TextEditingController();
  final ScrollController scroll = ScrollController();
  bool listening = false;

  @override
  void initState() {
    super.initState();
    thread.addListener(_onThread);
    thread.start();
  }

  @override
  void dispose() {
    thread.removeListener(_onThread);
    Voice.instance.stopListening();
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  void _onThread() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.animateTo(scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  void _send([String? text]) {
    final message = (text ?? input.text).trim();
    if (message.isEmpty) return;
    input.clear();
    FocusScope.of(context).unfocus();
    thread.ask(message);
  }

  Future<void> _mic() async {
    if (listening) {
      await Voice.instance.stopListening();
      setState(() => listening = false);
      return;
    }
    final ok = await Voice.instance.listen(onResult: (words, isFinal) {
      if (!mounted) return;
      input.text = words;
      if (isFinal) setState(() => listening = false);
    });
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le micro n\'est pas disponible. Écris ta question.')));
      return;
    }
    setState(() => listening = true);
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final q = session.question(widget.questionId);
    final number = session.indexOf(widget.questionId) + 1;
    final showFollowUps = !thread.loading && thread.error == null && thread.turns.isNotEmpty && !thread.turns.last.fromStudent;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            GradientHeaderShell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
              child: Column(
                children: [
                  const HeaderNavBar(title: 'Examo t\'explique'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.gold500.withValues(alpha: .2),
                            border: Border.all(color: AppColors.gold500.withValues(alpha: .4)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.track_changes_rounded, color: Color(0xFFFFD79A), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Question $number · ${session.exam.subjectName}',
                                  style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 3),
                              Text(stripMarkup(q.prompt).replaceAll(ExamQuestion.blankMarker, '…'),
                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xC7FFFFFF), fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _modeToggle(context),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  for (final t in thread.turns) ...[
                    t.fromStudent ? _studentBubble(t.text) : _tutorBubble(t.text),
                    const SizedBox(height: 12),
                  ],
                  if (thread.loading) _tutorBubble('Examo réfléchit…', muted: true),
                  if (thread.error != null) _errorCard(),
                  if (showFollowUps) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 42, top: 2),
                      child: Wrap(spacing: 9, runSpacing: 9, children: [
                        AppChip(label: 'Réexplique autrement', icon: Icons.refresh_rounded, tone: ChipTone.line, height: 34, onTap: () => _send('Réexplique-moi autrement, s\'il te plaît.')),
                        AppChip(label: 'Donne-moi un exemple', icon: Icons.lightbulb_outline_rounded, tone: ChipTone.line, height: 34, onTap: () => _send('Donne-moi un exemple simple.')),
                        AppChip(label: 'Plus simplement', icon: Icons.child_care_rounded, tone: ChipTone.line, height: 34, onTap: () => _send('Explique-moi encore plus simplement.')),
                      ]),
                    ),
                    const SizedBox(height: 18),
                    AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          const Text('Tu as compris cette explication ?', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 11),
                          Row(children: [
                            Expanded(child: SmallButton(label: 'Oui, c\'est clair', icon: Icons.check_rounded, color: AppColors.ok600, onPressed: () => Navigator.of(context).maybePop())),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SmallButton(
                                label: 'Pas encore',
                                icon: Icons.help_outline_rounded,
                                onPressed: () => _send('Je n\'ai toujours pas compris. Explique-moi autrement, plus simplement.'),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(18, 10, 18, 14 + MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(color: Colors.white, border: const Border(top: BorderSide(color: AppColors.line)), boxShadow: [
            BoxShadow(color: AppColors.kx900.withValues(alpha: .1), blurRadius: 26, offset: const Offset(0, -8)),
          ]),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.only(left: 4, right: 12),
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.line)),
                  child: Row(children: [
                    IconButton(
                      onPressed: _mic,
                      icon: Icon(listening ? Icons.mic_rounded : Icons.mic_none_rounded, color: listening ? AppColors.crim600 : AppColors.kx700),
                      tooltip: 'Parler',
                    ),
                    Expanded(
                      child: TextField(
                        controller: input,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: listening ? 'Je t\'écoute…' : 'Pose ta question à Examo…',
                          hintStyle: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: AppColors.kx700,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: thread.loading ? null : _send,
                  child: const SizedBox(width: 48, height: 48, child: Icon(Icons.send_rounded, color: Colors.white, size: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Expanded(
            child: Container(
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.menu_book_rounded, size: 15, color: AppColors.kx700),
                SizedBox(width: 7),
                Text('Lire', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.kx700)),
              ]),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => AiExplainVoiceScreen(session: widget.session, questionId: widget.questionId),
              )),
              child: SizedBox(
                height: 34,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.graphic_eq_rounded, size: 15, color: Colors.white70),
                  const SizedBox(width: 7),
                  Text('Écouter', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: .84))),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _errorCard() {
    return AppCard(
      color: AppColors.crim100,
      borderColor: const Color(0xFFF3C9C4),
      child: Row(children: [
        const Icon(Icons.wifi_off_rounded, color: AppColors.crim600),
        const SizedBox(width: 10),
        Expanded(child: Text(thread.error!, style: const TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.crim700))),
        SmallButton(label: 'Réessayer', icon: Icons.refresh_rounded, color: AppColors.crim600, onPressed: thread.retry),
      ]),
    );
  }

  Widget _studentBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: const BoxDecoration(
          color: AppColors.kx700,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white)),
      ),
    );
  }

  Widget _tutorBubble(String text, {bool muted = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: AppColors.kx700, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.track_changes_rounded, color: AppColors.gold500, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.kx50,
              border: Border.all(color: AppColors.kx100),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(text,
                style: TextStyle(fontSize: 14, height: 1.6, color: muted ? AppColors.muted : AppColors.ink, fontStyle: muted ? FontStyle.italic : FontStyle.normal)),
          ),
        ),
      ],
    );
  }
}
