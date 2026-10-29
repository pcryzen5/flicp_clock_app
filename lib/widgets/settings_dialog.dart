import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pomodoro_settings.dart';
import '../theme/app_theme.dart';

class SettingsDialog extends StatefulWidget {
  final PomodoroSettings initialSettings;
  final AppThemeData currentTheme;
  final ValueChanged<PomodoroSettings> onSave;

  const SettingsDialog({
    super.key,
    required this.initialSettings,
    required this.currentTheme,
    required this.onSave,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late int _focusMinutes;
  late int _shortBreakMinutes;
  late int _longBreakMinutes;
  late int _longBreakInterval;
  late bool _autoStartBreaks;
  late bool _autoStartPomodoros;
  late bool _soundEnabled;
  late int _selectedThemeIndex;
  late String _ambientSound;
  late double _ambientVolume;

  @override
  void initState() {
    super.initState();
    _focusMinutes = widget.initialSettings.focusMinutes;
    _shortBreakMinutes = widget.initialSettings.shortBreakMinutes;
    _longBreakMinutes = widget.initialSettings.longBreakMinutes;
    _longBreakInterval = widget.initialSettings.longBreakInterval;
    _autoStartBreaks = widget.initialSettings.autoStartBreaks;
    _autoStartPomodoros = widget.initialSettings.autoStartPomodoros;
    _soundEnabled = widget.initialSettings.soundEnabled;
    _selectedThemeIndex = widget.initialSettings.selectedThemeIndex;
    _ambientSound = widget.initialSettings.ambientSound;
    _ambientVolume = widget.initialSettings.ambientVolume;
  }

  void _triggerSave() {
    final updated = widget.initialSettings.copyWith(
      focusMinutes: _focusMinutes,
      shortBreakMinutes: _shortBreakMinutes,
      longBreakMinutes: _longBreakMinutes,
      longBreakInterval: _longBreakInterval,
      autoStartBreaks: _autoStartBreaks,
      autoStartPomodoros: _autoStartPomodoros,
      soundEnabled: _soundEnabled,
      selectedThemeIndex: _selectedThemeIndex,
      ambientSound: _ambientSound,
      ambientVolume: _ambientVolume,
    );
    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.getTheme(_selectedThemeIndex);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        decoration: BoxDecoration(
          color: theme.bgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune_rounded, color: theme.focusColor, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Preferences & Timer',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: theme.textSecondary,
                    onPressed: () {
                      _triggerSave();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.white10),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Timer Durations
                    _SectionHeader(title: 'Timer Durations (Minutes)', theme: theme),
                    const SizedBox(height: 12),

                    _DurationSlider(
                      label: 'Focus Session',
                      value: _focusMinutes,
                      min: 10,
                      max: 60,
                      color: theme.focusColor,
                      theme: theme,
                      onChanged: (val) {
                        setState(() => _focusMinutes = val.round());
                        _triggerSave();
                      },
                    ),
                    _DurationSlider(
                      label: 'Short Break',
                      value: _shortBreakMinutes,
                      min: 1,
                      max: 15,
                      color: theme.shortBreakColor,
                      theme: theme,
                      onChanged: (val) {
                        setState(() => _shortBreakMinutes = val.round());
                        _triggerSave();
                      },
                    ),
                    _DurationSlider(
                      label: 'Long Break',
                      value: _longBreakMinutes,
                      min: 5,
                      max: 45,
                      color: theme.longBreakColor,
                      theme: theme,
                      onChanged: (val) {
                        setState(() => _longBreakMinutes = val.round());
                        _triggerSave();
                      },
                    ),
                    _DurationSlider(
                      label: 'Long Break Interval',
                      value: _longBreakInterval,
                      min: 2,
                      max: 8,
                      unit: 'sessions',
                      color: theme.accentColor,
                      theme: theme,
                      onChanged: (val) {
                        setState(() => _longBreakInterval = val.round());
                        _triggerSave();
                      },
                    ),

                    const SizedBox(height: 20),

                    // Section 2: Automation & Flow
                    _SectionHeader(title: 'Workflow Automation', theme: theme),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Auto-start Breaks',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Automatically start countdown when focus completes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: theme.textSecondary,
                        ),
                      ),
                      value: _autoStartBreaks,
                      activeColor: theme.focusColor,
                      onChanged: (val) {
                        setState(() => _autoStartBreaks = val);
                        _triggerSave();
                      },
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Auto-start Pomodoros',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Automatically start focus sprint when break completes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: theme.textSecondary,
                        ),
                      ),
                      value: _autoStartPomodoros,
                      activeColor: theme.focusColor,
                      onChanged: (val) {
                        setState(() => _autoStartPomodoros = val);
                        _triggerSave();
                      },
                    ),

                    const SizedBox(height: 20),

                    // Section 3: Sound & Ambiance
                    _SectionHeader(title: 'Audio & Ambiance', theme: theme),
                    const SizedBox(height: 8),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Sound Alerts & Chimes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Peaceful chimes upon session completion',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: theme.textSecondary,
                        ),
                      ),
                      value: _soundEnabled,
                      activeColor: theme.focusColor,
                      onChanged: (val) {
                        setState(() => _soundEnabled = val);
                        _triggerSave();
                      },
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'Background White Noise / Soundscape',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      children: [
                        _SoundChip(
                          label: 'Off',
                          icon: Icons.volume_mute_rounded,
                          isSelected: _ambientSound == 'off',
                          theme: theme,
                          onTap: () {
                            setState(() => _ambientSound = 'off');
                            _triggerSave();
                          },
                        ),
                        _SoundChip(
                          label: 'Rain',
                          icon: Icons.water_drop_rounded,
                          isSelected: _ambientSound == 'rain',
                          theme: theme,
                          onTap: () {
                            setState(() => _ambientSound = 'rain');
                            _triggerSave();
                          },
                        ),
                        _SoundChip(
                          label: 'Brown Noise',
                          icon: Icons.air_rounded,
                          isSelected: _ambientSound == 'white_noise',
                          theme: theme,
                          onTap: () {
                            setState(() => _ambientSound = 'white_noise');
                            _triggerSave();
                          },
                        ),
                        _SoundChip(
                          label: 'Clock Tick',
                          icon: Icons.access_time_rounded,
                          isSelected: _ambientSound == 'tick',
                          theme: theme,
                          onTap: () {
                            setState(() => _ambientSound = 'tick');
                            _triggerSave();
                          },
                        ),
                      ],
                    ),

                    if (_ambientSound != 'off') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.volume_down_rounded, size: 18, color: theme.textSecondary),
                          Expanded(
                            child: Slider(
                              value: _ambientVolume,
                              min: 0.1,
                              max: 1.0,
                              activeColor: theme.focusColor,
                              onChanged: (val) {
                                setState(() => _ambientVolume = val);
                                _triggerSave();
                              },
                            ),
                          ),
                          Icon(Icons.volume_up_rounded, size: 18, color: theme.textSecondary),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Section 4: Themes
                    _SectionHeader(title: 'App Theme Palette', theme: theme),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(AppThemes.themes.length, (index) {
                        final th = AppThemes.themes[index];
                        final isSelected = _selectedThemeIndex == index;
                        return InkWell(
                          onTap: () {
                            setState(() => _selectedThemeIndex = index);
                            _triggerSave();
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: th.bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? th.focusColor : th.cardBorder,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: th.focusColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: th.shortBreakColor,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: th.longBreakColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  th.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: th.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Dialog Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.cardBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _focusMinutes = 25;
                        _shortBreakMinutes = 5;
                        _longBreakMinutes = 15;
                        _longBreakInterval = 4;
                        _autoStartBreaks = false;
                        _autoStartPomodoros = false;
                        _ambientSound = 'off';
                      });
                      _triggerSave();
                    },
                    child: Text(
                      'Reset Defaults',
                      style: GoogleFonts.plusJakartaSans(
                        color: theme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.focusColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () {
                      _triggerSave();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Done',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: theme.brightness == Brightness.dark
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppThemeData theme;

  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: theme.focusColor,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _DurationSlider extends StatelessWidget {
  final String label;
  final int value;
  final double min;
  final double max;
  final String unit;
  final Color color;
  final AppThemeData theme;
  final ValueChanged<double> onChanged;

  const _DurationSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.unit = 'min',
    required this.color,
    required this.theme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
            Text(
              '$value $unit',
              style: AppFonts.mono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble().clamp(min, max),
          min: min,
          max: max,
          activeColor: color,
          inactiveColor: theme.bgCardLight,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SoundChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final AppThemeData theme;
  final VoidCallback onTap;

  const _SoundChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(icon, size: 14, color: isSelected ? theme.focusColor : theme.textSecondary),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.bgCardLight,
      selectedColor: theme.focusColor.withValues(alpha: 0.2),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? theme.focusColor : theme.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.focusColor : theme.cardBorder,
        ),
      ),
    );
  }
}
