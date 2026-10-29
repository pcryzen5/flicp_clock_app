import 'dart:math' as math;
import 'package:flutter/material.dart';

class ScenicBackgroundWidget extends StatelessWidget {
  final String scenicType;
  final Widget child;

  const ScenicBackgroundWidget({
    super.key,
    required this.scenicType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _ScenicPainter(scenicType: scenicType),
          ),
        ),
        child,
      ],
    );
  }
}

class _ScenicPainter extends CustomPainter {
  final String scenicType;

  _ScenicPainter({required this.scenicType});

  @override
  void paint(Canvas canvas, Size size) {
    switch (scenicType) {
      case 'crimson_forest':
        _paintCrimsonForest(canvas, size);
        break;
      case 'winter_moon':
        _paintWinterMoon(canvas, size);
        break;
      case 'ocean_teal':
        _paintOceanTeal(canvas, size);
        break;
      case 'midnight_city':
        _paintMidnightCity(canvas, size);
        break;
      case 'sunset_peach':
        _paintSunsetPeach(canvas, size);
        break;
      case 'minimal_dark':
      default:
        _paintMinimalDark(canvas, size);
        break;
    }
  }

  void _paintCrimsonForest(Canvas canvas, Size size) {
    // Atmospheric scarlet radial glow in the center
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.9,
        colors: [
          const Color(0xFF4A1222).withValues(alpha: 0.6),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // Layer 1: Distant soft pine trees (lighter burgundy)
    final distantTreePaint = Paint()..color = const Color(0xFF330D19).withValues(alpha: 0.7);
    _drawPineTreeRow(canvas, size, baseHeightRatio: 0.88, treeHeight: 110, count: 18, paint: distantTreePaint, offsetSeed: 12);

    // Layer 2: Midground pine trees (rich burgundy)
    final midTreePaint = Paint()..color = const Color(0xFF260812);
    _drawPineTreeRow(canvas, size, baseHeightRatio: 0.93, treeHeight: 140, count: 14, paint: midTreePaint, offsetSeed: 45);

    // Layer 3: Foreground silhouette
    final forePaint = Paint()..color = const Color(0xFF16040A);
    final groundPath = Path()
      ..moveTo(0, size.height * 0.96)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.92, size.width, size.height * 0.95)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(groundPath, forePaint);
    _drawPineTreeRow(canvas, size, baseHeightRatio: 0.97, treeHeight: 160, count: 8, paint: forePaint, offsetSeed: 78);
  }

