import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ModeSelectorWidget extends StatelessWidget {
  final String currentMode; // 'focus', 'shortBreak', 'longBreak'
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final AppThemeData themeData;
  final ValueChanged<String> onModeChanged;

  const ModeSelectorWidget({
    super.key,
    required this.currentMode,
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.themeData,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: themeData.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeData.cardBorder, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeTab(
            title: 'Focus',
            durationText: '${focusMinutes}m',
            modeKey: 'focus',
            isSelected: currentMode == 'focus',
            activeColor: themeData.focusColor,
            themeData: themeData,
            onTap: () => onModeChanged('focus'),
          ),
          _ModeTab(
            title: 'Short Break',
            durationText: '${shortBreakMinutes}m',
            modeKey: 'shortBreak',
            isSelected: currentMode == 'shortBreak',
            activeColor: themeData.shortBreakColor,
            themeData: themeData,
            onTap: () => onModeChanged('shortBreak'),
          ),
          _ModeTab(
            title: 'Long Break',
            durationText: '${longBreakMinutes}m',
            modeKey: 'longBreak',
            isSelected: currentMode == 'longBreak',
            activeColor: themeData.longBreakColor,
            themeData: themeData,
            onTap: () => onModeChanged('longBreak'),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String title;
  final String durationText;
  final String modeKey;
  final bool isSelected;
  final Color activeColor;
  final AppThemeData themeData;
  final VoidCallback onTap;

  const _ModeTab({
    required this.title,
    required this.durationText,
    required this.modeKey,
    required this.isSelected,
    required this.activeColor,
    required this.themeData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor.withValues(alpha: 0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : themeData.textSecondary,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.25)
                    : themeData.bgCardLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                durationText,
                style: AppFonts.mono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? activeColor : themeData.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
