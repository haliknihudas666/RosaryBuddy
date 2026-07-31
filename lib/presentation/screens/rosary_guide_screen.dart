import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../data/models/mystery_type.dart';
import '../../data/repositories/rosary_repository.dart';
import '../../providers/app_settings_provider.dart';

/// Provider for managing selected mystery type in the Rosary Guide screen.
final guideMysteryProvider = StateProvider<MysteryType>((ref) {
  return const RosaryRepository().getTodaysMystery();
});

/// Provider for managing user intention text in the Rosary Guide screen.
final guideIntentionProvider = StateProvider<String?>((ref) => null);

/// Provider for managing active highlighted card index in the Rosary Guide screen.
final guideActiveIndexProvider = StateProvider<int?>((ref) => null);

enum _GuideItemType { generalIntention, mystery, prayer }

class _GuideItem {
  final _GuideItemType type;
  final String title;
  final String text;
  final String? subtitle;
  final int? repeatCount;

  const _GuideItem.generalIntention()
    : type = _GuideItemType.generalIntention,
      title = '',
      text = '',
      subtitle = null,
      repeatCount = null;

  const _GuideItem.mystery({required this.title, required this.subtitle})
    : type = _GuideItemType.mystery,
      text = '',
      repeatCount = null;

  const _GuideItem.prayer({
    required this.title,
    required this.text,
    this.repeatCount,
  }) : type = _GuideItemType.prayer,
       subtitle = null;
}

class RosaryGuideScreen extends ConsumerWidget {
  const RosaryGuideScreen({super.key});

