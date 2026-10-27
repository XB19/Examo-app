import 'package:flutter/material.dart';

import '../models/exam_content.dart';
import '../theme/app_colors.dart';
import 'rich_prompt.dart';

/// Texte support d'une question : énoncé toujours visible, texte long dépliable.
class PassageCard extends StatefulWidget {
  final ExamPassage passage;

  /// Pour une dictée, le texte n'est montré qu'une fois la dictée rendue.
  final bool dictationRevealed;

  const PassageCard({super.key, required this.passage, this.dictationRevealed = false});

  @override
  State<PassageCard> createState() => _PassageCardState();
}

class _PassageCardState extends State<PassageCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.passage;
    final isDictation = p.kind == PassageKind.dictation;
    if (isDictation && !widget.dictationRevealed) return const SizedBox.shrink();

    final text = isDictation ? p.revealedDictation : (p.text ?? '');
    final title = isDictation ? 'Texte de la dictée' : (p.title ?? 'Énoncé');
    const bodyStyle = TextStyle(fontSize: 14.5, height: 1.65, color: AppColors.ink);

    if (p.kind == PassageKind.statement) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.kx50, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.kx100)),
        child: Text.rich(TextSpan(children: markupSpans(text, style: bodyStyle))),
      );
    }

    return Container(
      decoration: BoxDecoration(color: AppColors.kx50, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.kx100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => expanded = !expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(children: [
                const Icon(Icons.menu_book_rounded, color: AppColors.kx700, size: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: markupSpans(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.kx700))),
                  ),
                ),
                Text(expanded ? 'Fermer' : 'Lire le texte', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.kx600)),
                Icon(expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.kx600),
              ]),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text.rich(TextSpan(children: markupSpans(text, style: bodyStyle))),
            ),
        ],
      ),
    );
  }
}
