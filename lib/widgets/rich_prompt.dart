import 'package:flutter/material.dart';

/// Rend un texte du sujet en respectant ses soulignements (<u>…</u>).
List<InlineSpan> markupSpans(String text, {TextStyle? style}) {
  final spans = <InlineSpan>[];
  final pattern = RegExp(r'<u>(.*?)</u>', dotAll: true);
  var last = 0;
  for (final m in pattern.allMatches(text)) {
    if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start), style: style));
    spans.add(TextSpan(
      text: m.group(1),
      style: (style ?? const TextStyle()).copyWith(decoration: TextDecoration.underline, decorationThickness: 1.6),
    ));
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last), style: style));
  return spans;
}

class RichPrompt extends StatelessWidget {
  final String text;
  final TextStyle style;
  const RichPrompt(this.text, {super.key, required this.style});

  @override
  Widget build(BuildContext context) => Text.rich(TextSpan(children: markupSpans(text.replaceAll('___', '……………'), style: style)));
}