  List<_GuideItem> _buildGuideItems(MysteryType mysteryType, String lang) {
    final l10n = lookupAppLocalizations(Locale(lang));
    final isEn = lang == 'en';
    final setName = mysteryType.getSetName(lang);
    final mysteryNames = mysteryType.getMysteryNames(lang);
    final items = <_GuideItem>[];

    final signOfCross = l10n.text_sign_of_cross;
    final apostlesCreed = l10n.text_apostles_creed;
    final ourFather = l10n.text_our_father;
    final hailMary = l10n.text_hail_mary;
    final gloryBe = l10n.text_glory_be;
    final fatima = l10n.text_fatima;
    final salveRegina = l10n.text_salve_regina;
    final closingPrayer = l10n.text_closing_prayer;

    final ordinals = [
      l10n.ordinal_1,
      l10n.ordinal_2,
      l10n.ordinal_3,
      l10n.ordinal_4,
      l10n.ordinal_5,
    ];

    final signOfCrossTitle = l10n.title_sign_of_cross;
    final apostlesCreedTitle = l10n.title_apostles_creed;
    final ourFatherTitle = l10n.title_our_father;
    final hailMaryTitle = l10n.title_hail_mary;
    final gloryBeTitle = l10n.title_glory_be;
    final fatimaTitle = l10n.title_fatima_prayer;
    final salveReginaTitle = l10n.title_salve_regina;
    final closingTitle = l10n.title_closing_prayer;
    final endingTitle = l10n.title_ending_sign_of_cross;

    // ── 1. General Intentions (Before Starting) ───────────────────────────────
    items.add(const _GuideItem.generalIntention());

    // ── 2. Opening Prayers ───────────────────────────────────────────────────
    items.add(_GuideItem.prayer(title: signOfCrossTitle, text: signOfCross));
    items.add(
      _GuideItem.prayer(title: apostlesCreedTitle, text: apostlesCreed),
    );
    items.add(_GuideItem.prayer(title: ourFatherTitle, text: ourFather));
    items.add(
      _GuideItem.prayer(title: hailMaryTitle, text: hailMary, repeatCount: 3),
    );
    items.add(_GuideItem.prayer(title: gloryBeTitle, text: gloryBe));

    // ── 3. 5 Decades ─────────────────────────────────────────────────────────
    for (int d = 0; d < 5; d++) {
      final ordinal = ordinals[d];
      final mysteryName = mysteryNames[d];
      final mysteryTitlePattern = isEn
          ? 'The $ordinal Mystery: $setName'
          : 'Ang $ordinal $setName';

      // Highlighted Mystery Announcement (with embedded intention)
      items.add(
        _GuideItem.mystery(title: mysteryTitlePattern, subtitle: mysteryName),
      );

      // Our Father
      items.add(_GuideItem.prayer(title: ourFatherTitle, text: ourFather));

      // Hail Mary (Repeat 10x)
      items.add(
        _GuideItem.prayer(
          title: hailMaryTitle,
          text: hailMary,
          repeatCount: 10,
        ),
      );

      // Glory Be
      items.add(_GuideItem.prayer(title: gloryBeTitle, text: gloryBe));

      // Fatima Prayer
      items.add(_GuideItem.prayer(title: fatimaTitle, text: fatima));
    }

    // ── 4. Closing Prayers ────────────────────────────────────────────────────
    items.add(_GuideItem.prayer(title: salveReginaTitle, text: salveRegina));
    items.add(_GuideItem.prayer(title: closingTitle, text: closingPrayer));
    items.add(_GuideItem.prayer(title: endingTitle, text: signOfCross));

    return items;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final mysteryType = ref.watch(guideMysteryProvider);
    final intention = ref.watch(guideIntentionProvider);
    final activeIndex = ref.watch(guideActiveIndexProvider);

    final guideItems = _buildGuideItems(mysteryType, lang);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.guide_title,
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
                          ref.read(guideActiveIndexProvider.notifier).state =
                              null;
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
                itemCount: guideItems.length,
                itemBuilder: (context, index) {
                  final item = guideItems[index];
                  final isActive = activeIndex == index;
                  void onTap() {
                    final notifier = ref.read(
                      guideActiveIndexProvider.notifier,
                    );
                    notifier.state = (notifier.state == index) ? null : index;
                  }

                  switch (item.type) {
                    case _GuideItemType.generalIntention:
                      return _buildGeneralIntentionCard(
                        context,
                        userIntention: intention,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        isActive: isActive,
                        onTap: onTap,
                      );
                    case _GuideItemType.mystery:
                      return _buildMysteryCard(
                        context,
                        title: item.title,
                        subtitle: item.subtitle!,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        isActive: isActive,
                        onTap: onTap,
                      );
                    case _GuideItemType.prayer:
                      return _buildPrayerCard(
                        context,
                        title: item.title,
                        body: item.text,
                        repeatCount: item.repeatCount,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        isActive: isActive,
                        onTap: onTap,
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralIntentionCard(
    BuildContext context, {
    required String? userIntention,
    required bool isDark,
    required Color primaryColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final l10n = AppLocalizations.of(context);
    final sectionTitle = l10n.guide_intention_section_title;
    final note = l10n.guide_intention_note;
    final sampleLabel = l10n.guide_intention_example_label;
    final sampleText = l10n.intention_input_hint;
    final yourIntentionLabel = l10n.your_intention_label;
    final activeBadge = l10n.active_badge;

    final borderColor = isActive
        ? primaryColor
        : (isDark ? const Color(0xFF5C3D2E) : const Color(0xFFD2BEA6));
    final cardBg = isActive
        ? (isDark
              ? primaryColor.withValues(alpha: 0.15)
              : primaryColor.withValues(alpha: 0.08))
        : Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: isActive ? 2.0 : 1.0),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isActive ? '📍' : '🙏',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sectionTitle,
                      style: GoogleFonts.cinzel(
                        color: primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        activeBadge,
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFF1A0F0A),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                note,
                style: GoogleFonts.spectral(
                  color: isDark
                      ? const Color(0xFFF5E6D3)
                      : const Color(0xFF1A0F0A),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (userIntention != null && userIntention.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        yourIntentionLabel,
                        style: GoogleFonts.cinzel(
                          color: primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"${userIntention.trim()}"',
                        style: GoogleFonts.spectral(
                          color: isDark
                              ? const Color(0xFFF5E6D3)
                              : const Color(0xFF1A0F0A),
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Text(
                  sampleLabel,
                  style: GoogleFonts.cinzel(
                    color: isDark
                        ? const Color(0xFFBFA98A)
                        : const Color(0xFF5C3D2E),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"$sampleText"',
                  style: GoogleFonts.spectral(
                    color: isDark
                        ? const Color(0xFFBFA98A)
                        : const Color(0xFF5C3D2E),
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMysteryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isDark,
    required Color primaryColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final l10n = AppLocalizations.of(context);
    final borderColor = isActive
        ? primaryColor
        : (isDark ? primaryColor.withValues(alpha: 0.6) : primaryColor);
    final cardBg = isActive
        ? (isDark ? const Color(0xFF3B2418) : const Color(0xFFFFF0E0))
        : (isDark ? const Color(0xFF2A1B12) : const Color(0xFFFFF8F0));

    final noteText = l10n.decade_intention_note;
    final intentionPhrase = l10n.decade_intention_phrase;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8.0, bottom: 12.0),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: isActive ? 2.5 : 1.5),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(
                alpha: isActive ? 0.4 : (isDark ? 0.25 : 0.15),
              ),
              blurRadius: isActive ? 14 : 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Accent Bar
              Container(
                height: isActive ? 5 : 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      primaryColor.withValues(alpha: 0.5),
                      primaryColor,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(
                          alpha: isActive ? 0.3 : 0.15,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isActive ? '📍' : '✨',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: GoogleFonts.cinzel(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.spectral(
                              color: isDark
                                  ? const Color(0xFFF5E6D3)
                                  : const Color(0xFF1A0F0A),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF19100B)
                                  : const Color(0xFFFAF2E9),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      '💡',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        l10n.decade_intention_title,
                                        style: GoogleFonts.cinzel(
                                          color: primaryColor,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  noteText,
                                  style: GoogleFonts.spectral(
                                    color: isDark
                                        ? const Color(0xFFD4C3AC)
                                        : const Color(0xFF4A3427),
                                    fontSize: 12.5,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  intentionPhrase,
                                  style: GoogleFonts.spectral(
                                    color: isDark
                                        ? const Color(0xFFF5E6D3)
                                        : const Color(0xFF1A0F0A),
                                    fontSize: 13.5,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildPrayerCard(
    BuildContext context, {
    required String title,
    required String body,
    int? repeatCount,
    required bool isDark,
    required Color primaryColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark
                    ? primaryColor.withValues(alpha: 0.16)
                    : primaryColor.withValues(alpha: 0.08))
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive
                ? primaryColor
                : (isDark ? const Color(0xFF3D2517) : const Color(0xFFE5D3BD)),
            width: isActive ? 2.0 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isActive) ...[
                  Icon(Icons.bookmark_rounded, color: primaryColor, size: 18),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cinzel(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                if (repeatCount != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      l10n.repeat_x.replaceAll('X', 'X$repeatCount'),
                      style: GoogleFonts.cinzel(
                        color: isDark ? const Color(0xFFF5E6D3) : primaryColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
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
      ),
    );
  }
}
