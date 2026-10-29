import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TimerCircleWidget extends StatefulWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final String mode; // 'focus', 'shortBreak', 'longBreak'
  final bool isRunning;
  final int currentCycleSession; // 1 to longBreakInterval
  final int maxCycleSessions;
  final String? activeTaskTitle;
  final AppThemeData themeData;

  const TimerCircleWidget({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.mode,
    required this.isRunning,
    required this.currentCycleSession,
    required this.maxCycleSessions,
    this.activeTaskTitle,
    required this.themeData,
  });

  @override
  State<TimerCircleWidget> createState() => _TimerCircleWidgetState();
}

class _TimerCircleWidgetState extends State<TimerCircleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isRunning) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant TimerCircleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 500));
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSecs) {
    final minutes = totalSecs ~/ 60;
    final seconds = totalSecs % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getModeLabel() {
    switch (widget.mode) {
      case 'shortBreak':
        return 'SHORT BREAK';
      case 'longBreak':
        return 'LONG BREAK';
      case 'focus':
      default:
        return 'FOCUS TIME';
    }
  }

  IconData _getModeIcon() {
    switch (widget.mode) {
      case 'shortBreak':
        return Icons.coffee_rounded;
      case 'longBreak':
        return Icons.nature_people_rounded;
      case 'focus':
      default:
        return Icons.local_fire_department_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeColor = widget.themeData.getModeColor(widget.mode);
    final progress = widget.totalSeconds > 0
        ? (widget.totalSeconds - widget.remainingSeconds) / widget.totalSeconds
        : 0.0;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isRunning ? _pulseAnimation.value : 1.0,
          child: SizedBox(
            width: 290,
            height: 290,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ambient Glow
                Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: modeColor.withValues(alpha: widget.isRunning ? 0.35 : 0.15),
                        blurRadius: widget.isRunning ? 36 : 20,
                        spreadRadius: widget.isRunning ? 4 : 0,
                      ),
                    ],
                  ),
                ),

                // Background Circular Card
                Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.themeData.bgCard,
                    border: Border.all(
                      color: widget.themeData.cardBorder,
                      width: 1.5,
                    ),
                  ),
                ),

                // Custom Arc Progress
                SizedBox(
                  width: 260,
                  height: 260,
                  child: CustomPaint(
                    painter: _TimerRingPainter(
                      progress: progress,
                      activeColor: modeColor,
                      trackColor: widget.themeData.bgCardLight.withValues(alpha: 0.7),
                      strokeWidth: 10.0,
                    ),
                  ),
                ),

                // Inner content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mode Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: modeColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: modeColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getModeIcon(), size: 14, color: modeColor),
                            const SizedBox(width: 6),
                            Text(
                              _getModeLabel(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: modeColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Digital Countdown Numbers
                      Text(
                        _formatTime(widget.remainingSeconds),
                        style: AppFonts.mono(
                          fontSize: 54,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          color: widget.themeData.textPrimary,
                          shadows: [
                            Shadow(
                              color: modeColor.withValues(alpha: 0.3),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Cycle Round Indicator (e.g., Round 2 of 4)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.maxCycleSessions,
                          (index) {
                            final isFilled = index < widget.currentCycleSession;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFilled
                                    ? modeColor
                                    : widget.themeData.cardBorder,
                                boxShadow: isFilled
                                    ? [
                                        BoxShadow(
                                          color: modeColor.withValues(alpha: 0.6),
                                          blurRadius: 6,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Active Task hint if any
                      if (widget.activeTaskTitle != null && widget.activeTaskTitle!.isNotEmpty)
                        Text(
                          widget.activeTaskTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: widget.themeData.textSecondary,
                          ),
                        )
                      else
                        Text(
                          'Round ${widget.currentCycleSession} of ${widget.maxCycleSessions}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: widget.themeData.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  _TimerRingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background full track ring
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Active animated arc
    if (progress > 0) {
      final activePaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [
            activeColor.withValues(alpha: 0.6),
            activeColor,
          ],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
