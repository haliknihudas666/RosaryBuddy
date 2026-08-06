import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'offline_audio_repository.dart';

/// Repository encapsulating TTS synthesis, offline caching, and audio playback.
class TtsRepository {
  FlutterEdgeTts? _edgeTts;
  final AudioPlayer audioPlayer = AudioPlayer();
  final OfflineAudioRepository _offlineRepo = OfflineAudioRepository();
  String? _tempAudioPath;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialises the TTS engine and audio player.
  Future<void> init(String lang) async {
    final voice = lang == 'en'
        ? 'en-US-JennyNeural'
        : 'fil-PH-BlessicaNeural';
    _edgeTts = FlutterEdgeTts(
      voice: voice,
      enableSentenceBoundary: false,
      enableWordBoundary: false,
    );

    try {
      await _edgeTts!.getVoices();
    } catch (e) {
      debugPrint("Edge TTS getVoices error (may be offline): $e");
    }

    try {
      final tempDir = await getTemporaryDirectory();
      _tempAudioPath = '${tempDir.path}/rosary_prayer.mp3';
    } catch (e) {
      debugPrint("Error getting temp dir: $e");
    }

    _isInitialized = true;
  }

  /// Synthesises and plays back the given [text].
  /// If [audioKey] is provided, attempts to play from local cache first.
  Future<void> speak(String text, {String? audioKey}) async {
    await audioPlayer.stop();

    // 1. Try local offline cache first
    if (audioKey != null) {
      final cachedPath = await _offlineRepo.getCachedFilePath(audioKey);
      if (cachedPath != null) {
        try {
          await audioPlayer.setFilePath(cachedPath);
          await audioPlayer.play();
          return;
        } catch (e) {
          debugPrint("Error playing cached file ($audioKey): $e");
        }
      }
    }

    if (!_isInitialized || _edgeTts == null) return;

    // 2. Synthesize via Edge TTS and cache result if online
    try {
      if (audioKey != null) {
        final result = await _edgeTts!.synthesize(text);
        if (result.audioBytes.isNotEmpty) {
          final savedPath = await _offlineRepo.saveAudioBytes(audioKey, result.audioBytes);
          await audioPlayer.setFilePath(savedPath);
          await audioPlayer.play();
          return;
        }
      }

      if (_tempAudioPath != null) {
        await _edgeTts!.synthesizeToFile(
          text,
          audioFilePath: _tempAudioPath!,
        );
        await audioPlayer.setFilePath(_tempAudioPath!);
        await audioPlayer.play();
      } else {
        final result = await _edgeTts!.synthesize(text);
        final tempFile = File(
          '${Directory.systemTemp.path}/rosary_fallback.mp3',
        );
        await tempFile.writeAsBytes(result.audioBytes);
        await audioPlayer.setFilePath(tempFile.path);
        await audioPlayer.play();
      }
    } catch (e) {
      debugPrint("TTS synthesis error: $e");
      rethrow;
    }
  }

  /// Stops any active playback.
  Future<void> stop() async {
    await audioPlayer.stop();
  }

  /// Stream of processing state changes — useful for detecting playback completion.
  Stream<ProcessingState> get processingStateStream =>
      audioPlayer.processingStateStream;

  /// Disposes all resources.
  void dispose() {
    audioPlayer.dispose();
    _edgeTts?.close();
  }
}
