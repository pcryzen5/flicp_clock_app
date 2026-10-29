import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class FlipClockWidget extends StatefulWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final String mode;
  final bool isRunning;
  final int currentCycleSession;
  final int maxCycleSessions;
  final String? activeTaskTitle;
  final AppThemeData themeData;

  const FlipClockWidget({
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
  State<FlipClockWidget> createState() => _FlipClockWidgetState();
}

class _FlipClockWidgetState extends State<FlipClockWidget> {
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _getModeLabel() {
    switch (widget.mode) {
      case 'shortBreak':
        return 'SHORT BREAK';
      case 'longBreak':
        return 'LONG BREAK';
      case 'focus':
      default:
        return 'FOCUS';
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.remainingSeconds ~/ 60;
    final seconds = widget.remainingSeconds % 60;
    final minutesStr = _twoDigits(minutes);
    final secondsStr = _twoDigits(seconds);

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy/M/d').format(now);
    final dayStr = DateFormat('EEEE').format(now);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final cardWidth =
            (maxWidth > 420 ? 162.0 : (maxWidth - 44) / 2).clamp(120.0, 170.0);
        final cardHeight = cardWidth * 1.18;
        final fontSize = cardWidth * 0.72;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FlipPlate(
                  value: minutesStr,
                  fontSize: fontSize,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                  themeData: widget.themeData,
                  topLeftLabel: dateStr,
                  topRightLabel: _getModeLabel(),
                ),
                const SizedBox(width: 14),
                _FlipPlate(
                  value: secondsStr,
                  fontSize: fontSize,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                  themeData: widget.themeData,
                  topLeftLabel: dayStr,
                  topRightLabel:
                      'R${widget.currentCycleSession}/${widget.maxCycleSessions}',
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.maxCycleSessions, (index) {
                final isFilled = index < widget.currentCycleSession;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? widget.themeData.flipDigitColor
                        : widget.themeData.flipCardBg.withValues(alpha: 0.5),
                    border: Border.all(
                      color: isFilled
                          ? widget.themeData.flipDigitColor
                          : widget.themeData.cardBorder,
                      width: 1.2,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: widget.themeData.flipDigitColor
                                  .withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),
            if (widget.activeTaskTitle != null &&
                widget.activeTaskTitle!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: widget.themeData.flipCardBg.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: widget.themeData.cardBorder),
                ),
                child: Text(
                  'LOGO ${widget.activeTaskTitle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.themeData.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _FlipPlate extends StatefulWidget {
  final String value;
  final double fontSize;
  final double cardWidth;
  final double cardHeight;
  final AppThemeData themeData;
  final String topLeftLabel;
  final String topRightLabel;

  const _FlipPlate({
    required this.value,
    required this.fontSize,
    required this.cardWidth,
    required this.cardHeight,
    required this.themeData,
    required this.topLeftLabel,
    required this.topRightLabel,
  });

  @override
  State<_FlipPlate> createState() => _FlipPlateState();
}

class _FlipPlateState extends State<_FlipPlate>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  String _current = '';
  String _previous = '';

  @override
  void initState() {
    super.initState();
    _current = widget.value;
    _previous = widget.value;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant _FlipPlate old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      _previous = old.value;
      _current = widget.value;
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.cardWidth;
    final h = widget.cardHeight;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: widget.themeData.flipCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.themeData.cardBorder.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _HalfDigit(
                    value: _current,
                    isTop: true,
                    cardWidth: w,
                    cardHeight: h,
                    fontSize: widget.fontSize,
                    themeData: widget.themeData,
                  ),
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) => _HalfDigit(
                      value: _anim.value < 0.5 ? _previous : _current,
                      isTop: false,
                      cardWidth: w,
                      cardHeight: h,
                      fontSize: widget.fontSize,
                      themeData: widget.themeData,
                    ),
                  ),
                ),
              ],
            ),
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) {
                final t = _anim.value;
                if (t <= 0.0 || t >= 1.0) return const SizedBox.shrink();

                if (t <= 0.5) {
                  final angle = t * math.pi;
                  final dim = (t / 0.5).clamp(0.0, 1.0);
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: w,
                      height: h / 2,
                      child: Transform(
                        alignment: Alignment.bottomCenter,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002)
                          ..rotateX(angle),
                        child: _HalfDigit(
                          value: _previous,
                          isTop: true,
                          cardWidth: w,
                          cardHeight: h,
                          fontSize: widget.fontSize,
                          themeData: widget.themeData,
                          dimFactor: dim,
                        ),
                      ),
                    ),
                  );
                } else {
                  final angle = (1.0 - t) * math.pi;
                  final dim = ((1.0 - t) / 0.5).clamp(0.0, 1.0);
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: w,
                      height: h / 2,
                      child: Transform(
                        alignment: Alignment.topCenter,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002)
                          ..rotateX(-angle),
                        child: _HalfDigit(
                          value: _current,
                          isTop: false,
                          cardWidth: w,
                          cardHeight: h,
                          fontSize: widget.fontSize,
                          themeData: widget.themeData,
                          dimFactor: dim,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            Center(
              child: Row(
                children: [
                  Container(
                    width: 5,
                    height: 9,
                    decoration: BoxDecoration(
                      color: widget.themeData.flipCardSeam,
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(3)),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            height: 1.5, color: widget.themeData.flipCardSeam),
                        Container(
                            height: 1.0,
                            color: Colors.white.withValues(alpha: 0.07)),
                      ],
                    ),
                  ),
                  Container(
                    width: 5,
                    height: 9,
                    decoration: BoxDecoration(
                      color: widget.themeData.flipCardSeam,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(3)),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.topLeftLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.mono(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w700,
                        color: widget.themeData.flipDigitColor
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      widget.topRightLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: widget.themeData.flipDigitColor
                            .withValues(alpha: 0.85),
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

class _HalfDigit extends StatelessWidget {
  final String value;
  final bool isTop;
  final double cardWidth;
  final double cardHeight;
  final double fontSize;
  final AppThemeData themeData;
  final double dimFactor;

  const _HalfDigit({
    required this.value,
    required this.isTop,
    required this.cardWidth,
    required this.cardHeight,
    required this.fontSize,
    required this.themeData,
    this.dimFactor = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // The parent Expanded gives us exactly cardHeight/2.
    // OverflowBox lets the inner Stack render at full cardHeight,
    // and ClipRect (from Expanded's tight constraints) clips to the half.
    // Aligning topCenter/bottomCenter ensures we see the right half of the digit.
    Widget half = ClipRect(
      child: OverflowBox(
        maxHeight: cardHeight,
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isTop
                          ? [
                              themeData.flipCardBg,
                              themeData.flipCardBg.withValues(alpha: 0.88),
                            ]
                          : [
                              themeData.flipCardBg.withValues(alpha: 0.82),
                              themeData.flipCardBg,
                            ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  value,
                  style: AppFonts.flipNumber(
                    fontSize: fontSize,
                    color: themeData.flipDigitColor,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (dimFactor > 0.0) {
      half = Stack(
        children: [
          half,
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: dimFactor * 0.45),
            ),
          ),
        ],
      );
    }

    return half;
  }
}

