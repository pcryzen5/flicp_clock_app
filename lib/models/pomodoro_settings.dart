import 'dart:convert';

class PomodoroSettings {
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int longBreakInterval;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;
  final bool soundEnabled;
  final int selectedThemeIndex;
  final String ambientSound; // 'off', 'white_noise', 'rain', 'tick'
  final double ambientVolume;

  const PomodoroSettings({
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.longBreakInterval = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
    this.soundEnabled = true,
    this.selectedThemeIndex = 0,
    this.ambientSound = 'off',
    this.ambientVolume = 0.5,
  });

  PomodoroSettings copyWith({
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakInterval,
    bool? autoStartBreaks,
    bool? autoStartPomodoros,
    bool? soundEnabled,
    int? selectedThemeIndex,
    String? ambientSound,
    double? ambientVolume,
  }) {
    return PomodoroSettings(
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartPomodoros: autoStartPomodoros ?? this.autoStartPomodoros,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      selectedThemeIndex: selectedThemeIndex ?? this.selectedThemeIndex,
      ambientSound: ambientSound ?? this.ambientSound,
      ambientVolume: ambientVolume ?? this.ambientVolume,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'focusMinutes': focusMinutes,
      'shortBreakMinutes': shortBreakMinutes,
      'longBreakMinutes': longBreakMinutes,
      'longBreakInterval': longBreakInterval,
      'autoStartBreaks': autoStartBreaks,
      'autoStartPomodoros': autoStartPomodoros,
      'soundEnabled': soundEnabled,
      'selectedThemeIndex': selectedThemeIndex,
      'ambientSound': ambientSound,
      'ambientVolume': ambientVolume,
    };
  }

  factory PomodoroSettings.fromMap(Map<String, dynamic> map) {
    return PomodoroSettings(
      focusMinutes: map['focusMinutes'] as int? ?? 25,
      shortBreakMinutes: map['shortBreakMinutes'] as int? ?? 5,
      longBreakMinutes: map['longBreakMinutes'] as int? ?? 15,
      longBreakInterval: map['longBreakInterval'] as int? ?? 4,
      autoStartBreaks: map['autoStartBreaks'] as bool? ?? false,
      autoStartPomodoros: map['autoStartPomodoros'] as bool? ?? false,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      selectedThemeIndex: map['selectedThemeIndex'] as int? ?? 0,
      ambientSound: map['ambientSound'] as String? ?? 'off',
      ambientVolume: (map['ambientVolume'] as num?)?.toDouble() ?? 0.5,
    );
  }

  String toJson() => json.encode(toMap());

  factory PomodoroSettings.fromJson(String source) =>
      PomodoroSettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
