import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/localization_data.dart';
import '../../providers/app_settings_provider.dart';

/// Dialog for entering prayer intentions before starting the Rosary.
///
/// Now a ConsumerStatefulWidget to read language from Riverpod.
class IntentionDialog extends ConsumerStatefulWidget {
  const IntentionDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const IntentionDialog(),
    );
  }

  @override
  ConsumerState<IntentionDialog> createState() => _IntentionDialogState();
}

class _IntentionDialogState extends ConsumerState<IntentionDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addChipText(String label) {
    final lang = ref.read(languageProvider);
    final isEn = lang == 'en';
    final currentText = _controller.text.trim();

    if (currentText.isEmpty) {
      final prefix = isEn
          ? 'I offer this Holy Rosary for '
          : 'Iniaalay ko po ang Banal na Rosaryo na ito para sa ';
      _controller.text = '$prefix${label.toLowerCase()}...';
    } else {
      _controller.text = '$currentText, $label';
    }
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor =
        isDark ? const Color(0xFF5C3D2E) : const Color(0xFFD2BEA6);
    final textMainColor =
        isDark ? const Color(0xFFF5E6D3) : const Color(0xFF1A0F0A);
    final textMutedColor =
        isDark ? const Color(0xFFBFA98A) : const Color(0xFF5C3D2E);

    final title = LocalizationData.getText(lang, 'intention_dialog_title');
    final desc = LocalizationData.getText(lang, 'intention_dialog_desc');
    final hint = LocalizationData.getText(lang, 'intention_input_hint');
    final prayWithoutBtn =
        LocalizationData.getText(lang, 'pray_without_intention');
    final startWithBtn =
        LocalizationData.getText(lang, 'start_with_intention');

    final chips = [
      LocalizationData.getText(lang, 'quick_chip_family'),
      LocalizationData.getText(lang, 'quick_chip_peace'),
      LocalizationData.getText(lang, 'quick_chip_guidance'),
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Accent Line
              Container(height: 3, color: primaryColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title with Icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A0F0A)
                                : const Color(0xFFF5E6D3),
                            borderRadius: BorderRadius.circular(6),
                            border:
                                Border.all(color: borderColor, width: 1),
                          ),
                          child: Icon(
                            Icons.volunteer_activism_rounded,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.cinzel(
                              color: primaryColor,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Description
                    Text(
                      desc,
                      style: GoogleFonts.spectral(
                        color: textMutedColor,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Quick Chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: chips.map((chipLabel) {
                        return InkWell(
                          onTap: () => _addChipText(chipLabel),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF3D2517)
                                  : const Color(0xFFF5E6D3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    primaryColor.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  size: 14,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  chipLabel,
                                  style: GoogleFonts.cinzel(
                                    color: textMainColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    // Intention Text Input Field
                    TextField(
                      controller: _controller,
                      maxLines: 4,
                      minLines: 3,
                      style: GoogleFonts.spectral(
                        color: textMainColor,
                        fontSize: 15,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: GoogleFonts.spectral(
                          color: textMutedColor.withValues(alpha: 0.6),
                          fontSize: 13.5,
                          fontStyle: FontStyle.italic,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1A0F0A)
                            : const Color(0xFFFAF5EE),
                        contentPadding: const EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              BorderSide(color: borderColor, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Pray Without Intention Button
                        Expanded(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.pop(context, null),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: BorderSide(
                                    color: borderColor, width: 1),
                              ),
                            ),
                            child: Text(
                              prayWithoutBtn,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                color: textMutedColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Offer & Start Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final text = _controller.text.trim();
                              Navigator.pop(
                                context,
                                text.isEmpty ? null : text,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: const Color(0xFF1A0F0A),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              startWithBtn,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
