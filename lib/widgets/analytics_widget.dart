import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/session_record.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class AnalyticsWidget extends StatelessWidget {
  final List<SessionRecord> history;
  final StorageService storageService;
  final AppThemeData themeData;
  final VoidCallback onClearHistory;

  const AnalyticsWidget({
    super.key,
    required this.history,
    required this.storageService,
    required this.themeData,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final todayMinutes = storageService.getTodayFocusMinutes(history);
    final todaySessions = storageService.getTodayCompletedSessions(history);
    final streak = storageService.calculateStreak(history);
    final totalFocusMinutes = history
        .where((s) => s.mode == 'focus')
        .fold(0, (sum, s) => sum + s.durationMinutes);
    final totalHours = (totalFocusMinutes / 60).toStringAsFixed(1);

    final past7Days = storageService.getPast7DaysStats(history);
    final maxMinutes = past7Days.fold<int>(
      60,
      (max, item) => item.minutes > max ? item.minutes : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Productivity Analytics',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: themeData.textPrimary,
              ),
            ),
            if (history.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                color: themeData.textSecondary,
                tooltip: 'Clear History',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: themeData.bgCard,
                      title: Text(
                        'Clear History?',
                        style: TextStyle(color: themeData.textPrimary),
                      ),
                      content: Text(
                        'This will reset your session history and stats.',
                        style: TextStyle(color: themeData.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onClearHistory();
                          },
                          child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),

        const SizedBox(height: 16),

        // 4 KPI Summary Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _KpiCard(
                  title: 'Today Focus',
                  value: todayMinutes >= 60
                      ? '${(todayMinutes / 60).toStringAsFixed(1)}h'
                      : '${todayMinutes}m',
                  subtext: '$todayMinutes minutes today',
                  icon: Icons.timer_outlined,
                  color: themeData.focusColor,
                  width: cardWidth,
                  themeData: themeData,
                ),
                _KpiCard(
                  title: 'Sessions Today',
                  value: '$todaySessions',
                  subtext: 'Completed pomodoros',
                  icon: Icons.check_circle_outline_rounded,
                  color: themeData.shortBreakColor,
                  width: cardWidth,
                  themeData: themeData,
                ),
                _KpiCard(
                  title: 'Focus Streak',
                  value: '$streak ${streak == 1 ? 'day' : 'days'}',
                  subtext: streak > 0 ? 'Consistency on point 🔥' : 'Start today!',
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFFF9100),
                  width: cardWidth,
                  themeData: themeData,
                ),
                _KpiCard(
                  title: 'Total Hours',
                  value: '${totalHours}h',
                  subtext: '${history.where((s) => s.mode == 'focus').length} total sessions',
                  icon: Icons.insights_rounded,
                  color: themeData.accentColor,
                  width: cardWidth,
                  themeData: themeData,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),

        // Weekly Activity Chart Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: themeData.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: themeData.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last 7 Days Focus',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: themeData.textPrimary,
                    ),
                  ),
                  Text(
                    'Max: ${maxMinutes}m / day',
                    style: AppFonts.mono(
                      fontSize: 11,
                      color: themeData.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bar Chart
              SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: past7Days.map((stat) {
                    final heightFactor = maxMinutes > 0 ? (stat.minutes / maxMinutes).clamp(0.04, 1.0) : 0.04;
                    final dayName = DateFormat('E').format(stat.date);
                    final isToday = stat.date.day == DateTime.now().day &&
                        stat.date.month == DateTime.now().month;

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (stat.minutes > 0)
                            Text(
                              '${stat.minutes}m',
                              style: AppFonts.mono(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: isToday ? themeData.focusColor : themeData.textSecondary,
                              ),
                            )
                          else
                            const SizedBox(height: 12),
                          const SizedBox(height: 4),

                          // Vertical Bar
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: heightFactor,
                                child: Container(
                                  width: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: LinearGradient(
                                      colors: isToday
                                          ? [
                                              themeData.focusColor,
                                              themeData.focusColor.withValues(alpha: 0.7),
                                            ]
                                          : [
                                              themeData.focusColor.withValues(alpha: 0.5),
                                              themeData.focusColor.withValues(alpha: 0.25),
                                            ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    boxShadow: isToday && stat.minutes > 0
                                        ? [
                                            BoxShadow(
                                              color: themeData.focusColor.withValues(alpha: 0.4),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Day Label
                          Text(
                            dayName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                              color: isToday ? themeData.focusColor : themeData.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Recent Sessions Timeline
        Text(
          'Recent Sessions',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: themeData.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        if (history.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeData.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: themeData.cardBorder),
            ),
            child: Center(
              child: Text(
                'Complete a focus session to see your activity timeline here!',
                style: GoogleFonts.plusJakartaSans(
                  color: themeData.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.take(6).length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = history.reversed.toList()[index];
              final modeColor = themeData.getModeColor(item.mode);
              final dateStr = DateFormat('MMM d, h:mm a').format(item.timestamp);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: themeData.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: themeData.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: modeColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.mode == 'focus'
                            ? Icons.local_fire_department_rounded
                            : Icons.coffee_rounded,
                        size: 16,
                        color: modeColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.taskTitle != null && item.taskTitle!.isNotEmpty
                                ? item.taskTitle!
                                : (item.mode == 'focus' ? 'Focus Session' : 'Break Time'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: themeData.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateStr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: themeData.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${item.durationMinutes}m',
                      style: AppFonts.mono(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: modeColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;
  final double width;
  final AppThemeData themeData;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
    required this.width,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeData.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: themeData.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: themeData.textSecondary,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppFonts.mono(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: themeData.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtext,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: themeData.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
