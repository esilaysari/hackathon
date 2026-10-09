import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Ders metnini gösterir; `ters tırnak` içindeki kısımlar satır içinde monospace yazılır.
class LessonText extends StatelessWidget {
  const LessonText(this.text, {super.key, required this.style, this.textAlign});

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('`');
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i],
              style: i.isOdd ? const TextStyle(fontFamily: AppFonts.mono) : null,
            ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
