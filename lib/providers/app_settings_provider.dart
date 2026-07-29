import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the app-wide theme mode (light/dark).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Manages the app-wide language setting ('tl' or 'en').
class LanguageNotifier extends Notifier<String> {
  @override
  String build() => 'tl';

  void setLanguage(String lang) => state = lang;
}

final languageProvider =
    NotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);
