enum BeadType { cross, large, small }

enum PrayerCategory {
  intention,
  signOfCross,
  apostlesCreed,
  ourFather,
  hailMary,
  gloryBe,
  fatima,
  mysteryAnnouncement,
  salveRegina,
  closing,
}

class RosaryStep {
  /// -1 = cross pendant, 0..58 = bead index on rosary
  final int beadIndex;
  final String title;
  final String text;
  final String ttsText;
  final PrayerCategory category;
  final BeadType beadType;
  final bool isMystery;
  final String? mysterySubtitle;
  // e.g. "3 ng 10" for Hail Mary progress within a decade
  final String? stepCounter;

  RosaryStep({
    required this.beadIndex,
    required this.title,
    required this.text,
    String? ttsText,
    required this.category,
    required this.beadType,
    this.isMystery = false,
    this.mysterySubtitle,
    this.stepCounter,
  }) : ttsText = ttsText ?? text;
}
