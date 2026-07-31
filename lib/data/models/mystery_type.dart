import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

enum MysteryType { joyful, sorrowful, glorious, luminous }

extension MysteryTypeExtension on MysteryType {
  String getSetName(String lang) {
    final l10n = lookupAppLocalizations(Locale(lang));
    switch (this) {
      case MysteryType.joyful:
        return l10n.mystery_set_joyful;
      case MysteryType.sorrowful:
        return l10n.mystery_set_sorrowful;
      case MysteryType.glorious:
        return l10n.mystery_set_glorious;
      case MysteryType.luminous:
        return l10n.mystery_set_luminous;
    }
  }

  String getDisplayName(String lang) {
    final l10n = lookupAppLocalizations(Locale(lang));
    switch (this) {
      case MysteryType.joyful:
        return l10n.mystery_display_joyful;
      case MysteryType.sorrowful:
        return l10n.mystery_display_sorrowful;
      case MysteryType.glorious:
        return l10n.mystery_display_glorious;
      case MysteryType.luminous:
        return l10n.mystery_display_luminous;
    }
  }

  String get emoji {
    switch (this) {
      case MysteryType.joyful:
        return '🌸';
      case MysteryType.sorrowful:
        return '✝️';
      case MysteryType.glorious:
        return '✨';
      case MysteryType.luminous:
        return '💡';
    }
  }

  String getDayText(String lang) {
    final l10n = lookupAppLocalizations(Locale(lang));
    switch (this) {
      case MysteryType.joyful:
        return l10n.mystery_day_joyful;
      case MysteryType.sorrowful:
        return l10n.mystery_day_sorrowful;
      case MysteryType.glorious:
        return l10n.mystery_day_glorious;
      case MysteryType.luminous:
        return l10n.mystery_day_luminous;
    }
  }

  List<String> getMysteryNames(String lang) {
    final l10n = lookupAppLocalizations(Locale(lang));
    switch (this) {
      case MysteryType.joyful:
        return [
          l10n.joyful_1,
          l10n.joyful_2,
          l10n.joyful_3,
          l10n.joyful_4,
          l10n.joyful_5,
        ];
      case MysteryType.sorrowful:
        return [
          l10n.sorrowful_1,
          l10n.sorrowful_2,
          l10n.sorrowful_3,
          l10n.sorrowful_4,
          l10n.sorrowful_5,
        ];
      case MysteryType.glorious:
        return [
          l10n.glorious_1,
          l10n.glorious_2,
          l10n.glorious_3,
          l10n.glorious_4,
          l10n.glorious_5,
        ];
      case MysteryType.luminous:
        return [
          l10n.luminous_1,
          l10n.luminous_2,
          l10n.luminous_3,
          l10n.luminous_4,
          l10n.luminous_5,
        ];
    }
  }
}
