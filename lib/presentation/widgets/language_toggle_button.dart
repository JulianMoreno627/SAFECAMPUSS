import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';

/// Pill button ES ↔ EN. Úsalo con [Positioned] o directamente en un Row.
class LanguageToggleButton extends ConsumerWidget {
  final bool light; // true → texto blanco (para fondos oscuros)

  const LanguageToggleButton({super.key, this.light = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEs = ref.watch(localeProvider).languageCode == 'es';

    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🌐',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 5),
            Text(
              isEs ? 'ES' : 'EN',
              style: TextStyle(
                color: light ? Colors.white : AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.swap_horiz_rounded,
              size: 13,
              color: light
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.accent.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
