import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pomodoro_settings.dart';
import '../models/task_item.dart';
import '../models/session_record.dart';

class StorageService {
  static const String _kSettingsKey = 'pomodoro_settings';
  static const String _kTasksKey = 'pomodoro_tasks';
  static const String _kHistoryKey = 'pomodoro_history';
  static const String _kActiveTaskKey = 'pomodoro_active_task_id';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Settings ---
  PomodoroSettings loadSettings() {
    final raw = _prefs.getString(_kSettingsKey);
    if (raw == null) return const PomodoroSettings();
    try {
      return PomodoroSettings.fromJson(raw);
    } catch (_) {
      return const PomodoroSettings();
    }
  }

  Future<void> saveSettings(PomodoroSettings settings) async {
    await _prefs.setString(_kSettingsKey, settings.toJson());
  }

  // --- Tasks ---
  List<TaskItem> loadTasks() {
    final raw = _prefs.getString(_kTasksKey);
    if (raw == null) {
      return [];
    }

    try {
      final List<dynamic> list = json.decode(raw);
      return list.map((e) => TaskItem.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final list = tasks.map((t) => t.toMap()).toList();
    await _prefs.setString(_kTasksKey, json.encode(list));
  }

  // --- Active Task ID ---
  String? loadActiveTaskId() {
    return _prefs.getString(_kActiveTaskKey);
  }

  Future<void> saveActiveTaskId(String? id) async {
    if (id == null) {
      await _prefs.remove(_kActiveTaskKey);
    } else {
      await _prefs.setString(_kActiveTaskKey, id);
    }
  }

  // --- Session History ---
  List<SessionRecord> loadHistory() {
    final raw = _prefs.getString(_kHistoryKey);
    if (raw == null) {
      return [];
    }

    try {
      final List<dynamic> list = json.decode(raw);
      return list.map((e) => SessionRecord.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(List<SessionRecord> history) async {
    final list = history.map((s) => s.toMap()).toList();
    await _prefs.setString(_kHistoryKey, json.encode(list));
  }

  // --- Analytics Helpers ---
  int getTodayFocusMinutes(List<SessionRecord> history) {
    final now = DateTime.now();
    return history
        .where((s) =>
            s.mode == 'focus' &&
            s.timestamp.year == now.year &&
            s.timestamp.month == now.month &&
            s.timestamp.day == now.day)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int getTodayCompletedSessions(List<SessionRecord> history) {
    final now = DateTime.now();
    return history
        .where((s) =>
            s.mode == 'focus' &&
            s.timestamp.year == now.year &&
            s.timestamp.month == now.month &&
            s.timestamp.day == now.day)
        .length;
  }

  int calculateStreak(List<SessionRecord> history) {
    final focusDays = history
        .where((s) => s.mode == 'focus')
        .map((s) => DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day))
        .toSet()
        .toList();

    focusDays.sort((a, b) => b.compareTo(a));

    if (focusDays.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // If no session today or yesterday, streak is broken
    if (!focusDays.contains(today) && !focusDays.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDay = focusDays.contains(today) ? today : yesterday;

    while (focusDays.contains(checkDay)) {
      streak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  List<DailyFocusStat> getPast7DaysStats(List<SessionRecord> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<DailyFocusStat> stats = [];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final daySessions = history.where((s) =>
          s.mode == 'focus' &&
          s.timestamp.year == date.year &&
          s.timestamp.month == date.month &&
          s.timestamp.day == date.day);
      final minutes = daySessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
      stats.add(DailyFocusStat(date: date, minutes: minutes));
    }

    return stats;
  }
}

class DailyFocusStat {
  final DateTime date;
  final int minutes;

  DailyFocusStat({required this.date, required this.minutes});
}
