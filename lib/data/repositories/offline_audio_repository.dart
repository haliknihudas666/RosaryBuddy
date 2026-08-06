import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:path_provider/path_provider.dart';

import '../../l10n/app_localizations.dart';
import '../models/mystery_type.dart';
import 'rosary_repository.dart';

class OfflineAudioItem {
  final String audioKey;
  final String lang;
  final String ttsText;
  final String voice;

  const OfflineAudioItem({
    required this.audioKey,
    required this.lang,
    required this.ttsText,
    required this.voice,
  });
}

/// Repository responsible for checking, saving, and downloading local cached audio files.
class OfflineAudioRepository {
  Directory? _cacheDir;

  Future<Directory> getCacheDirectory() async {
    if (_cacheDir != null) return _cacheDir!;
    final appDocs = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDocs.path}/audio_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  /// Returns the absolute path of the cached audio file if it exists, otherwise null.
  Future<String?> getCachedFilePath(String audioKey) async {
    final dir = await getCacheDirectory();
    final file = File('${dir.path}/$audioKey');
    if (await file.exists() && (await file.length()) > 0) {
      return file.path;
    }
    return null;
  }

  /// Saves raw audio bytes to local cache.
  Future<String> saveAudioBytes(String audioKey, List<int> bytes) async {
    final dir = await getCacheDirectory();
    final file = File('${dir.path}/$audioKey');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Builds the complete list of static prayer audio items across English and Tagalog.
  List<OfflineAudioItem> buildAllPrayerManifest() {
    final items = <OfflineAudioItem>[];
    const rosaryRepo = RosaryRepository();

    for (final lang in ['en', 'tl']) {
      final voice = lang == 'en'
          ? 'en-US-JennyNeural'
          : 'fil-PH-BlessicaNeural';
      final l10n = lookupAppLocalizations(Locale(lang));

      // 1. Standard Prayers
      final standardPrayers = <String, String>{
        '${lang}_sign_of_cross.mp3': l10n.text_sign_of_cross,
        '${lang}_apostles_creed.mp3': l10n.text_apostles_creed,
        '${lang}_our_father.mp3': l10n.text_our_father,
        '${lang}_hail_mary.mp3': l10n.text_hail_mary,
        '${lang}_glory_be.mp3': l10n.text_glory_be,
        '${lang}_fatima.mp3': l10n.text_fatima,
        '${lang}_salve_regina.mp3': l10n.text_salve_regina,
        '${lang}_closing.mp3': l10n.text_closing_prayer,
        '${lang}_ending_tts.mp3': l10n.text_ending_tts,
      };

      standardPrayers.forEach((key, text) {
        items.add(
          OfflineAudioItem(
            audioKey: key,
            lang: lang,
            ttsText: text,
            voice: voice,
          ),
        );
      });

      // 2. Mystery Announcements across all 4 mystery types
      for (final mysteryType in MysteryType.values) {
        final steps = rosaryRepo.buildSteps(mysteryType, lang);
        final mysterySteps = steps.where((s) => s.isMystery).toList();
        for (final step in mysterySteps) {
          final key = step.getAudioKey(lang);
          if (key != null) {
            items.add(
              OfflineAudioItem(
                audioKey: key,
                lang: lang,
                ttsText: step.ttsText,
                voice: voice,
              ),
            );
          }
        }
      }
    }

    return items;
  }

  /// Synthesizes and caches a single audio item using FlutterEdgeTts.
  Future<bool> preCacheAudioItem(OfflineAudioItem item) async {
    final existing = await getCachedFilePath(item.audioKey);
    if (existing != null) return true;

    try {
      final tts = FlutterEdgeTts(
        voice: item.voice,
        enableSentenceBoundary: false,
        enableWordBoundary: false,
      );
      final result = await tts.synthesize(item.ttsText);
      await tts.close();

      if (result.audioBytes.isNotEmpty) {
        await saveAudioBytes(item.audioKey, result.audioBytes);
        return true;
      }
    } catch (e) {
      debugPrint('Failed to synthesize ${item.audioKey}: $e');
    }
    return false;
  }
}
