import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/exam_content.dart';
import '../models/student_answer.dart';
import '../theme/app_colors.dart';
import 'buttons.dart';
import 'chip_widgets.dart';
import 'dictation_player.dart';
import 'rich_prompt.dart';

/// Zone de réponse adaptée au type de question.
class AnswerInput extends StatelessWidget {
  final int examId;
  final ExamQuestion question;
  final ExamPassage? passage;
  final StudentAnswer answer;
  final VoidCallback onChanged;
  final bool dictationLocked;

  const AnswerInput({
    super.key,
    required this.examId,
    required this.question,
    required this.passage,
    required this.answer,
    required this.onChanged,
    this.dictationLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return switch (question.type) {
      QuestionType.shortText => _TextAnswer(key: ValueKey(question.id), answer: answer, onChanged: onChanged, minLines: 3),
      QuestionType.longText => _LongAnswer(key: ValueKey(question.id), answer: answer, onChanged: onChanged),
      QuestionType.choice => _ChoiceAnswer(question: question, answer: answer, onChanged: onChanged),
      QuestionType.fillBlanks => _BlanksAnswer(key: ValueKey(question.id), question: question, answer: answer, onChanged: onChanged),
      QuestionType.table => _TableAnswer(key: ValueKey(question.id), question: question, answer: answer, onChanged: onChanged),
      QuestionType.photo => PhotoAnswer(
          answer: answer,
          onChanged: onChanged,
          hint: 'Fais ton dessin sur une feuille, puis prends-le en photo bien à plat, avec de la lumière.',
        ),
      QuestionType.dictation => dictationLocked
          ? _DictationDone(answer: answer)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DictationPlayer(examId: examId, sentences: passage?.sentences ?? const []),
                const SizedBox(height: 14),
                PhotoAnswer(
                  answer: answer,
                  onChanged: onChanged,
                  hint: 'Écris la dictée sur ton cahier pendant la lecture. À la fin, prends ta page en photo.',
                  cameraLabel: 'Photographier ma dictée',
                ),
              ],
            ),
    };
  }
}

BoxDecoration _fieldBox() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.kx300),
      boxShadow: [BoxShadow(color: AppColors.kx700.withValues(alpha: .06), blurRadius: 0, spreadRadius: 4)],
    );

class _TextAnswer extends StatefulWidget {
  final StudentAnswer answer;
  final VoidCallback onChanged;
  final int minLines;
  const _TextAnswer({super.key, required this.answer, required this.onChanged, required this.minLines});

  @override
  State<_TextAnswer> createState() => _TextAnswerState();
}

class _TextAnswerState extends State<_TextAnswer> {
  late final TextEditingController controller = TextEditingController(text: widget.answer.text);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: _fieldBox(),
      child: TextField(
        controller: controller,
        // Le clavier ne doit pas « corriger » la réponse de l'élève à sa place.
        autocorrect: false,
        enableSuggestions: false,
        minLines: widget.minLines,
        maxLines: widget.minLines + 8,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.ink),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Écris ta réponse ici…',
          hintStyle: TextStyle(color: AppColors.muted),
        ),
        onChanged: (v) {
          widget.answer.text = v;
          widget.onChanged();
        },
      ),
    );
  }
}

class _LongAnswer extends StatefulWidget {
  final StudentAnswer answer;
  final VoidCallback onChanged;
  const _LongAnswer({super.key, required this.answer, required this.onChanged});

  @override
  State<_LongAnswer> createState() => _LongAnswerState();
}

class _LongAnswerState extends State<_LongAnswer> {
  late bool photoMode = widget.answer.photoPath != null && widget.answer.text.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          AppChip(
            label: 'Écrire',
            icon: Icons.keyboard_alt_outlined,
            tone: photoMode ? ChipTone.line : ChipTone.on,
            height: 32,
            onTap: () => setState(() => photoMode = false),
          ),
          const SizedBox(width: 8),
          AppChip(
            label: 'Photo de ma copie',
            icon: Icons.camera_alt_outlined,
            tone: photoMode ? ChipTone.on : ChipTone.line,
            height: 32,
            onTap: () => setState(() => photoMode = true),
          ),
        ]),
        const SizedBox(height: 12),
        if (photoMode)
          PhotoAnswer(
            answer: widget.answer,
            onChanged: widget.onChanged,
            hint: 'Écris ta rédaction sur ton cahier, puis prends la page en photo. Écris lisiblement.',
            cameraLabel: 'Photographier ma copie',
          )
        else
          _TextAnswer(answer: widget.answer, onChanged: widget.onChanged, minLines: 10),
      ],
    );
  }
}

