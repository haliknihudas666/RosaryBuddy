import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/localization/localization_data.dart';
import '../../data/models/rosary_step.dart';
import 'pulsing_dot.dart';

/// Panel displaying the current prayer text, title, progress bar, and
/// special cards for mystery announcements and intentions.
class PrayerPanel extends StatelessWidget {
  final RosaryStep step;
  final int stepIndex;
  final int totalSteps;
  final bool isSpeaking;
  final String lang;

  const PrayerPanel({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.isSpeaking,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                height: 2, color: Theme.of(context).colorScheme.primary),
            _buildHandle(context),
            _buildProgressBar(context),
            _buildTitle(context),
            Expanded(child: _buildPrayerText(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color:
              isDark ? const Color(0xFF5C3D2E) : const Color(0xFFD2BEA6),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = (stepIndex + 1) / totalSteps;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMutedColor =
        isDark ? const Color(0xFFBFA98A) : const Color(0xFF5C3D2E);

    final stepWord = LocalizationData.getText(lang, 'step');
    final ofWord = LocalizationData.getText(lang, 'of');
    final readingWord = LocalizationData.getText(lang, 'reading');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$stepWord ${stepIndex + 1} $ofWord $totalSteps',
                style: GoogleFonts.spectral(
                  color: textMutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isSpeaking)
                Row(
                  children: [
                    const PulsingDot(),
                    const SizedBox(width: 5),
                    Text(
                      readingWord,
                      style: GoogleFonts.cinzel(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? const Color(0xFF1A0F0A)
                  : const Color(0xFFF5E6D3),
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMutedColor =
        isDark ? const Color(0xFFBFA98A) : const Color(0xFF5C3D2E);
    final dividerColor =
        isDark ? const Color(0xFF3D2517) : const Color(0xFFE5D3BD);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.title,
                  style: GoogleFonts.cinzel(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (step.stepCounter != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF581C87).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: const Color(0xFF581C87),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    step.stepCounter!,
                    style: GoogleFonts.cinzel(
                      color: isDark
                          ? const Color(0xFFF5E6D3)
                          : const Color(0xFF581C87),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (step.isMystery && step.mysterySubtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              step.mysterySubtitle!,
              style: GoogleFonts.spectral(
                color: textMutedColor,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          Divider(color: dividerColor, height: 12, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildPrayerText(BuildContext context) {
    final isMysteryAnnounce =
        step.category == PrayerCategory.mysteryAnnouncement;
    final isIntention = step.category == PrayerCategory.intention;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMainColor =
        isDark ? const Color(0xFFF5E6D3) : const Color(0xFF1A0F0A);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: isMysteryAnnounce
          ? _buildMysteryCard(context)
          : isIntention
              ? _buildIntentionCard(context)
              : Text(
                  step.text,
                  style: GoogleFonts.spectral(
                    color: textMainColor,
                    fontSize: 16,
                    height: 1.7,
                  ),
                ),
    );
  }

  Widget _buildIntentionCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMainColor =
        isDark ? const Color(0xFFF5E6D3) : const Color(0xFF1A0F0A);
    final textMutedColor =
        isDark ? const Color(0xFFBFA98A) : const Color(0xFF5C3D2E);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark ? const Color(0xFF3D2517) : const Color(0xFFD2BEA6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.40),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volunteer_activism_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                step.title.toUpperCase(),
                style: GoogleFonts.cinzel(
                  color: textMutedColor,
                  fontSize: 11,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step.text,
            style: GoogleFonts.spectral(
              color: textMainColor,
              fontSize: 16.5,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMysteryCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMainColor =
        isDark ? const Color(0xFFF5E6D3) : const Color(0xFF1A0F0A);
    final textMutedColor =
        isDark ? const Color(0xFFBFA98A) : const Color(0xFF5C3D2E);

    final meditationWord = LocalizationData.getText(lang, 'meditation');
    final nextOurFatherWord =
        LocalizationData.getText(lang, 'next_our_father');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark ? const Color(0xFF3D2517) : const Color(0xFFD2BEA6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.40),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🙏  $meditationWord',
            style: GoogleFonts.cinzel(
              color: textMutedColor,
              fontSize: 11,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.mysterySubtitle ?? step.text,
            style: GoogleFonts.spectral(
              color: textMainColor,
              fontSize: 17,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            nextOurFatherWord,
            style: GoogleFonts.cinzel(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 11,
              letterSpacing: 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