  void _paintWinterMoon(Canvas canvas, Size size) {
    // Glowing Full Moon on upper right
    final moonCenter = Offset(size.width * 0.75, size.height * 0.22);
    final moonRadius = math.min(size.width, size.height) * 0.12;

    // Outer luminous halo
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius * 2.6));
    canvas.drawCircle(moonCenter, moonRadius * 2.6, haloPaint);

    // Moon disc
    final moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFFE2EBF5),
          const Color(0xFFCBD6E2),
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    canvas.drawCircle(moonCenter, moonRadius, moonPaint);

    // Star specks
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.65);
    final random = math.Random(101);
    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * (size.height * 0.65);
      final r = random.nextDouble() * 1.8 + 0.5;
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }

    // Snowy curved hillside
    final snowPaint = Paint()..color = const Color(0xFF1E2838);
    final snowPath = Path()
      ..moveTo(0, size.height * 0.90)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.82, size.width * 0.75, size.height * 0.91)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.94, size.width, size.height * 0.89)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(snowPath, snowPaint);

    // Winter Pine trees silhouette
    final treePaint = Paint()..color = const Color(0xFF121924);
    _drawPineTreeRow(canvas, size, baseHeightRatio: 0.92, treeHeight: 130, count: 12, paint: treePaint, offsetSeed: 99);
  }

  void _paintOceanTeal(Canvas canvas, Size size) {
    // Luminous lunar / teal glow on top left
    final glowCenter = Offset(size.width * 0.2, size.height * 0.25);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF388E9C).withValues(alpha: 0.35),
          const Color(0xFF1E525D).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: glowCenter, radius: size.width * 0.45));
    canvas.drawCircle(glowCenter, size.width * 0.45, glowPaint);

    // Moon circle
    final moonPaint = Paint()..color = const Color(0xFFD4F4F3).withValues(alpha: 0.85);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.2), 32, moonPaint);

    // Forest pine silhouettes across the bottom
    final midTreePaint = Paint()..color = const Color(0xFF13323B);
    _drawPineTreeRow(canvas, size, baseHeightRatio: 0.89, treeHeight: 120, count: 16, paint: midTreePaint, offsetSeed: 33);

    final forePaint = Paint()..color = const Color(0xFF091C22);
    final groundPath = Path()
      ..moveTo(0, size.height * 0.94)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.90, size.width, size.height * 0.95)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(groundPath, forePaint);
    _drawPineTreeRow(canvas, size, baseHeightRatio: 0.96, treeHeight: 150, count: 10, paint: forePaint, offsetSeed: 55);
  }

  void _paintMidnightCity(Canvas canvas, Size size) {
    // Star particles in upper space
    final starPaint = Paint()..color = const Color(0xFFB4C8F5).withValues(alpha: 0.6);
    final random = math.Random(77);
    for (int i = 0; i < 45; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * (size.height * 0.6);
      final r = random.nextDouble() * 1.6 + 0.6;
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }

    // Distant city silhouette / ridges
    final cityPaint = Paint()..color = const Color(0xFF181D2E);
    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, size.height * 0.91);

    // Staggered building blocks
    const double step = 28;
    for (double x = 0; x < size.width; x += step) {
      final h = 25 + (random.nextDouble() * 35);
      path.lineTo(x, size.height * 0.94 - h);
      path.lineTo(x + step * 0.85, size.height * 0.94 - h);
      path.lineTo(x + step * 0.85, size.height * 0.94);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, cityPaint);

    final foreBase = Paint()..color = const Color(0xFF0F121E);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.94, size.width, size.height * 0.06), foreBase);
  }

  void _paintSunsetPeach(Canvas canvas, Size size) {
    // Radiant warm sun disc in lower left
    final sunCenter = Offset(size.width * 0.22, size.height * 0.72);
    final sunHalo = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.4),
          const Color(0xFFFFD1BA).withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: 140));
    canvas.drawCircle(sunCenter, 140, sunHalo);

    final sunPaint = Paint()..color = const Color(0xFFFFF2EB);
    canvas.drawCircle(sunCenter, 46, sunPaint);

    // Soft cloud silhouettes
    final cloudPaint = Paint()..color = const Color(0xFFFF9985).withValues(alpha: 0.45);
    _drawCloud(canvas, Offset(size.width * 0.8, size.height * 0.25), 90, cloudPaint);
    _drawCloud(canvas, Offset(size.width * 0.1, size.height * 0.35), 70, cloudPaint);
    _drawCloud(canvas, Offset(size.width * 0.7, size.height * 0.85), 110, cloudPaint);
  }

  void _paintMinimalDark(Canvas canvas, Size size) {
    // Subtle studio vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.35),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  void _drawPineTreeRow(Canvas canvas, Size size, {
    required double baseHeightRatio,
    required double treeHeight,
    required int count,
    required Paint paint,
    required int offsetSeed,
  }) {
    final random = math.Random(offsetSeed);
    final spacing = size.width / (count - 1);

    for (int i = 0; i < count; i++) {
      final x = i * spacing + (random.nextDouble() - 0.5) * (spacing * 0.4);
      final y = size.height * baseHeightRatio + (random.nextDouble() - 0.5) * 12;
      final currentHeight = treeHeight * (0.7 + random.nextDouble() * 0.5);
      final width = currentHeight * 0.42;

      final treePath = Path();
      treePath.moveTo(x, y - currentHeight); // Peak
      treePath.lineTo(x + width * 0.25, y - currentHeight * 0.65);
      treePath.lineTo(x + width * 0.15, y - currentHeight * 0.65);
      treePath.lineTo(x + width * 0.4, y - currentHeight * 0.35);
      treePath.lineTo(x + width * 0.25, y - currentHeight * 0.35);
      treePath.lineTo(x + width * 0.5, y);
      treePath.lineTo(x - width * 0.5, y);
      treePath.lineTo(x - width * 0.25, y - currentHeight * 0.35);
      treePath.lineTo(x - width * 0.4, y - currentHeight * 0.35);
      treePath.lineTo(x - width * 0.15, y - currentHeight * 0.65);
      treePath.lineTo(x - width * 0.25, y - currentHeight * 0.65);
      treePath.close();

      canvas.drawPath(treePath, paint);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(Offset(center.dx - radius * 0.7, center.dy + radius * 0.2), radius * 0.6, paint);
    canvas.drawCircle(Offset(center.dx + radius * 0.7, center.dy + radius * 0.2), radius * 0.6, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.4), width: radius * 2.2, height: radius * 0.8),
        Radius.circular(radius * 0.4),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScenicPainter oldDelegate) {
    return oldDelegate.scenicType != scenicType;
  }
}