class _ChoiceAnswer extends StatelessWidget {
  final ExamQuestion question;
  final StudentAnswer answer;
  final VoidCallback onChanged;
  const _ChoiceAnswer({required this.question, required this.answer, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < question.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                answer.choice = i;
                onChanged();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                decoration: BoxDecoration(
                  color: answer.choice == i ? AppColors.kx50 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: answer.choice == i ? AppColors.kx700 : AppColors.line, width: answer.choice == i ? 1.8 : 1.4),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: answer.choice == i ? AppColors.kx700 : Colors.transparent,
                        border: Border.all(color: answer.choice == i ? AppColors.kx700 : const Color(0xFFCBD5E6), width: 1.8),
                      ),
                      child: answer.choice == i ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: markupSpans(question.options[i])),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BlanksAnswer extends StatefulWidget {
  final ExamQuestion question;
  final StudentAnswer answer;
  final VoidCallback onChanged;
  const _BlanksAnswer({super.key, required this.question, required this.answer, required this.onChanged});

  @override
  State<_BlanksAnswer> createState() => _BlanksAnswerState();
}

class _BlanksAnswerState extends State<_BlanksAnswer> {
  late final List<TextEditingController> controllers = [
    for (final b in widget.answer.blanks) TextEditingController(text: b),
  ];

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 15.5, height: 2.1, color: AppColors.ink, fontWeight: FontWeight.w600);
    final parts = widget.question.prompt.split(ExamQuestion.blankMarker);
    final spans = <InlineSpan>[];
    for (int i = 0; i < parts.length; i++) {
      spans.addAll(markupSpans(parts[i], style: style));
      if (i < parts.length - 1 && i < controllers.length) {
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            width: 170,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.kx50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.kx300),
            ),
            child: TextField(
              controller: controllers[i],
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: i < controllers.length - 1 ? TextInputAction.next : TextInputAction.done,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.kx700),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'mot ${i + 1}',
                hintStyle: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
              onChanged: (v) {
                widget.answer.blanks[i] = v;
                widget.onChanged();
              },
            ),
          ),
        ));
      }
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _fieldBox(),
      child: Text.rich(TextSpan(children: spans)),
    );
  }
}

class _TableAnswer extends StatefulWidget {
  final ExamQuestion question;
  final StudentAnswer answer;
  final VoidCallback onChanged;
  const _TableAnswer({super.key, required this.question, required this.answer, required this.onChanged});

  @override
  State<_TableAnswer> createState() => _TableAnswerState();
}

class _TableAnswerState extends State<_TableAnswer> {
  late final List<List<TextEditingController?>> controllers = [
    for (int r = 0; r < widget.question.tableRows.length; r++)
      [
        for (int c = 0; c < widget.question.tableRows[r].length; c++)
          widget.question.tableRows[r][c] == null ? TextEditingController(text: widget.answer.table[r][c]) : null,
      ],
  ];

  @override
  void dispose() {
    for (final row in controllers) {
      for (final c in row) {
        c?.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final columns = q.tableRows.isEmpty ? 0 : q.tableRows.first.length;
    final withChoices = q.options.isNotEmpty;
    final cellWidth = withChoices ? 168.0 : (columns > 4 ? 76.0 : 112.0);
    Widget cell(Widget child, {bool header = false}) => Container(
          width: cellWidth,
          constraints: const BoxConstraints(minHeight: 46),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: header ? AppColors.kx50 : Colors.white,
          child: child,
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: AppColors.kx300), borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Table(
          defaultColumnWidth: FixedColumnWidth(cellWidth),
          border: TableBorder.symmetric(inside: const BorderSide(color: AppColors.line)),
          children: [
            if (q.tableHeader != null)
              TableRow(children: [
                for (final h in q.tableHeader!)
                  cell(Text(h, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.kx700)), header: true),
              ]),
            for (int r = 0; r < q.tableRows.length; r++)
              TableRow(children: [
                for (int c = 0; c < q.tableRows[r].length; c++)
                  q.tableRows[r][c] != null
                      ? cell(Text(q.tableRows[r][c]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))
                      : withChoices
                          ? cell(_ChoiceCell(question: q, answer: widget.answer, r: r, c: c, onChanged: widget.onChanged))
                          : cell(TextField(
                          controller: controllers[r][c],
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.kx700),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: '?',
                            filled: true,
                            fillColor: AppColors.kx50,
                            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          ),
                          onChanged: (v) {
                            widget.answer.table[r][c] = v;
                            widget.onChanged();
                          },
                        )),
              ]),
          ],
        ),
      ),
    );
  }
}

