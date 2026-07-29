import '../datasources/prayer_texts.dart';
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
    final isEn = lang == 'en';
    final setName = mysteryType.getSetName(lang);
    final mysteryNames = mysteryType.getMysteryNames(lang);
    final steps = <RosaryStep>[];

    // Prayer text references
    final signOfCross = isEn ? kSignOfCrossEn : kSignOfCrossTl;
    final apostlesCreed = isEn ? kApostlesCreedEn : kApostlesCreedTl;
    final ourFather = isEn ? kOurFatherEn : kOurFatherTl;
    final hailMary = isEn ? kHailMaryEn : kHailMaryTl;
    final gloryBe = isEn ? kGloryBeEn : kGloryBeTl;
    final fatima = isEn ? kFatimaEn : kFatimaTl;
    final salveRegina = isEn ? kSalveReginaEn : kSalveReginaTl;
    final closingPrayer = isEn ? kClosingPrayerEn : kClosingPrayerTl;
    final ordinals = isEn ? _ordinalsEn : _ordinalsTl;

    // Title strings
    final intentionTitle =
        isEn ? 'General Intentions' : 'Pangkalahatang Intensyon';
    final signOfCrossTitle =
        isEn ? 'The Sign of the Cross' : 'Ang Pag-antanda ng Krus';
    final apostlesCreedTitle =
        isEn ? 'The Apostles\' Creed' : 'Ang Sumasampalataya';
    final ourFatherTitle = isEn ? 'Our Father' : 'Ama Namin';
    final hailMaryTitle = isEn ? 'Hail Mary' : 'Aba Ginoong Maria';
    final gloryBeTitle = isEn ? 'Glory Be' : 'Luwalhati';
    final fatimaTitle =
        isEn ? 'The Fatima Prayer' : 'Panalangin ng Fatima';
    final salveReginaTitle =
        isEn ? 'Hail, Holy Queen' : 'Aba Po, Santa Mariang Birhen';
    final closingTitle = isEn ? 'Let Us Pray' : 'Manalangin Tayo';
    final endingTitle = isEn
        ? 'Ending — The Sign of the Cross'
        : 'Pagtatapos — Ang Pag-antanda ng Krus';

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

    final endingTts = isEn
        ? 'In the name of the Father, and of the Son, and of the Holy Spirit. Amen. We have finished praying the Holy Rosary. Thanks be to God.'
        : 'Sa ngalan ng Ama, ng Anak at ng Espiritu Santo. Amen. Natapos na ang ating pag-dasal ng Santo Rosaryo. Salamat sa Diyos.';

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

// ─── Ordinals ─────────────────────────────────────────────────────────────────

const _ordinalsTl = [
  'Unang',
  'Ikalawang',
  'Ikatlong',
  'Ikaapat na',
  'Ikalimang',
];

const _ordinalsEn = [
  'First',
  'Second',
  'Third',
  'Fourth',
  'Fifth',
];
