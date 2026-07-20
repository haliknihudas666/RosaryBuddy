import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/rosary_data.dart';
import '../data/localization_data.dart';
import '../main.dart';
import '../models/mystery_type.dart';

class RosaryGuideScreen extends StatefulWidget {
  const RosaryGuideScreen({super.key});

  @override
  State<RosaryGuideScreen> createState() => _RosaryGuideScreenState();
}

class _RosaryGuideScreenState extends State<RosaryGuideScreen> {
  late MysteryType _mysteryType;

  @override
  void initState() {
    super.initState();
    _mysteryType = getTodaysMystery();
  }

  void _setMysteryType(MysteryType type) {
    if (type == _mysteryType) return;
    HapticFeedback.selectionClick();
    setState(() {
      _mysteryType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = languageNotifier.value;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocalizationData.getText(lang, 'guide_title'),
          style: GoogleFonts.cinzel(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              themeNotifier.value =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMysterySelector(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildRosaryGuideContent(lang),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMysterySelector() {
    final today = getTodaysMystery();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF5C3D2E) : const Color(0xFFD2BEA6);
    final lang = languageNotifier.value;

    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(12, 2, 12, 12),
      child: Row(
        children: MysteryType.values.map((type) {
          final selected = _mysteryType == type;
          final isToday = type == today;
          return Expanded(
            child: GestureDetector(
              onTap: () => _setMysteryType(type),
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
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                          )
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
                            : (isDark ? const Color(0xFFBFA98A) : const Color(0xFF5C3D2E)),
                        fontSize: 8.5,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
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

  List<Widget> _buildRosaryGuideContent(String lang) {
    final isEn = lang == 'en';
    final List<Widget> widgets = [];
    final mysterySetName = _mysteryType.getSetName(lang).toUpperCase();
    final mysteryNames = _mysteryType.getMysteryNames(lang);

    final ordinals = isEn
        ? ['FIRST', 'SECOND', 'THIRD', 'FOURTH', 'FIFTH']
        : ['UNANG', 'IKALAWANG', 'IKATLONG', 'IKAAPAT NA', 'IKALIMANG'];

    // Prayer titles
    final signOfCrossTitle = isEn ? 'THE SIGN OF THE CROSS' : 'ANG PAG-ANTANDA NG KRUS';
    final apostlesCreedTitle = isEn ? 'THE APOSTLES\' CREED' : 'ANG SUMASAMPALATAYA';
    final ourFatherTitle = isEn ? 'OUR FATHER' : 'AMA NAMIN';
    final hailMaryTitle = isEn ? 'HAIL MARY' : 'ABA GINOONG MARIA';
    final gloryBeTitle = isEn ? 'GLORY BE' : 'LUWALHATI';
    final fatimaTitle = isEn ? 'THE FATIMA PRAYER' : 'PANALANGIN NG FATIMA';
    final salveReginaTitle = isEn ? 'HAIL, HOLY QUEEN' : 'ABA PO, SANTA MARIANG BIRHEN';
    final closingTitle = isEn ? 'LET US PRAY' : 'MANALANGIN TAYO';

    // 1. SIGN OF THE CROSS
    widgets.add(_buildPrayerSection(signOfCrossTitle, isEn ? kSignOfCrossEn : kSignOfCrossTl));

    // 2. APOSTLES' CREED
    widgets.add(_buildPrayerSection(apostlesCreedTitle, isEn ? kApostlesCreedEn : kApostlesCreedTl));

    // 3. OUR FATHER
    widgets.add(_buildPrayerSection(ourFatherTitle, isEn ? kOurFatherEn : kOurFatherTl));

    // 4. HAIL MARY (Repeat x 3)
    widgets.add(_buildPrayerSection(
      hailMaryTitle,
      isEn ? kHailMaryEn : kHailMaryTl,
      repeatCount: 3,
      lang: lang,
    ));

    // 5. GLORY BE
    widgets.add(_buildPrayerSection(gloryBeTitle, isEn ? kGloryBeEn : kGloryBeTl));

    // 6. Decades
    for (int i = 0; i < 5; i++) {
      final ordinal = ordinals[i];
      final mysteryName = mysteryNames[i];

      final titlePattern = isEn ? 'THE $ordinal MYSTERY: $mysterySetName' : 'ANG $ordinal $mysterySetName';

      widgets.add(_buildMysteryAnnouncementSection(
        titlePattern,
        mysteryName,
      ));

      widgets.add(_buildPrayerSection(ourFatherTitle, isEn ? kOurFatherEn : kOurFatherTl));

      widgets.add(_buildPrayerSection(
        hailMaryTitle,
        isEn ? kHailMaryEn : kHailMaryTl,
        repeatCount: 10,
        lang: lang,
      ));

      widgets.add(_buildPrayerSection(gloryBeTitle, isEn ? kGloryBeEn : kGloryBeTl));

      widgets.add(_buildPrayerSection(fatimaTitle, isEn ? kFatimaEn : kFatimaTl));
    }

    // 7. HAIL, HOLY QUEEN
    widgets.add(_buildPrayerSection(salveReginaTitle, isEn ? kSalveReginaEn : kSalveReginaTl));

    // 8. LET US PRAY
    widgets.add(_buildPrayerSection(closingTitle, isEn ? kClosingPrayerEn : kClosingPrayerTl));

    // 9. ENDING SIGN OF THE CROSS
    widgets.add(_buildPrayerSection(signOfCrossTitle, isEn ? kSignOfCrossEn : kSignOfCrossTl));

    // Extra bottom padding
    widgets.add(const SizedBox(height: 40));

    return widgets;
  }

  Widget _buildPrayerSection(String title, String body, {int? repeatCount, String? lang}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.cinzel(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              if (repeatCount != null && lang != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF581C87).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: const Color(0xFF581C87),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    LocalizationData.getText(lang, 'repeat_x').replaceAll('X', 'X$repeatCount'),
                    style: GoogleFonts.cinzel(
                      color: isDark ? const Color(0xFFF5E6D3) : const Color(0xFF581C87),
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
              color: isDark ? const Color(0xFFF5E6D3) : const Color(0xFF1A0F0A),
              fontSize: 15.5,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMysteryAnnouncementSection(String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF5C3D2E) : const Color(0xFFD2BEA6);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8.0, bottom: 24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 2, color: Theme.of(context).colorScheme.primary),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cinzel(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.spectral(
                      color: isDark ? const Color(0xFFF5E6D3) : const Color(0xFF1A0F0A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
