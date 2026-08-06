import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../models/mystery_type.dart';
import '../models/rosary_step.dart';

/// Repository responsible for building rosary prayer sequences
/// and determining the day's mystery type.
class RosaryRepository {
  const RosaryRepository();

  /// Returns the mystery type prescribed for the current day of the week.
  MysteryType getTodaysMystery() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case DateTime.monday:
      case DateTime.saturday:
        return MysteryType.joyful;
      case DateTime.tuesday:
      case DateTime.friday:
        return MysteryType.sorrowful;
      case DateTime.wednesday:
      case DateTime.sunday:
        return MysteryType.glorious;
      case DateTime.thursday:
      default:
        return MysteryType.luminous;
    }
  }

  /// Builds the full list of rosary steps for a given mystery and language.
  List<RosaryStep> buildSteps(
    MysteryType mysteryType,
    String lang, {
    String? intention,
  }) {
    final l10n = lookupAppLocalizations(Locale(lang));
    final isEn = lang == 'en';
    final setName = mysteryType.getSetName(lang);
    final mysteryNames = mysteryType.getMysteryNames(lang);
    final steps = <RosaryStep>[];

    // Prayer text references from localization
    final signOfCross = l10n.text_sign_of_cross;
    final apostlesCreed = l10n.text_apostles_creed;
    final ourFather = l10n.text_our_father;
    final hailMary = l10n.text_hail_mary;
    final gloryBe = l10n.text_glory_be;
    final fatima = l10n.text_fatima;
    final salveRegina = l10n.text_salve_regina;
    final closingPrayer = l10n.text_closing_prayer;
    final endingTts = l10n.text_ending_tts;

    final ordinals = [
      l10n.ordinal_1,
      l10n.ordinal_2,
      l10n.ordinal_3,
      l10n.ordinal_4,
      l10n.ordinal_5,
    ];

    // Title strings from localization data
    final intentionTitle = l10n.general_intention_title;
    final signOfCrossTitle = l10n.title_sign_of_cross;
    final apostlesCreedTitle = l10n.title_apostles_creed;
    final ourFatherTitle = l10n.title_our_father;
    final hailMaryTitle = l10n.title_hail_mary;
    final gloryBeTitle = l10n.title_glory_be;
    final fatimaTitle = l10n.title_fatima_prayer;
    final salveReginaTitle = l10n.title_salve_regina;
    final closingTitle = l10n.title_closing_prayer;
    final endingTitle = l10n.title_ending_sign_of_cross;

    // ── Opening ──────────────────────────────────────────────────────────────
    if (intention != null && intention.trim().isNotEmpty) {
      steps.add(RosaryStep(
        beadIndex: -1,
        title: intentionTitle,
        text: intention.trim(),
        category: PrayerCategory.intention,
        beadType: BeadType.cross,
      ));
    }

    steps.add(RosaryStep(
      beadIndex: -1,
      title: signOfCrossTitle,
      text: signOfCross,
      category: PrayerCategory.signOfCross,
      beadType: BeadType.cross,
    ));
    steps.add(RosaryStep(
      beadIndex: -1,
      title: apostlesCreedTitle,
      text: apostlesCreed,
      category: PrayerCategory.apostlesCreed,
      beadType: BeadType.cross,
    ));
    steps.add(RosaryStep(
      beadIndex: 0,
      title: ourFatherTitle,
      text: ourFather,
      category: PrayerCategory.ourFather,
      beadType: BeadType.large,
    ));

    // 3 Hail Marys on the pendant tail
    for (int i = 1; i <= 3; i++) {
      steps.add(RosaryStep(
        beadIndex: i,
        title: hailMaryTitle,
        text: hailMary,
        ttsText: hailMary,
        category: PrayerCategory.hailMary,
        beadType: BeadType.small,
        stepCounter: isEn ? '$i of 3' : '$i ng 3',
      ));
    }

    // Glory Be at the junction
    steps.add(RosaryStep(
      beadIndex: 3,
      title: gloryBeTitle,
      text: gloryBe,
      category: PrayerCategory.gloryBe,
      beadType: BeadType.small,
    ));

    // ── 5 Decades ────────────────────────────────────────────────────────────
    for (int d = 0; d < 5; d++) {
      final mysteryBeadIdx = 4 + d * 11;
      final firstHmIdx = mysteryBeadIdx + 1;
      final lastHmIdx = firstHmIdx + 9;
      final ordinal = ordinals[d];
      final mysteryName = mysteryNames[d];

      final mysteryTitle = isEn ? 'The $ordinal Mystery' : 'Ang $ordinal';

      // Mystery announcement
      steps.add(RosaryStep(
        beadIndex: mysteryBeadIdx,
        title: isEn ? '$mysteryTitle: $setName' : '$mysteryTitle $setName',
        text: mysteryName,
        ttsText: isEn
            ? '$mysteryTitle. $setName. $mysteryName.'
            : 'Ang $ordinal $setName. $mysteryName.',
        category: PrayerCategory.mysteryAnnouncement,
        beadType: BeadType.large,
        isMystery: true,
        mysterySubtitle: mysteryName,
        customAudioKey: 'mystery_${mysteryType.name}_$d',
      ));

      // Our Father on the same large bead
      steps.add(RosaryStep(
        beadIndex: mysteryBeadIdx,
        title: ourFatherTitle,
        text: ourFather,
        category: PrayerCategory.ourFather,
        beadType: BeadType.large,
      ));

      // 10 Hail Marys
      for (int i = 0; i < 10; i++) {
        steps.add(RosaryStep(
          beadIndex: firstHmIdx + i,
          title: hailMaryTitle,
          text: hailMary,
          category: PrayerCategory.hailMary,
          beadType: BeadType.small,
          stepCounter: isEn ? '${i + 1} of 10' : '${i + 1} ng 10',
        ));
      }

      // Glory Be
      steps.add(RosaryStep(
        beadIndex: lastHmIdx,
        title: gloryBeTitle,
        text: gloryBe,
        category: PrayerCategory.gloryBe,
        beadType: BeadType.small,
      ));

      // Fatima Prayer
      steps.add(RosaryStep(
        beadIndex: lastHmIdx,
        title: fatimaTitle,
        text: fatima,
        category: PrayerCategory.fatima,
        beadType: BeadType.small,
      ));
    }

    // ── Closing ───────────────────────────────────────────────────────────────
    steps.add(RosaryStep(
      beadIndex: -1,
      title: salveReginaTitle,
      text: salveRegina,
      category: PrayerCategory.salveRegina,
      beadType: BeadType.cross,
    ));
    steps.add(RosaryStep(
      beadIndex: -1,
      title: closingTitle,
      text: closingPrayer,
      category: PrayerCategory.closing,
      beadType: BeadType.cross,
    ));

    steps.add(RosaryStep(
      beadIndex: -1,
      title: endingTitle,
      text: signOfCross,
      ttsText: endingTts,
      category: PrayerCategory.signOfCross,
      beadType: BeadType.cross,
    ));

    return steps;
  }
}
