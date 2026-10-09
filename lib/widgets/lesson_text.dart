import 'package:flutter/material.dart';

/// Ders metnini gösterir; `ters tırnak` içindeki kod parçaları kalın yazılır.
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
              style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w700) : null,
            ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
