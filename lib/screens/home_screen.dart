import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pomodoro_settings.dart';
import '../models/task_item.dart';
import '../models/session_record.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/flip_clock_widget.dart';
import '../widgets/scenic_background.dart';
import '../widgets/timer_controls.dart';
import '../widgets/mode_selector.dart';
import '../widgets/task_list_widget.dart';
import '../widgets/analytics_widget.dart';
import '../widgets/settings_dialog.dart';
import 'screensaver_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;

  const HomeScreen({super.key, required this.storageService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PomodoroSettings _settings;
  late List<TaskItem> _tasks;
  late List<SessionRecord> _history;
  String? _activeTaskId;

  // Timer State
  Timer? _timer;
  String _mode = 'focus'; // 'focus', 'shortBreak', 'longBreak'
  int _remainingSeconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  int _currentCycleSession = 1;
  bool _isRunning = false;

  // Mobile Navigation
  int _mobileTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _settings = widget.storageService.loadSettings();
    _tasks = widget.storageService.loadTasks();
    _history = widget.storageService.loadHistory();
    _activeTaskId = widget.storageService.loadActiveTaskId();

    _applyMode(_mode, autoStart: false);

    // If ambient sound was saved as active, start it
    if (_settings.ambientSound != 'off') {
      SoundService.instance.playAmbient(_settings.ambientSound, _settings.ambientVolume);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    SoundService.instance.stopAmbient();
    super.dispose();
  }

  AppThemeData get _currentTheme => AppThemes.getTheme(_settings.selectedThemeIndex);

  TaskItem? get _activeTask {
    if (_activeTaskId == null) return null;
    try {
      return _tasks.firstWhere((t) => t.id == _activeTaskId);
    } catch (_) {
      return null;
    }
  }

  int _getDurationSecondsForMode(String mode) {
    switch (mode) {
      case 'shortBreak':
        return _settings.shortBreakMinutes * 60;
      case 'longBreak':
        return _settings.longBreakMinutes * 60;
      case 'focus':
      default:
        return _settings.focusMinutes * 60;
    }
  }

  void _applyMode(String mode, {bool autoStart = false}) {
    _timer?.cancel();
    final duration = _getDurationSecondsForMode(mode);
    setState(() {
      _mode = mode;
      _totalSeconds = duration;
      _remainingSeconds = duration;
      _isRunning = autoStart;
    });

    if (autoStart) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_settings.soundEnabled) {
      SoundService.instance.playSound('start');
    }
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _onSessionComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    if (_settings.soundEnabled) {
      SoundService.instance.playSound('click');
    }
    setState(() => _isRunning = false);
  }

  void _togglePlay() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    if (_settings.soundEnabled) {
      SoundService.instance.playSound('click');
    }
    final duration = _getDurationSecondsForMode(_mode);
    setState(() {
      _isRunning = false;
      _remainingSeconds = duration;
      _totalSeconds = duration;
    });
  }

  void _add5Minutes() {
    if (_settings.soundEnabled) {
      SoundService.instance.playSound('click');
    }
    setState(() {
      _remainingSeconds += 300;
      _totalSeconds += 300;
    });
  }

  void _skipSession() {
    _timer?.cancel();
    if (_settings.soundEnabled) {
      SoundService.instance.playSound('click');
    }
    _advanceToNextMode(recordCompleted: false);
  }

  void _onSessionComplete() {
    setState(() {
      _remainingSeconds = 0;
      _isRunning = false;
    });

    // Play celebration chime
    if (_settings.soundEnabled) {
      SoundService.instance.playSound('finish');
    }

    // Record session
    final durationMinutes = _totalSeconds ~/ 60;
    final record = SessionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      durationMinutes: durationMinutes,
      mode: _mode,
      taskTitle: _activeTask?.title,
    );

    final updatedHistory = List<SessionRecord>.from(_history)..add(record);
    _history = updatedHistory;
    widget.storageService.saveHistory(updatedHistory);

    // If focus session, increment task completed pomodoros
    if (_mode == 'focus' && _activeTask != null) {
      final task = _activeTask!;
      final newCompleted = task.completedPomodoros + 1;
      final updatedTask = task.copyWith(
        completedPomodoros: newCompleted,
        isCompleted: newCompleted >= task.estimatedPomodoros ? true : task.isCompleted,
      );
      _handleUpdateTask(updatedTask);
    }

    _showCompletionSnackBar(_mode);
    _advanceToNextMode(recordCompleted: true);
  }

  void _advanceToNextMode({required bool recordCompleted}) {
    if (_mode == 'focus') {
      if (_currentCycleSession >= _settings.longBreakInterval) {
        _currentCycleSession = 1;
        _applyMode('longBreak', autoStart: _settings.autoStartBreaks);
      } else {
        _currentCycleSession++;
        _applyMode('shortBreak', autoStart: _settings.autoStartBreaks);
      }
    } else {
      _applyMode('focus', autoStart: _settings.autoStartPomodoros);
    }
  }

  void _showCompletionSnackBar(String completedMode) {
    String msg;
    Color color;

    if (completedMode == 'focus') {
      msg = '🎉 Focus session finished! Time to relax.';
      color = _currentTheme.shortBreakColor;
    } else {
      msg = '⚡ Break over! Ready to dive back into deep focus?';
      color = _currentTheme.focusColor;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- Task Handlers ---
  void _handleToggleCompleteTask(TaskItem task) {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    _handleUpdateTask(updated);
  }

  void _handleSelectActiveTask(String taskId) {
    setState(() {
      _activeTaskId = _activeTaskId == taskId ? null : taskId;
    });
    widget.storageService.saveActiveTaskId(_activeTaskId);
  }

  void _handleAddTask(TaskItem newTask) {
    setState(() {
      _tasks.insert(0, newTask);
      if (_activeTaskId == null) {
        _activeTaskId = newTask.id;
        widget.storageService.saveActiveTaskId(newTask.id);
      }
    });
    widget.storageService.saveTasks(_tasks);
  }

  void _handleUpdateTask(TaskItem updatedTask) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });
    widget.storageService.saveTasks(_tasks);
  }

  void _handleDeleteTask(String taskId) {
    setState(() {
      _tasks.removeWhere((t) => t.id == taskId);
      if (_activeTaskId == taskId) {
        _activeTaskId = null;
        widget.storageService.saveActiveTaskId(null);
      }
    });
    widget.storageService.saveTasks(_tasks);
  }

  void _handleClearHistory() {
    setState(() {
      _history.clear();
    });
    widget.storageService.saveHistory([]);
  }

  // --- Settings & Ambiance ---
  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        initialSettings: _settings,
        currentTheme: _currentTheme,
        onSave: (updated) {
          setState(() {
            final oldSound = _settings.ambientSound;
            final oldVol = _settings.ambientVolume;
            _settings = updated;
            widget.storageService.saveSettings(updated);

            // If ambient sound changed
            if (updated.ambientSound != oldSound || updated.ambientVolume != oldVol) {
              if (updated.ambientSound == 'off') {
                SoundService.instance.stopAmbient();
              } else {
                SoundService.instance.playAmbient(updated.ambientSound, updated.ambientVolume);
              }
            }

            // If timer wasn't running and current duration changed, reset remaining
            if (!_isRunning) {
              final newDuration = _getDurationSecondsForMode(_mode);
              _totalSeconds = newDuration;
              _remainingSeconds = newDuration;
            }
          });
        },
      ),
    );
  }

  void _toggleThemeDirectly() {
    final nextIndex = (_settings.selectedThemeIndex + 1) % AppThemes.themes.length;
    final updated = _settings.copyWith(selectedThemeIndex: nextIndex);
    setState(() {
      _settings = updated;
    });
    widget.storageService.saveSettings(updated);
  }

  void _openScreensaver() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondaryAnim) => ScreensaverScreen(
          themeData: _currentTheme,
        ),
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _currentTheme;
    final streak = widget.storageService.calculateStreak(_history);

    return Theme(
      data: theme.toThemeData(),
      child: Scaffold(
        backgroundColor: theme.bgPrimary,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(theme, streak),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: theme.bgGradient),
          child: ScenicBackgroundWidget(
            scenicType: theme.scenicType,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 880;

                  if (isWide) {
                    return _buildDesktopLayout(theme);
                  } else {
                    return _buildMobileLayout(theme);
                  }
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: MediaQuery.of(context).size.width < 880
            ? _buildBottomNavigationBar(theme)
            : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppThemeData theme, int streak) {
    return AppBar(
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.focusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.focusColor.withValues(alpha: 0.25)),
            ),
            child: Image.asset(
              'assets/images/app_logo_transparent.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Text('🍅', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PomoFocus Pro',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: theme.textPrimary,
                ),
              ),
              Text(
                'Deep Flow & Timeboxing',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Streak indicator badge
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9100).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF9100).withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '$streak ${streak == 1 ? 'day' : 'days'}',
                style: AppFonts.mono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF9100),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Quick theme palette cycle button
        IconButton(
          tooltip: 'Switch Theme (${theme.name})',
          icon: Icon(Icons.palette_outlined, color: theme.textPrimary, size: 21),
          onPressed: _toggleThemeDirectly,
        ),

        // Flip Clock Screensaver button
        IconButton(
          tooltip: 'Flip Clock Screensaver',
          icon: Icon(Icons.fullscreen_rounded, color: theme.textPrimary, size: 24),
          onPressed: _openScreensaver,
        ),

        // Preferences button
        IconButton(
          tooltip: 'Timer Preferences',
          icon: Icon(Icons.settings_outlined, color: theme.textPrimary, size: 21),
          onPressed: _openSettingsDialog,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // --- Wide Desktop / Web Layout ---
  Widget _buildDesktopLayout(AppThemeData theme) {
    return Row(
      children: [
        // Left Column: Timer & Controls
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mode Selector
                    ModeSelectorWidget(
                      currentMode: _mode,
                      focusMinutes: _settings.focusMinutes,
                      shortBreakMinutes: _settings.shortBreakMinutes,
                      longBreakMinutes: _settings.longBreakMinutes,
                      themeData: theme,
                      onModeChanged: (newMode) => _applyMode(newMode),
                    ),

                    const SizedBox(height: 32),

                    // Flip Clock Mechanical Display
                    FlipClockWidget(
                      totalSeconds: _totalSeconds,
                      remainingSeconds: _remainingSeconds,
                      mode: _mode,
                      isRunning: _isRunning,
                      currentCycleSession: _currentCycleSession,
                      maxCycleSessions: _settings.longBreakInterval,
                      activeTaskTitle: _activeTask?.title,
                      themeData: theme,
                    ),

                    const SizedBox(height: 28),

                    // Controls
                    TimerControlsWidget(
                      isRunning: _isRunning,
                      mode: _mode,
                      themeData: theme,
                      onTogglePlay: _togglePlay,
                      onReset: _resetTimer,
                      onSkip: _skipSession,
                      onAdd5Minutes: _add5Minutes,
                      soundEnabled: _settings.soundEnabled,
                      onToggleSound: () {
                        final updated = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
                        setState(() => _settings = updated);
                        widget.storageService.saveSettings(updated);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Active Focus Task Card
                    _buildActiveTaskHero(theme),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Divider
        VerticalDivider(width: 1, color: theme.cardBorder),

        // Right Column: Tasks & Analytics
        Expanded(
          flex: 6,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  color: theme.bgCard,
                  child: TabBar(
                    indicatorColor: theme.focusColor,
                    labelColor: theme.focusColor,
                    unselectedLabelColor: theme.textSecondary,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    tabs: const [
                      Tab(icon: Icon(Icons.checklist_rounded), text: 'Tasks & Sprints'),
                      Tab(icon: Icon(Icons.analytics_rounded), text: 'Analytics & Heatmap'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: TaskListWidget(
                          tasks: _tasks,
                          activeTaskId: _activeTaskId,
                          themeData: theme,
                          onToggleComplete: _handleToggleCompleteTask,
                          onSelectActiveTask: _handleSelectActiveTask,
                          onAddTask: _handleAddTask,
                          onUpdateTask: _handleUpdateTask,
                          onDeleteTask: _handleDeleteTask,
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: AnalyticsWidget(
                          history: _history,
                          storageService: widget.storageService,
                          themeData: theme,
                          onClearHistory: _handleClearHistory,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Compact / Mobile Layout ---
  Widget _buildMobileLayout(AppThemeData theme) {
    if (_mobileTabIndex == 0) {
      // Timer Tab
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            ModeSelectorWidget(
              currentMode: _mode,
              focusMinutes: _settings.focusMinutes,
              shortBreakMinutes: _settings.shortBreakMinutes,
              longBreakMinutes: _settings.longBreakMinutes,
              themeData: theme,
              onModeChanged: (newMode) => _applyMode(newMode),
            ),
            const SizedBox(height: 28),
            // Flip Clock Mechanical Display
            FlipClockWidget(
              totalSeconds: _totalSeconds,
              remainingSeconds: _remainingSeconds,
              mode: _mode,
              isRunning: _isRunning,
              currentCycleSession: _currentCycleSession,
              maxCycleSessions: _settings.longBreakInterval,
              activeTaskTitle: _activeTask?.title,
              themeData: theme,
            ),
            const SizedBox(height: 24),
            TimerControlsWidget(
              isRunning: _isRunning,
              mode: _mode,
              themeData: theme,
              onTogglePlay: _togglePlay,
              onReset: _resetTimer,
              onSkip: _skipSession,
              onAdd5Minutes: _add5Minutes,
              soundEnabled: _settings.soundEnabled,
              onToggleSound: () {
                final updated = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
                setState(() => _settings = updated);
                widget.storageService.saveSettings(updated);
              },
            ),
            const SizedBox(height: 24),
            _buildActiveTaskHero(theme),
          ],
        ),
      );
    } else if (_mobileTabIndex == 1) {
      // Tasks Tab
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: TaskListWidget(
          tasks: _tasks,
          activeTaskId: _activeTaskId,
          themeData: theme,
          onToggleComplete: _handleToggleCompleteTask,
          onSelectActiveTask: _handleSelectActiveTask,
          onAddTask: _handleAddTask,
          onUpdateTask: _handleUpdateTask,
          onDeleteTask: _handleDeleteTask,
        ),
      );
    } else {
      // Analytics Tab
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AnalyticsWidget(
          history: _history,
          storageService: widget.storageService,
          themeData: theme,
          onClearHistory: _handleClearHistory,
        ),
      );
    }
  }

  Widget _buildBottomNavigationBar(AppThemeData theme) {
    return NavigationBar(
      selectedIndex: _mobileTabIndex,
      onDestinationSelected: (index) => setState(() => _mobileTabIndex = index),
      backgroundColor: theme.bgCard,
      indicatorColor: theme.focusColor.withValues(alpha: 0.2),
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.timer_outlined, color: theme.textSecondary),
          selectedIcon: Icon(Icons.timer_rounded, color: theme.focusColor),
          label: 'Timer',
        ),
        NavigationDestination(
          icon: Icon(Icons.checklist_rounded, color: theme.textSecondary),
          selectedIcon: Icon(Icons.checklist_rounded, color: theme.focusColor),
          label: 'Tasks',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_rounded, color: theme.textSecondary),
          selectedIcon: Icon(Icons.bar_chart_rounded, color: theme.focusColor),
          label: 'Analytics',
        ),
      ],
    );
  }

  void _openAddTaskModal() {
    TaskDialogHelper.showAddOrEditTaskDialog(
      context,
      themeData: _currentTheme,
      onSave: _handleAddTask,
    );
  }

  // Active Task Hero Widget
  Widget _buildActiveTaskHero(AppThemeData theme) {
    final active = _activeTask;

    if (active == null) {
      final hasTasks = _tasks.isNotEmpty;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.focusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasTasks ? Icons.track_changes_rounded : Icons.add_task_rounded,
                size: 20,
                color: theme.focusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasTasks ? 'No active task selected' : 'Ready to start focusing?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasTasks
                        ? 'Select a task from your list or add a new one.'
                        : 'Create your first task to track your Pomodoro sprints.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.focusColor,
                foregroundColor: theme.brightness == Brightness.dark ? Colors.black87 : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _openAddTaskModal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Add Task',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.focusColor.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: theme.focusColor.withValues(alpha: 0.08),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox to complete active task directly from timer
          GestureDetector(
            onTap: () => _handleToggleCompleteTask(active),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active.isCompleted ? theme.focusColor : Colors.transparent,
                border: Border.all(
                  color: active.isCompleted ? theme.focusColor : theme.cardBorder,
                  width: 1.8,
                ),
              ),
              child: active.isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ACTIVE OBJECTIVE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: theme.focusColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '🍅 ${active.completedPomodoros} / ${active.estimatedPomodoros}',
                      style: AppFonts.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  active.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.textPrimary,
                    decoration: active.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Clear Active Task',
            icon: Icon(Icons.close_rounded, size: 18, color: theme.textSecondary),
            onPressed: () {
              setState(() => _activeTaskId = null);
              widget.storageService.saveActiveTaskId(null);
            },
          ),
        ],
      ),
    );
  }
}
