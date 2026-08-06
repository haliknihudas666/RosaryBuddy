import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../data/models/mystery_type.dart';
import '../../data/repositories/rosary_repository.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/offline_audio_provider.dart';
import '../widgets/intention_dialog.dart';
import 'rosary_screen.dart';
import 'rosary_guide_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final offlineState = ref.watch(offlineAudioProvider);
    final todayMystery = const RosaryRepository().getTodaysMystery();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMutedColor =
        isDark ? const Color(0xFFBFA98A) : const Color(0xFF5C3D2E);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Language Selector, Theme Toggle, and Offline Audio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language select control (Pill shape)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF5C3D2E)
                            : const Color(0xFFD2BEA6),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLangBtn(context, ref, 'TL', lang == 'tl',
                            () {
                          ref
                              .read(languageProvider.notifier)
                              .setLanguage('tl');
                        }),
                        _buildLangBtn(context, ref, 'EN', lang == 'en',
                            () {
                          ref
                              .read(languageProvider.notifier)
                              .setLanguage('en');
                        }),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Offline Audio Button
                      IconButton(
                        tooltip: 'Offline Prayers',
                        icon: offlineState.isDownloading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : Icon(
                                offlineState.isFullyDownloaded
                                    ? Icons.offline_pin_rounded
                                    : Icons.cloud_download_rounded,
                                color: offlineState.isFullyDownloaded
                                    ? const Color(0xFF4CAF50)
                                    : Theme.of(context).colorScheme.primary,
                              ),
                        onPressed: () =>
                            _showOfflineAudioDialog(context, ref),
                      ),
                      // Theme Toggle
                      IconButton(
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          ref.read(themeModeProvider.notifier).toggle();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(flex: 2),
              // App Logo / Symbol
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌹', style: TextStyle(fontSize: 44)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // App Title
              Center(
                child: Text(
                  AppLocalizations.of(context).app_title,
                  style: GoogleFonts.cinzel(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${AppLocalizations.of(context).today_mystery}: ${todayMystery.getDisplayName(lang)} (${todayMystery.emoji})',
                  style: GoogleFonts.spectral(
                    color: textMutedColor,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Option 1: Interactive Rosary
              _buildMenuCard(
                context: context,
                title: AppLocalizations.of(context).interactive_title,
                subtitle: AppLocalizations.of(context).interactive_subtitle,
                icon: Icons.explore_rounded,
                onTap: () async {
                  final intention = await IntentionDialog.show(context);
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RosaryScreen(
                          initialIntention: intention,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              // Option 2: Rosary Guide (Reading Mode)
              _buildMenuCard(
                context: context,
                title: AppLocalizations.of(context).guide_title,
                subtitle: AppLocalizations.of(context).guide_subtitle,
                icon: Icons.menu_book_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RosaryGuideScreen(),
                    ),
                  );
                },
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangBtn(
    BuildContext context,
    WidgetRef ref,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.cinzel(
            color: active
                ? const Color(0xFF1A0F0A)
                : (isDark
                    ? const Color(0xFFBFA98A)
                    : const Color(0xFF5C3D2E)),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF5C3D2E) : const Color(0xFFD2BEA6);
    final textMutedColor =
        isDark ? const Color(0xFFBFA98A) : const Color(0xFF5C3D2E);
    final textMainColor =
        isDark ? const Color(0xFFF5E6D3) : const Color(0xFF1A0F0A);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Column(
          children: [
            Container(
                height: 2,
                color: Theme.of(context).colorScheme.primary),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.15),
                highlightColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A0F0A)
                              : const Color(0xFFF5E6D3),
                          borderRadius: BorderRadius.circular(4),
                          border:
                              Border.all(color: borderColor, width: 1),
                        ),
                        child: Icon(
                          icon,
                          color:
                              Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.cinzel(
                                color: textMainColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: GoogleFonts.spectral(
                                color: textMutedColor,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfflineAudioDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(offlineAudioProvider);
            final progress = state.totalCount > 0
                ? state.downloadedCount / state.totalCount
                : 0.0;
            final percent = (progress * 100).toInt();

            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark
                      ? const Color(0xFF5C3D2E)
                      : const Color(0xFFD2BEA6),
                ),
              ),
              title: Row(
                children: [
                  Icon(
                    state.isFullyDownloaded
                        ? Icons.offline_pin_rounded
                        : Icons.cloud_download_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Offline Audio',
                    style: GoogleFonts.cinzel(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.isFullyDownloaded
                        ? 'All 58 prayer audio files in Tagalog and English are downloaded and ready for 100% offline use.'
                        : 'Download prayer audio files to pray the Holy Rosary offline without internet connection.',
                    style: GoogleFonts.spectral(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: state.totalCount > 0 ? progress : 0,
                    backgroundColor: isDark
                        ? const Color(0xFF2A1A12)
                        : const Color(0xFFE8DCCF),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.downloadedCount} / ${state.totalCount} downloaded',
                        style: GoogleFonts.spectral(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: GoogleFonts.cinzel(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: GoogleFonts.cinzel(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: state.isDownloading
                      ? null
                      : () {
                          ref
                              .read(offlineAudioProvider.notifier)
                              .downloadAllPrayers();
                        },
                  icon: state.isDownloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    state.isDownloading
                        ? 'Downloading...'
                        : (state.isFullyDownloaded
                            ? 'Re-download All'
                            : 'Download Offline'),
                    style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

