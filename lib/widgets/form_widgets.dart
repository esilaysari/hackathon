import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Input'lar radius-md; hata rengi sert kırmızı yerine Warning kenarlık + Grey-900 metin (§4.2).
final appInputTheme = InputDecorationTheme(
  filled: true,
  fillColor: AppColors.creamSurface,
  labelStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.grey600),
  floatingLabelStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.lilac700),
  hintStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.grey600),
  errorStyle: AppTextStyles.caption.copyWith(color: AppColors.grey900),
  border: _border(AppColors.grey400),
  enabledBorder: _border(AppColors.grey400),
  focusedBorder: _border(AppColors.lilac700),
  errorBorder: _border(AppColors.warning),
  focusedErrorBorder: _border(AppColors.warning),
);

OutlineInputBorder _border(Color color) =>
    OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: color));

/// Lilac-700 küçük metin bağlantısı (demo girişleri, "Ayrıntılar", "Kapat").
final appLinkStyle = AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500, color: AppColors.lilac700);

/// Hata / uyarı notu: Warning-Soft zemin, Grey-900 metin.
class WarningNote extends StatelessWidget {
  const WarningNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Text(text, style: AppTextStyles.bodyLg),
      ),
    );
  }
}

/// Krem zeminde beyaz kart: radius-lg, Shadow/Light.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, this.color = AppColors.creamSurface});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.light,
      ),
      child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: child),
    );
  }
}

/// Öğrenci tarafı ekranlar için ortalanmış, en fazla 480px genişlikte kaydırılabilir sütun.
class CenteredColumn extends StatelessWidget {
  const CenteredColumn({super.key, required this.children, this.maxWidth = AppLayout.studentMaxWidth});

  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Theme(
            data: Theme.of(context).copyWith(inputDecorationTheme: appInputTheme),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
      ),
    );
  }
}

/// İki seçenekli etiket çipi; seçili olan Lilac-100 zemin + Lilac-700 kenarlık (DESIGN.md §8.3).
class SelectChip extends StatelessWidget {
  const SelectChip({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.lilac100 : AppColors.creamSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: selected ? AppColors.lilac700 : AppColors.grey400),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Text(label, style: AppTextStyles.bodyLg),
        ),
      ),
    );
  }
}
