import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

/// Full-screen flip-clock screensaver.
/// Shows real-time  HH : MM : SS  with animated flip mechanics.
/// Tap anywhere or press Escape / Back to dismiss.
class ScreensaverScreen extends StatefulWidget {
  final AppThemeData themeData;

  const ScreensaverScreen({super.key, required this.themeData});

  @override
  State<ScreensaverScreen> createState() => _ScreensaverScreenState();
}

class _ScreensaverScreenState extends State<ScreensaverScreen>
    with TickerProviderStateMixin {
  late Timer _tick;
  DateTime _now = DateTime.now();

  // Animated background gradient drift
  late AnimationController _bgCtrl;
  late Animation<double> _bgAnim;

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _tick.cancel();
    _bgCtrl.dispose();
    super.dispose();
  }

  void _dismiss() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final h = _twoDigits(_now.hour);
    final m = _twoDigits(_now.minute);
    final s = _twoDigits(_now.second);

    final dateStr = DateFormat('EEEE, MMMM d').format(_now);
    final yearStr = _now.year.toString();
    final theme = widget.themeData;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (e) {
        if (e is KeyDownEvent &&
            (e.logicalKey == LogicalKeyboardKey.escape ||
                e.logicalKey == LogicalKeyboardKey.space)) {
          _dismiss();
        }
      },
      child: GestureDetector(
        onTap: _dismiss,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) {
              final t = _bgAnim.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.6 + t * 1.2,
                      -0.4 + t * 0.8,
                    ),
                    radius: 1.4,
                    colors: [
                      theme.flipCardBg.withValues(alpha: 0.55),
                      const Color(0xFF080808),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Top close button ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            tooltip: 'Exit Screensaver',
                            icon: Icon(
                              Icons.close_rounded,
                              color: theme.flipDigitColor.withValues(alpha: 0.4),
                              size: 26,
                            ),
                            onPressed: _dismiss,
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // ── Date line ─────────────────────────────────────────
                      Text(
                        dateStr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.5,
                          color: theme.flipDigitColor.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        yearStr,
                        style: AppFonts.mono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.flipDigitColor.withValues(alpha: 0.3),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Flip Plates:  HH  :  MM  :  SS ───────────────────
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          final availW = constraints.maxWidth;
                          final colonPad = (availW < 500) ? 4.0 : 10.0;
                          final cardW =
                              ((availW - 48 - (colonPad * 4)) / 3.4).clamp(50.0, 220.0);
                          final cardH = cardW * 1.18;
                          final fs = cardW * 0.70;
                          final colonFs = cardW * 0.55;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _SSFlipPlate(
                                value: h,
                                label: 'HOURS',
                                cardWidth: cardW,
                                cardHeight: cardH,
                                fontSize: fs,
                                themeData: theme,
                              ),
                              _ColonSep(
                                fontSize: colonFs,
                                themeData: theme,
                                horizontalPadding: colonPad,
                              ),
                              _SSFlipPlate(
                                value: m,
                                label: 'MINUTES',
                                cardWidth: cardW,
                                cardHeight: cardH,
                                fontSize: fs,
                                themeData: theme,
                              ),
                              _ColonSep(
                                fontSize: colonFs,
                                themeData: theme,
                                horizontalPadding: colonPad,
                              ),
                              _SSFlipPlate(
                                value: s,
                                label: 'SECONDS',
                                cardWidth: cardW,
                                cardHeight: cardH,
                                fontSize: fs,
                                themeData: theme,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 48),

                      // ── Dismiss hint ───────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 14,
                            color:
                                theme.flipDigitColor.withValues(alpha: 0.25),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TAP ANYWHERE OR PRESS ESC TO EXIT',
                            style: AppFonts.mono(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                              color:
                                  theme.flipDigitColor.withValues(alpha: 0.25),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(flex: 3),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Colon separator between plates
// ─────────────────────────────────────────────────────────────────────────────
class _ColonSep extends StatefulWidget {
  final double fontSize;
  final AppThemeData themeData;
  final double horizontalPadding;

  const _ColonSep({
    required this.fontSize,
    required this.themeData,
    this.horizontalPadding = 10,
  });

  @override
  State<_ColonSep> createState() => _ColonSepState();
}

class _ColonSepState extends State<_ColonSep>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: FadeTransition(
        opacity: _fade,
        child: Text(
          ':',
          style: AppFonts.flipNumber(
            fontSize: widget.fontSize,
            color: widget.themeData.flipDigitColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Single flip plate for screensaver (HH / MM / SS)
// ─────────────────────────────────────────────────────────────────────────────
class _SSFlipPlate extends StatefulWidget {
  final String value;
  final String label;
  final double cardWidth;
  final double cardHeight;
  final double fontSize;
  final AppThemeData themeData;

  const _SSFlipPlate({
    required this.value,
    required this.label,
    required this.cardWidth,
    required this.cardHeight,
    required this.fontSize,
    required this.themeData,
  });

  @override
  State<_SSFlipPlate> createState() => _SSFlipPlateState();
}

class _SSFlipPlateState extends State<_SSFlipPlate>
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
  void didUpdateWidget(covariant _SSFlipPlate old) {
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
    final theme = widget.themeData;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: theme.flipCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.cardBorder.withValues(alpha: 0.7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: theme.flipDigitColor.withValues(alpha: 0.04),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Static halves
                Column(
                  children: [
                    Expanded(
                      child: _SSHalfDigit(
                        value: _current,
                        isTop: true,
                        cardWidth: w,
                        cardHeight: h,
                        fontSize: widget.fontSize,
                        themeData: theme,
                      ),
                    ),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _anim,
                        builder: (_, __) => _SSHalfDigit(
                          value: _anim.value < 0.5 ? _previous : _current,
                          isTop: false,
                          cardWidth: w,
                          cardHeight: h,
                          fontSize: widget.fontSize,
                          themeData: theme,
                        ),
                      ),
                    ),
                  ],
                ),

                // Animated flap
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
                            child: _SSHalfDigit(
                              value: _previous,
                              isTop: true,
                              cardWidth: w,
                              cardHeight: h,
                              fontSize: widget.fontSize,
                              themeData: theme,
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
                            child: _SSHalfDigit(
                              value: _current,
                              isTop: false,
                              cardWidth: w,
                              cardHeight: h,
                              fontSize: widget.fontSize,
                              themeData: theme,
                              dimFactor: dim,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),

                // Center seam
                Center(
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 10,
                        decoration: BoxDecoration(
                          color: theme.flipCardSeam,
                          borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(3)),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(height: 1.8, color: theme.flipCardSeam),
                            Container(
                                height: 1.0,
                                color: Colors.white.withValues(alpha: 0.07)),
                          ],
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 10,
                        decoration: BoxDecoration(
                          color: theme.flipCardSeam,
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(3)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Label below card
        const SizedBox(height: 10),
        Text(
          widget.label,
          style: AppFonts.mono(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: theme.flipDigitColor.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Half-digit renderer for screensaver plates
// ─────────────────────────────────────────────────────────────────────────────
class _SSHalfDigit extends StatelessWidget {
  final String value;
  final bool isTop;
  final double cardWidth;
  final double cardHeight;
  final double fontSize;
  final AppThemeData themeData;
  final double dimFactor;

  const _SSHalfDigit({
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
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
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
