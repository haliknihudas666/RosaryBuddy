import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/localization_data.dart';
import '../../data/models/mystery_type.dart';
import '../../data/repositories/rosary_repository.dart';
import '../../providers/app_settings_provider.dart';

/// Provider for managing selected mystery type in the Rosary Guide screen.
final guideMysteryProvider = StateProvider<MysteryType>((ref) {
  return const RosaryRepository().getTodaysMystery();
});

/// Provider for managing user intention text in the Rosary Guide screen.
final guideIntentionProvider = StateProvider<String?>((ref) => null);

class RosaryGuideScreen extends ConsumerWidget {
  const RosaryGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final mysteryType = ref.watch(guideMysteryProvider);
    final intention = ref.watch(guideIntentionProvider);

    final steps = const RosaryRepository().buildSteps(
      mysteryType,
      lang,
      intention: intention,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocalizationData.getText(lang, 'guide_title'),
          style: GoogleFonts.cinzel(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mystery Selector Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: MysteryType.values.map((type) {
                    final selected = mysteryType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(guideMysteryProvider.notifier).state = type;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: selected
                                ? primaryColor
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: selected
                                  ? primaryColor
                                  : (isDark
                                      ? const Color(0xFF5C3D2E)
                                      : const Color(0xFFD2BEA6)),
                              width: selected ? 1.4 : 0.9,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${type.emoji} ${type.getDisplayName(lang)}',
                              style: GoogleFonts.cinzel(
                                color: selected
                                    ? const Color(0xFF1A0F0A)
                                    : (isDark
                                        ? const Color(0xFFBFA98A)
                                        : const Color(0xFF5C3D2E)),
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Scrollable List of Prayer Steps
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF3D2517)
                            : const Color(0xFFE5D3BD),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: GoogleFonts.cinzel(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (step.mysterySubtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            step.mysterySubtitle!,
                            style: GoogleFonts.spectral(
                              color: isDark
                                  ? const Color(0xFFBFA98A)
                                  : const Color(0xFF5C3D2E),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          step.text,
                          style: GoogleFonts.spectral(
                            color: isDark
                                ? const Color(0xFFF5E6D3)
                                : const Color(0xFF1A0F0A),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
