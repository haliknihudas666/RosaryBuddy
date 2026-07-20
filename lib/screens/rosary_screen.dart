import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../data/rosary_data.dart';
import '../data/localization_data.dart';
import '../main.dart';
import '../models/mystery_type.dart';
import '../models/rosary_step.dart';
import '../painters/rosary_painter.dart';
import '../widgets/control_bar.dart';
import '../widgets/prayer_panel.dart';

class RosaryScreen extends StatefulWidget {
  const RosaryScreen({super.key});

  @override
  State<RosaryScreen> createState() => _RosaryScreenState();
}

class _RosaryScreenState extends State<RosaryScreen>
    with TickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────────────────
  late MysteryType _mysteryType;
  late List<RosaryStep> _steps;
  int _currentStepIndex = 0;
  int _speakingStepIndex = -1;
  int _lastProcessedCompletedIndex = -1;
  bool _isAutoMode = false;
  bool _isSpeaking = false;
  bool _ttsReady = false;
  bool _ttsEnabled = true;
  Set<int> _completedBeads = {};
  int _currentBeadIndex = -1;

  // ── TTS & Audio ───────────────────────────────────────────────────────────
  late FlutterEdgeTts _edgeTts;
  late AudioPlayer _audioPlayer;
  String? _tempAudioPath;

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _mysteryType = getTodaysMystery();
    _steps = buildRosarySteps(_mysteryType, languageNotifier.value);
    _updateBeadState();
    _initAudioAndTts();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  Future<void> _initAudioAndTts() async {
    _audioPlayer = AudioPlayer();
    final voice = languageNotifier.value == 'en'
        ? 'en-US-JennyNeural'
        : 'fil-PH-BlessicaNeural';
    _edgeTts = FlutterEdgeTts(
      voice: voice,
      enableSentenceBoundary: false,
      enableWordBoundary: false,
    );

    final voices = await _edgeTts.getVoices();
    log(voices.map((e) => e.shortName).join(', '));

    // Get temp directory for storing the voice files
    try {
      final tempDir = await getTemporaryDirectory();
      _tempAudioPath = '${tempDir.path}/rosary_prayer.mp3';
    } catch (e) {
      debugPrint("Error getting temp dir: $e");
    }

    // Completion listener to advance in auto-play mode
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() => _isSpeaking = false);
          if (_isAutoMode &&
              _lastProcessedCompletedIndex != _currentStepIndex) {
            _lastProcessedCompletedIndex = _currentStepIndex;
            _advanceStep();
          }
        }
      }
    });

    if (mounted) setState(() => _ttsReady = true);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _edgeTts.close();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Bead state helpers ────────────────────────────────────────────────────

  void _updateBeadState() {
    final currentBead = _steps[_currentStepIndex].beadIndex;
    final done = <int>{};
    for (int i = 0; i < _currentStepIndex; i++) {
      final b = _steps[i].beadIndex;
      if (b != currentBead) done.add(b);
    }
    _currentBeadIndex = currentBead;
    _completedBeads = done;
  }

  // ── Step navigation ───────────────────────────────────────────────────────

  void _advanceStep() {
    if (_currentStepIndex >= _steps.length - 1) {
      // Rosary is complete.
      setState(() {
        _isAutoMode = false;
        _isSpeaking = false;
      });
      _audioPlayer.stop();
      _showCompletionDialog();
      return;
    }
    setState(() {
      _currentStepIndex++;
      _updateBeadState();
    });
    if (_isAutoMode) _speakCurrentStep();
  }

  void _previousStep() {
    if (_currentStepIndex <= 0) return;
    _audioPlayer.stop();
    setState(() {
      _isAutoMode = false;
      _isSpeaking = false;
      _currentStepIndex--;
      _lastProcessedCompletedIndex = -1;
      _updateBeadState();
    });
    _speakCurrentStep();
  }

  void _tapNext() {
    HapticFeedback.lightImpact();
    _audioPlayer.stop();
    if (_isAutoMode) setState(() => _isAutoMode = false);
    _lastProcessedCompletedIndex = -1;
    _advanceStep();
    _speakCurrentStep();
  }

  Future<void> _speakCurrentStep() async {
    if (!_ttsReady) return;
    final targetIndex = _currentStepIndex;
    _speakingStepIndex = targetIndex;

    await _audioPlayer.stop();
    if (_speakingStepIndex != targetIndex || !mounted) return;

    if (!_ttsEnabled) {
      setState(() => _isSpeaking = false);
      if (_isAutoMode) {
        // In auto-mode, if TTS is disabled, pause shortly then go to next bead automatically.
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (_isAutoMode && mounted && _currentStepIndex == targetIndex) {
            _advanceStep();
          }
        });
      }
      return;
    }

    setState(() => _isSpeaking = true);

    try {
      final ttsText = _steps[targetIndex].ttsText;

      if (_tempAudioPath != null) {
        // Synthesize to a file to avoid any platform byte stream limitations
        await _edgeTts.synthesizeToFile(
          ttsText,
          audioFilePath: _tempAudioPath!,
        );
        if (_speakingStepIndex != targetIndex || !mounted) return;

        await _audioPlayer.setFilePath(_tempAudioPath!);
        if (_speakingStepIndex != targetIndex || !mounted) return;

        await _audioPlayer.play();
      } else {
        // Fallback: direct synthesis to bytes if path provider failed
        final result = await _edgeTts.synthesize(ttsText);
        if (_speakingStepIndex != targetIndex || !mounted) return;

        final tempFile = File(
          '${Directory.systemTemp.path}/rosary_fallback.mp3',
        );
        await tempFile.writeAsBytes(result.audioBytes);
        if (_speakingStepIndex != targetIndex || !mounted) return;

        await _audioPlayer.setFilePath(tempFile.path);
        if (_speakingStepIndex != targetIndex || !mounted) return;

        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("TTS Error: $e");
      if (mounted && _speakingStepIndex == targetIndex) {
        if (_isAutoMode) {
          Future.delayed(const Duration(seconds: 2), () {
            if (_isAutoMode && mounted && _currentStepIndex == targetIndex) {
              _speakCurrentStep();
            }
          });
        } else {
          setState(() => _isSpeaking = false);
        }
      }
    }
  }

  void _toggleAutoMode() {
    HapticFeedback.mediumImpact();
    setState(() => _isAutoMode = !_isAutoMode);
    if (_isAutoMode) {
      setState(() => _ttsEnabled = true);
      _speakCurrentStep();
    } else {
      _audioPlayer.stop();
      setState(() => _isSpeaking = false);
    }
  }

  void _restart() {
    HapticFeedback.heavyImpact();
    _audioPlayer.stop();
    setState(() {
      _currentStepIndex = 0;
      _lastProcessedCompletedIndex = -1;
      _isAutoMode = false;
      _isSpeaking = false;
      _updateBeadState();
    });
  }

  void _setMysteryType(MysteryType type) {
    if (type == _mysteryType) return;
    _audioPlayer.stop();
    setState(() {
      _mysteryType = type;
      _steps = buildRosarySteps(type, languageNotifier.value);
      _currentStepIndex = 0;
      _lastProcessedCompletedIndex = -1;
      _isAutoMode = false;
      _isSpeaking = false;
      _updateBeadState();
    });
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showCompletionDialog() {
    final lang = languageNotifier.value;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF3D2517),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFFCA8A04), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌹', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                LocalizationData.getText(lang, 'dialog_title'),
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFCA8A04),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                LocalizationData.getText(lang, 'dialog_body'),
                textAlign: TextAlign.center,
                style: GoogleFonts.spectral(
                  color: const Color(0xFFBFA98A),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF5C3D2E)),
                        backgroundColor: Colors.transparent,
                        foregroundColor: const Color(0xFFBFA98A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        LocalizationData.getText(lang, 'dialog_close'),
                        style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _restart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCA8A04),
                        foregroundColor: const Color(0xFF1A0F0A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        LocalizationData.getText(lang, 'dialog_again'),
                        style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStepIndex];
    final isComplete = _currentStepIndex >= _steps.length - 1;
    final lang = languageNotifier.value;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildMysterySelector(),
            // ── Rosary canvas – tapping anywhere advances one step ──────────
            Expanded(
              flex: 5,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _tapNext,
                child: CustomPaint(
                  painter: RosaryPainter(
                    activeBeadIndex: _currentBeadIndex,
                    completedBeads: _completedBeads,
                    pulseAnim: _pulseAnim,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
            // ── Prayer text panel ──────────────────────────────────────────
            Expanded(
              flex: 4,
              child: PrayerPanel(
                step: step,
                stepIndex: _currentStepIndex,
                totalSteps: _steps.length,
                isSpeaking: _isSpeaking,
                lang: lang,
              ),
            ),
            // ── Controls ──────────────────────────────────────────────────
            ControlBar(
              isAutoMode: _isAutoMode,
              isSpeaking: _isSpeaking,
              canGoBack: _currentStepIndex > 0,
              canGoForward: !isComplete,
              isComplete: isComplete,
              lang: lang,
              onPrevious: _previousStep,
              onNext: _tapNext,
              onRestart: _restart,
              onToggleAuto: _toggleAutoMode,
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = languageNotifier.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Text(
            LocalizationData.getText(lang, 'app_title'),
            style: GoogleFonts.cinzel(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            onPressed: () {
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              _ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _ttsEnabled
                  ? Theme.of(context).colorScheme.primary
                  : (isDark
                        ? const Color(0xFF5C3D2E)
                        : const Color(0xFFD2BEA6)),
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _ttsEnabled = !_ttsEnabled;
                if (!_ttsEnabled) {
                  _audioPlayer.stop();
                  _isSpeaking = false;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMysterySelector() {
    final today = getTodaysMystery();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? const Color(0xFF5C3D2E)
        : const Color(0xFFD2BEA6);
    final lang = languageNotifier.value;

    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(12, 2, 12, 4),
      child: Row(
        children: MysteryType.values.map((type) {
          final selected = _mysteryType == type;
          final isToday = type == today;
          return Expanded(
            child: GestureDetector(
              onTap: () => _setMysteryType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : isToday
                        ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                        : borderColor,
                    width: selected ? 1.4 : 0.9,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(type.emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 1),
                    Text(
                      type.getDisplayName(lang),
                      style: GoogleFonts.cinzel(
                        color: selected
                            ? const Color(0xFF1A0F0A)
                            : (isDark
                                  ? const Color(0xFFBFA98A)
                                  : const Color(0xFF5C3D2E)),
                        fontSize: 8.5,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
