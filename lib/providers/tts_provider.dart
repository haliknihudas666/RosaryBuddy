import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../data/repositories/tts_repository.dart';
import 'app_settings_provider.dart';
import 'rosary_session_provider.dart';

/// Immutable state for the TTS subsystem.
@immutable
class TtsState {
  final bool isSpeaking;
  final bool ttsReady;
  final bool ttsEnabled;

  const TtsState({
    this.isSpeaking = false,
    this.ttsReady = false,
    this.ttsEnabled = true,
  });

  TtsState copyWith({
    bool? isSpeaking,
    bool? ttsReady,
    bool? ttsEnabled,
  }) {
    return TtsState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      ttsReady: ttsReady ?? this.ttsReady,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
    );
  }
}

/// Notifier managing TTS lifecycle and playback state.
class TtsNotifier extends Notifier<TtsState> {
  late final TtsRepository _repo;

  @override
  TtsState build() {
    _repo = TtsRepository();

    // Listen for audio completion to auto-advance.
    _repo.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        state = state.copyWith(isSpeaking: false);
        final session = ref.read(rosarySessionProvider);
        if (session.isAutoMode) {
          final sessionNotifier = ref.read(rosarySessionProvider.notifier);
          final completed = sessionNotifier.advanceStep();
          if (!completed) {
            speakCurrentStep();
          }
        }
      }
    });

    // Initialise asynchronously.
    _initAsync();

    // Clean up on disposal.
    ref.onDispose(() {
      _repo.dispose();
    });

    return const TtsState();
  }

  Future<void> _initAsync() async {
    final lang = ref.read(languageProvider);
    await _repo.init(lang);
    state = state.copyWith(ttsReady: true);
  }

  /// Speaks the current rosary step's TTS text.
  Future<void> speakCurrentStep() async {
    if (!state.ttsReady) return;

    if (!state.ttsEnabled) {
      state = state.copyWith(isSpeaking: false);
      final session = ref.read(rosarySessionProvider);
      if (session.isAutoMode) {
        final targetIndex = session.currentStepIndex;
        Future.delayed(const Duration(milliseconds: 1500), () {
          final current = ref.read(rosarySessionProvider);
          if (current.isAutoMode && current.currentStepIndex == targetIndex) {
            final notifier = ref.read(rosarySessionProvider.notifier);
            final completed = notifier.advanceStep();
            if (!completed) speakCurrentStep();
          }
        });
      }
      return;
    }

    state = state.copyWith(isSpeaking: true);

    final session = ref.read(rosarySessionProvider);
    final targetIndex = session.currentStepIndex;
    final ttsText = session.currentStep.ttsText;

    try {
      await _repo.speak(ttsText);
    } catch (e) {
      debugPrint("TTS Error: $e");
      final currentSession = ref.read(rosarySessionProvider);
      if (currentSession.currentStepIndex == targetIndex) {
        if (currentSession.isAutoMode) {
          Future.delayed(const Duration(seconds: 2), () {
            final latest = ref.read(rosarySessionProvider);
            if (latest.isAutoMode &&
                latest.currentStepIndex == targetIndex) {
              speakCurrentStep();
            }
          });
        } else {
          state = state.copyWith(isSpeaking: false);
        }
      }
    }
  }

  /// Stops playback.
  Future<void> stop() async {
    await _repo.stop();
    state = state.copyWith(isSpeaking: false);
  }

  /// Toggles TTS enabled/disabled.
  void toggleEnabled() {
    final wasEnabled = state.ttsEnabled;
    state = state.copyWith(ttsEnabled: !wasEnabled);
    if (wasEnabled) {
      _repo.stop();
      state = state.copyWith(isSpeaking: false);
    }
  }

  /// Access to the underlying repository for direct audio player control.
  TtsRepository get repository => _repo;
}

final ttsProvider =
    NotifierProvider<TtsNotifier, TtsState>(TtsNotifier.new);
