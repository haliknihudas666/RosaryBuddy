import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/mystery_type.dart';
import '../../data/repositories/rosary_repository.dart';
import '../../providers/app_settings_provider.dart';

/// A shared mystery type selector used on both RosaryScreen and
/// RosaryGuideScreen. Displays a row of four toggleable chips.
class MysterySelector extends ConsumerWidget {
  /// The currently selected mystery type.
  final MysteryType selectedType;

  /// Called when the user taps a mystery chip.
  final ValueChanged<MysteryType> onSelected;

  /// Optional margin override.
  final EdgeInsetsGeometry margin;

  const MysterySelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
    this.margin = const EdgeInsets.fromLTRB(12, 2, 12, 4),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = const RosaryRepository().getTodaysMystery();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF5C3D2E) : const Color(0xFFD2BEA6);
    final lang = ref.watch(languageProvider);

    return Container(
      height: 52,
      margin: margin,
      child: Row(
        children: MysteryType.values.map((type) {
          final selected = selectedType == type;
          final isToday = type == today;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(type);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : isToday
                            ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                            : borderColor,
                    width: selected ? 1.4 : 0.9,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.25),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(type.emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 1),
                    Text(
                      type.getDisplayName(lang),
                      style: GoogleFonts.cinzel(
                        color: selected
                            ? const Color(0xFF1A0F0A)
                            : (isDark
                                ? const Color(0xFFBFA98A)
                                : const Color(0xFF5C3D2E)),
                        fontSize: 8.5,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
