import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TimerControlsWidget extends StatelessWidget {
  final bool isRunning;
  final String mode;
  final AppThemeData themeData;
  final VoidCallback onTogglePlay;
  final VoidCallback onReset;
  final VoidCallback onSkip;
  final VoidCallback onAdd5Minutes;
  final bool soundEnabled;
  final VoidCallback onToggleSound;

  const TimerControlsWidget({
    super.key,
    required this.isRunning,
    required this.mode,
    required this.themeData,
    required this.onTogglePlay,
    required this.onReset,
    required this.onSkip,
    required this.onAdd5Minutes,
    required this.soundEnabled,
    required this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    final modeColor = themeData.getModeColor(mode);

    return Column(
      children: [
        // Main action row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reset Button
            _ActionButton(
              icon: Icons.refresh_rounded,
              tooltip: 'Reset Timer',
              onPressed: onReset,
              themeData: themeData,
            ),

            const SizedBox(width: 20),

            // Big Play / Pause Button with Glow
            GestureDetector(
              onTap: onTogglePlay,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      modeColor,
                      modeColor.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: modeColor.withValues(alpha: isRunning ? 0.5 : 0.3),
                      blurRadius: isRunning ? 24 : 14,
                      spreadRadius: isRunning ? 3 : 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 38,
                    color: themeData.brightness == Brightness.dark
                        ? Colors.black87
                        : Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Skip Button
            _ActionButton(
              icon: Icons.skip_next_rounded,
              tooltip: 'Skip to Next',
              onPressed: onSkip,
              themeData: themeData,
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Secondary quick-actions row (+5m & Sound toggle)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Quick +5 Min button
            InkWell(
              onTap: onAdd5Minutes,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: themeData.bgCardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: themeData.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.more_time_rounded, size: 16, color: themeData.textPrimary),
                    const SizedBox(width: 6),
                    Text(
                      '+5 Min',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: themeData.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Sound Toggle
            InkWell(
              onTap: onToggleSound,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: themeData.bgCardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: soundEnabled
                        ? modeColor.withValues(alpha: 0.5)
                        : themeData.cardBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      size: 16,
                      color: soundEnabled ? modeColor : themeData.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      soundEnabled ? 'Sound On' : 'Muted',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: soundEnabled ? modeColor : themeData.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final AppThemeData themeData;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeData.bgCard,
              border: Border.all(color: themeData.cardBorder, width: 1.2),
            ),
            child: Icon(
              icon,
              size: 24,
              color: themeData.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
