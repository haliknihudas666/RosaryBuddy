import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/localization_data.dart';
import '../../data/models/mystery_type.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/rosary_session_provider.dart';
import '../../providers/tts_provider.dart';
import '../painters/rosary_painter.dart';
import '../widgets/control_bar.dart';
import '../widgets/mystery_selector.dart';
import '../widgets/prayer_panel.dart';

class RosaryScreen extends ConsumerStatefulWidget {
  final String? initialIntention;

  const RosaryScreen({
    super.key,
    this.initialIntention,
  });

  @override
  ConsumerState<RosaryScreen> createState() => _RosaryScreenState();
}

class _RosaryScreenState extends ConsumerState<RosaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Initialise session with intention once built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(rosarySessionProvider.notifier)
          .init(intention: widget.initialIntention);
      ref.read(ttsProvider.notifier).speakCurrentStep();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onStepChanged() {
    ref.read(ttsProvider.notifier).speakCurrentStep();
  }

  void _showCompletionDialog() {
    final lang = ref.read(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDark
                ? const Color(0xFF5C3D2E)
                : const Color(0xFFD2BEA6),
            width: 1.5,
          ),
        ),
        title: Column(
          children: [
            const Text('🌹', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              LocalizationData.getText(lang, 'dialog_title'),
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          LocalizationData.getText(lang, 'dialog_body'),
          textAlign: TextAlign.center,
          style: GoogleFonts.spectral(
            color: isDark
                ? const Color(0xFFF5E6D3)
                : const Color(0xFF1A0F0A),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(rosarySessionProvider.notifier).restart();
              _onStepChanged();
            },
            child: Text(
              LocalizationData.getText(lang, 'dialog_again'),
              style: GoogleFonts.cinzel(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: const Color(0xFF1A0F0A),
            ),
            child: Text(
              LocalizationData.getText(lang, 'dialog_close'),
              style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(rosarySessionProvider);
    final ttsState = ref.watch(ttsProvider);
    final lang = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentStep = session.currentStep;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            ref.read(ttsProvider.notifier).stop();
            Navigator.pop(context);
          },
        ),
        title: Text(
          LocalizationData.getText(lang, 'interactive_title'),
          style: GoogleFonts.cinzel(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              ttsState.ttsEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: ttsState.ttsEnabled
                  ? Theme.of(context).colorScheme.primary
                  : (isDark
                      ? const Color(0xFF5C3D2E)
                      : const Color(0xFFD2BEA6)),
            ),
            onPressed: () {
              ref.read(ttsProvider.notifier).toggleEnabled();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mystery Type Selector Row
            MysterySelector(
              selectedType: session.mysteryType,
              onSelected: (type) {
                ref.read(ttsProvider.notifier).stop();
                ref
                    .read(rosarySessionProvider.notifier)
                    .setMysteryType(type);
                _onStepChanged();
              },
            ),

            // Canvas Rosary View
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: double.infinity,
                child: CustomPaint(
                  painter: RosaryPainter(
                    activeBeadIndex: currentStep.beadIndex,
                    completedBeads: session.completedBeads,
                    pulseAnim: _pulseController,
                    isDark: isDark,
                  ),
                ),
              ),
            ),

            // Bottom Panel: Prayer Text + Controls
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  Expanded(
                    child: PrayerPanel(
                      step: currentStep,
                      stepIndex: session.currentStepIndex,
                      totalSteps: session.steps.length,
                      isSpeaking: ttsState.isSpeaking,
                      lang: lang,
                    ),
                  ),
                  ControlBar(
                    isAutoMode: session.isAutoMode,
                    isSpeaking: ttsState.isSpeaking,
                    canGoBack: session.currentStepIndex > 0,
                    canGoForward: !session.isComplete,
                    isComplete: session.isComplete,
                    lang: lang,
                    onPrevious: () {
                      HapticFeedback.lightImpact();
                      ref.read(ttsProvider.notifier).stop();
                      ref.read(rosarySessionProvider.notifier).previousStep();
                      _onStepChanged();
                    },
                    onNext: () {
                      HapticFeedback.lightImpact();
                      ref.read(ttsProvider.notifier).stop();
                      final isDone = ref
                          .read(rosarySessionProvider.notifier)
                          .advanceStep();
                      if (isDone) {
                        _showCompletionDialog();
                      } else {
                        _onStepChanged();
                      }
                    },
                    onRestart: () {
                      HapticFeedback.mediumImpact();
                      ref.read(ttsProvider.notifier).stop();
                      ref.read(rosarySessionProvider.notifier).restart();
                      _onStepChanged();
                    },
                    onToggleAuto: () {
                      HapticFeedback.selectionClick();
                      final sessionNotifier =
                          ref.read(rosarySessionProvider.notifier);
                      sessionNotifier.toggleAutoMode();
                      if (ref.read(rosarySessionProvider).isAutoMode &&
                          !ref.read(ttsProvider).isSpeaking) {
                        _onStepChanged();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
