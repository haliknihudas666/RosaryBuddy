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

  final String? customAudioKey;

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
    this.customAudioKey,
  }) : ttsText = ttsText ?? text;

  /// Returns the unique filename key for local cached audio (e.g. "tl_hail_mary.mp3").
  /// Returns null if this step is a dynamic intention or cannot be cached statically.
  String? getAudioKey(String lang) {
    if (customAudioKey != null) {
      return '${lang}_${customAudioKey}.mp3';
    }
    switch (category) {
      case PrayerCategory.signOfCross:
        return ttsText.contains('finished') || ttsText.contains('natapos')
            ? '${lang}_ending_tts.mp3'
            : '${lang}_sign_of_cross.mp3';
      case PrayerCategory.apostlesCreed:
        return '${lang}_apostles_creed.mp3';
      case PrayerCategory.ourFather:
        return '${lang}_our_father.mp3';
      case PrayerCategory.hailMary:
        return '${lang}_hail_mary.mp3';
      case PrayerCategory.gloryBe:
        return '${lang}_glory_be.mp3';
      case PrayerCategory.fatima:
        return '${lang}_fatima.mp3';
      case PrayerCategory.salveRegina:
        return '${lang}_salve_regina.mp3';
      case PrayerCategory.closing:
        return '${lang}_closing.mp3';
      case PrayerCategory.intention:
      case PrayerCategory.mysteryAnnouncement:
        return null;
    }
  }
}

