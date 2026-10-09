import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Kod kutusu (DESIGN.md §3.3): Lilac-100 zemin, gömülü monospace, metinden küçük.
/// Satırlar olduğu gibi korunur, sola hizalanır; uzun satır yatay kaydırılır.
class CodeBlock extends StatelessWidget {
  const CodeBlock(this.code, {super.key, this.style = AppTextStyles.code});

  final String code;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.lilac100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(code, style: style, softWrap: false, textAlign: TextAlign.left),
      ),
    );
  }
}
