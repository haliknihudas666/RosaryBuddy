import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';

/// Bottom control bar for the interactive rosary screen.
///
/// Now a ConsumerWidget that reads providers directly instead of taking
/// many constructor parameters.
class ControlBar extends StatelessWidget {
  final bool isAutoMode;
  final bool isSpeaking;
  final bool canGoBack;
  final bool canGoForward;
  final bool isComplete;
  final String lang;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onRestart;
  final VoidCallback onToggleAuto;

  const ControlBar({
    super.key,
    required this.isAutoMode,
    required this.isSpeaking,
    required this.canGoBack,
    required this.canGoForward,
    required this.isComplete,
    required this.lang,
    required this.onPrevious,
    required this.onNext,
    required this.onRestart,
    required this.onToggleAuto,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topBorderColor = isDark
        ? const Color(0xFF3D2517)
        : const Color(0xFFE5D3BD);
    final buttonColor = isDark
        ? const Color(0xFFBFA98A)
        : const Color(0xFF5C3D2E);
    final disabledColor = isDark
        ? const Color(0xFF5C3D2E)
        : const Color(0xFFD2BEA6);
    final iconColor = canGoForward
        ? (isDark ? const Color(0xFF1A0F0A) : const Color(0xFFF5E6D3))
        : disabledColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(top: BorderSide(color: topBorderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CtrlBtn(
            icon: Icons.replay,
            label: AppLocalizations.of(context).restart,
            onTap: onRestart,
            color: buttonColor,
          ),
          _CtrlBtn(
            icon: Icons.skip_previous_rounded,
            label: AppLocalizations.of(context).back,
            onTap: canGoBack ? onPrevious : null,
            color: buttonColor,
          ),
          // Centre: big Next button
          GestureDetector(
            onTap: canGoForward ? onNext : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: canGoForward
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      )
                    : Border.all(color: disabledColor, width: 1),
                gradient: canGoForward
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          const Color(0xFFB8780A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: canGoForward
                    ? null
                    : (isDark
                          ? const Color(0xFF2C1A10)
                          : const Color(0xFFE5D3BD)),
                boxShadow: canGoForward
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.20),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isComplete ? Icons.check_rounded : Icons.skip_next_rounded,
                color: iconColor,
                size: 30,
              ),
            ),
          ),
          _CtrlBtn(
            icon: isAutoMode
                ? Icons.pause_circle_filled_rounded
                : Icons.play_circle_fill_rounded,
            label: isAutoMode
                ? AppLocalizations.of(context).stop
                : AppLocalizations.of(context).auto,
            onTap: onToggleAuto,
            color: isAutoMode
                ? Theme.of(context).colorScheme.primary
                : buttonColor,
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double iconSize;

  const _CtrlBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.35,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.cinzel(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