class _ChoiceCell extends StatelessWidget {
  final ExamQuestion question;
  final StudentAnswer answer;
  final int r;
  final int c;
  final VoidCallback onChanged;
  const _ChoiceCell({required this.question, required this.answer, required this.r, required this.c, required this.onChanged});

  /// Case à compléter en choisissant dans la liste donnée par le sujet.
  @override
  Widget build(BuildContext context) {
    final value = answer.table[r][c];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: AppColors.kx50, borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: value.isEmpty ? null : value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        hint: const Text('Choisir', style: TextStyle(fontSize: 13, color: AppColors.muted)),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.kx700),
        selectedItemBuilder: (_) => [
          for (final o in question.options) Align(alignment: Alignment.centerLeft, child: Text(o, maxLines: 2, overflow: TextOverflow.ellipsis)),
        ],
        items: [
          for (final o in question.options) DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 14))),
        ],
        onChanged: (v) {
          answer.table[r][c] = v ?? '';
          onChanged();
        },
      ),
    );
  }
}

/// Réponse en photo : appareil photo ou galerie, avec aperçu et possibilité de reprendre.
class PhotoAnswer extends StatelessWidget {
  final StudentAnswer answer;
  final VoidCallback onChanged;
  final String hint;
  final String cameraLabel;

  const PhotoAnswer({
    super.key,
    required this.answer,
    required this.onChanged,
    required this.hint,
    this.cameraLabel = 'Prendre une photo',
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source, maxWidth: 1600, maxHeight: 1600, imageQuality: 82);
      if (file == null) return;
      answer.photoPath = file.path;
      onChanged();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible d\'ouvrir l\'appareil photo. Essaie avec la galerie.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = answer.photoPath;
    if (path != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: AppColors.bg,
              constraints: const BoxConstraints(maxHeight: 320),
              child: kIsWeb ? Image.network(path, fit: BoxFit.contain) : Image.file(File(path), fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.check_circle, color: AppColors.ok600, size: 18),
            const SizedBox(width: 7),
            const Expanded(child: Text('Photo ajoutée à ta copie', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ok600))),
            SmallButton(label: 'Reprendre', icon: Icons.refresh_rounded, onPressed: () => _pick(context, ImageSource.camera)),
          ]),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.kx50, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.kx100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.camera_alt_outlined, color: AppColors.kx700, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(hint, style: const TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.ink2))),
          ]),
          const SizedBox(height: 12),
          AppButton(label: cameraLabel, icon: Icons.photo_camera_rounded, height: 48, fontSize: 14, onPressed: () => _pick(context, ImageSource.camera)),
          const SizedBox(height: 8),
          AppButton(
            label: 'Choisir une image',
            icon: Icons.photo_library_outlined,
            variant: AppButtonVariant.outline,
            height: 44,
            fontSize: 13.5,
            onPressed: () => _pick(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

class _DictationDone extends StatelessWidget {
  final StudentAnswer answer;
  const _DictationDone({required this.answer});

  @override
  Widget build(BuildContext context) {
    final done = answer.photoPath != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: done ? AppColors.ok100 : AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: done ? const Color(0xFFB9E3CE) : AppColors.line),
      ),
      child: Row(children: [
        Icon(done ? Icons.check_circle : Icons.do_not_disturb_on_outlined, color: done ? AppColors.ok600 : AppColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            done ? 'Ta dictée est rendue. Elle sera corrigée avec le reste de ta copie.' : 'Tu as passé la dictée : elle ne peut plus être faite.',
            style: TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600, color: done ? AppColors.ok600 : AppColors.ink2),
          ),
        ),
      ]),
    );
  }
}
