import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

/// Repository encapsulating TTS synthesis and audio playback.
///
/// This separates the audio/TTS lifecycle from the UI layer.
class TtsRepository {
  FlutterEdgeTts? _edgeTts;
  final AudioPlayer audioPlayer = AudioPlayer();
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

    await _edgeTts!.getVoices();

    try {
      final tempDir = await getTemporaryDirectory();
      _tempAudioPath = '${tempDir.path}/rosary_prayer.mp3';
    } catch (e) {
      debugPrint("Error getting temp dir: $e");
    }

    _isInitialized = true;
  }

  /// Synthesises and plays back the given [text].
  ///
  /// Returns immediately if TTS is not yet initialised.
  Future<void> speak(String text) async {
    if (!_isInitialized || _edgeTts == null) return;

    await audioPlayer.stop();

    if (_tempAudioPath != null) {
      await _edgeTts!.synthesizeToFile(
        text,
        audioFilePath: _tempAudioPath!,
      );
      await audioPlayer.setFilePath(_tempAudioPath!);
      await audioPlayer.play();
    } else {
      // Fallback: direct synthesis to bytes
      final result = await _edgeTts!.synthesize(text);
      final tempFile = File(
        '${Directory.systemTemp.path}/rosary_fallback.mp3',
      );
      await tempFile.writeAsBytes(result.audioBytes);
      await audioPlayer.setFilePath(tempFile.path);
      await audioPlayer.play();
    }
  }

  /// Stops any active playback.
  Future<void> stop() async {
    await audioPlayer.stop();
  }

  /// Stream of processing state changes — useful for detecting playback
  /// completion.
  Stream<ProcessingState> get processingStateStream =>
      audioPlayer.processingStateStream;

  /// Disposes all resources.
  void dispose() {
    audioPlayer.dispose();
    _edgeTts?.close();
  }
}
