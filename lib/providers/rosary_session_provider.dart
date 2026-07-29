import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/mystery_type.dart';
import '../data/models/rosary_step.dart';
import '../data/repositories/rosary_repository.dart';
import 'app_settings_provider.dart';

/// The rosary repository, provided as a singleton.
final rosaryRepositoryProvider = Provider<RosaryRepository>((ref) {
  return const RosaryRepository();
});

/// Immutable state snapshot for the interactive rosary session.
@immutable
class RosarySessionState {
  final MysteryType mysteryType;
  final List<RosaryStep> steps;
  final int currentStepIndex;
  final String? intention;
  final bool isAutoMode;
  final Set<int> completedBeads;
  final int currentBeadIndex;

  const RosarySessionState({
    required this.mysteryType,
    required this.steps,
    this.currentStepIndex = 0,
    this.intention,
    this.isAutoMode = false,
    this.completedBeads = const {},
    this.currentBeadIndex = -1,
  });

  RosaryStep get currentStep => steps[currentStepIndex];
  bool get isComplete => currentStepIndex >= steps.length - 1;

  RosarySessionState copyWith({
    MysteryType? mysteryType,
    List<RosaryStep>? steps,
    int? currentStepIndex,
    String? intention,
    bool? isAutoMode,
    Set<int>? completedBeads,
    int? currentBeadIndex,
  }) {
    return RosarySessionState(
      mysteryType: mysteryType ?? this.mysteryType,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      intention: intention ?? this.intention,
      isAutoMode: isAutoMode ?? this.isAutoMode,
      completedBeads: completedBeads ?? this.completedBeads,
      currentBeadIndex: currentBeadIndex ?? this.currentBeadIndex,
    );
  }
}

/// Notifier managing all interactive rosary session state.
class RosarySessionNotifier extends Notifier<RosarySessionState> {
  @override
  RosarySessionState build() {
    final repo = ref.read(rosaryRepositoryProvider);
    final lang = ref.read(languageProvider);
    final mystery = repo.getTodaysMystery();
    final steps = repo.buildSteps(mystery, lang);
    return RosarySessionState(
      mysteryType: mystery,
      steps: steps,
    );
  }

  /// Initialise with an optional intention (called once on screen entry).
  void init({String? intention}) {
    if (intention == null && state.intention == null) return;
    final repo = ref.read(rosaryRepositoryProvider);
    final lang = ref.read(languageProvider);
    final steps = repo.buildSteps(state.mysteryType, lang, intention: intention);
    state = RosarySessionState(
      mysteryType: state.mysteryType,
      steps: steps,
      intention: intention,
    );
  }

  /// Returns `true` if the rosary was completed by this advance.
  bool advanceStep() {
    if (state.isComplete) return true;
    final nextIndex = state.currentStepIndex + 1;
    state = _withBeadState(state.copyWith(currentStepIndex: nextIndex));
    return state.isComplete;
  }

  void previousStep() {
    if (state.currentStepIndex <= 0) return;
    state = _withBeadState(state.copyWith(
      currentStepIndex: state.currentStepIndex - 1,
      isAutoMode: false,
    ));
  }

  void restart() {
    state = _withBeadState(state.copyWith(
      currentStepIndex: 0,
      isAutoMode: false,
    ));
  }

  void setAutoMode(bool value) {
    state = state.copyWith(isAutoMode: value);
  }

  void toggleAutoMode() {
    state = state.copyWith(isAutoMode: !state.isAutoMode);
  }

  void setMysteryType(MysteryType type) {
    if (type == state.mysteryType) return;
    final repo = ref.read(rosaryRepositoryProvider);
    final lang = ref.read(languageProvider);
    final steps = repo.buildSteps(type, lang, intention: state.intention);
    state = RosarySessionState(
      mysteryType: type,
      steps: steps,
      intention: state.intention,
    );
  }

  /// Recalculates completedBeads and currentBeadIndex from the current step.
  RosarySessionState _withBeadState(RosarySessionState s) {
    final currentBead = s.steps[s.currentStepIndex].beadIndex;
    final done = <int>{};
    for (int i = 0; i < s.currentStepIndex; i++) {
      final b = s.steps[i].beadIndex;
      if (b != currentBead) done.add(b);
    }
    return s.copyWith(
      currentBeadIndex: currentBead,
      completedBeads: done,
    );
  }
}

final rosarySessionProvider =
    NotifierProvider<RosarySessionNotifier, RosarySessionState>(
        RosarySessionNotifier.new);
