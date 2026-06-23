// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

/// Full-screen decorative pattern rendered behind all UI when a theme is active.
///
/// Inspired by Acleda Bank's themed backgrounds — each theme gets a distinct
/// illustrated pattern (hearts, golden lines, snowflakes, circuit hexagons …)
/// painted over the gradient at low opacity so cards remain readable.
///
/// Pass [themeId] and [themeData] to render a specific theme (e.g. in the
/// wallpaper-selection preview). Omit both to use the currently active theme.
class ThemeBackgroundOverlay extends StatelessWidget {
  final String? themeId;
  final AppThemeData? themeData;

  const ThemeBackgroundOverlay({super.key, this.themeId, this.themeData});

  @override
  Widget build(BuildContext context) {
    final ws = WallpaperService();
    final id = themeId ?? ws.currentThemeId;
    final data = themeData ?? ws.currentThemeData;
    if (id == null || data == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: SizedBox.expand(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _ThemePatternPainter(themeId: id, themeData: data),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ThemePatternPainter extends CustomPainter {
  final String themeId;
  final AppThemeData themeData;

  const _ThemePatternPainter({required this.themeId, required this.themeData});

  @override
  bool shouldRepaint(_ThemePatternPainter old) => old.themeId != themeId;

  @override
  void paint(Canvas canvas, Size size) {
    switch (themeId) {
      case 'valentine':
        _paintValentine(canvas, size);
      case 'march_8':
        _paintMarch8(canvas, size);
      case 'dynamic':
        _paintDynamic(canvas, size);
      case 'linear':
        _paintLinear(canvas, size);
      case 'modern':
        _paintModern(canvas, size);
      case 'lunar':
        _paintLunar(canvas, size);
      case 'visak_bochea':
        _paintVisakBochea(canvas, size);
      case 'smart_glass':
        _paintSmartGlass(canvas, size);
      case 'islamic':
        _paintIslamic(canvas, size);
      case 'khmer_new_year':
        _paintKhmerNewYear(canvas, size);
      case 'temple':
        _paintTemple(canvas, size);
      case 'xmas':
        _paintXmas(canvas, size);
      case 'water_festival':
        _paintWaterFestival(canvas, size);
      case 'pchum_ben':
        _paintPchumBen(canvas, size);
      case 'cartoon':
        _paintCartoon(canvas, size);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _paintCircleGlow(
      Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withOpacity(0)],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.fill);
  }

  /// Heart shape centred on [centre] with bounding square [sz].
  void _drawHeart(Canvas canvas, Offset centre, double sz, Paint paint) {
    final w = sz;
    final h = sz;
    final x = centre.dx - w / 2;
    final y = centre.dy - h / 2;
    final path = Path()
      ..moveTo(x + w / 2, y + h * 0.32)
      ..cubicTo(x + w / 2, y + h * 0.04, x + w * 0.92, y + h * 0.04,
          x + w * 0.92, y + h * 0.32)
      ..cubicTo(
          x + w * 0.92, y + h * 0.60, x + w / 2, y + h * 0.86, x + w / 2, y + h)
      ..cubicTo(x + w / 2, y + h * 0.86, x + w * 0.08, y + h * 0.60,
          x + w * 0.08, y + h * 0.32)
      ..cubicTo(x + w * 0.08, y + h * 0.04, x + w / 2, y + h * 0.04, x + w / 2,
          y + h * 0.32)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawStar(
      Canvas canvas, Offset center, double innerR, double outerR, Paint paint) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = (i * 2 * pi / 10) - pi / 2;
      final r = i.isEven ? outerR : innerR;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * pi / 3) - pi / 6;
      final p = Offset(
          center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      if (i == 0)
        path.moveTo(p.dx, p.dy);
      else
        path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSnowflake(Canvas canvas, Offset center, double size, Paint paint) {
    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * pi / 3);
      canvas.drawLine(Offset(0, -size / 2), Offset(0, size / 2), paint);
      canvas.drawLine(Offset(-size * 0.18, -size * 0.22),
          Offset(size * 0.18, -size * 0.22), paint);
      canvas.drawLine(Offset(-size * 0.14, 0), Offset(size * 0.14, 0), paint);
      canvas.restore();
    }
  }

  void _drawWaterDrop(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..cubicTo(center.dx + size, center.dy - size * 0.3, center.dx + size,
          center.dy + size * 0.5, center.dx, center.dy + size)
      ..cubicTo(center.dx - size, center.dy + size * 0.5, center.dx - size,
          center.dy - size * 0.3, center.dx, center.dy - size);
    canvas.drawPath(path, paint);
  }

  /// 4-pointed sparkle / twinkle star.
  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a1 = i * pi / 2 - pi / 2;
      final a2 = a1 + pi / 4;
      final ox = center.dx + size * cos(a1);
      final oy = center.dy + size * sin(a1);
      final ix = center.dx + size * 0.28 * cos(a2);
      final iy = center.dy + size * 0.28 * sin(a2);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// 5-petal flower.
  void _drawFlower(Canvas canvas, Offset center, double size, Paint paint) {
    for (var i = 0; i < 5; i++) {
      final angle = i * 2 * pi / 5 - pi / 2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(0, -size * 0.34),
            width: size * 0.36,
            height: size * 0.52),
        paint,
      );
      canvas.restore();
    }
    canvas.drawCircle(center, size * 0.14, paint);
  }

  /// Multi-petal lotus blossom.
  void _drawLotus(Canvas canvas, Offset center, double size, Paint paint) {
    for (var layer = 0; layer < 2; layer++) {
      final n = 5 + layer;
      final off = layer == 0 ? 0.0 : pi / (5 + layer);
      final len = layer == 0 ? 0.60 : 0.82;
      final w = layer == 0 ? 0.14 : 0.18;
      for (var i = 0; i < n; i++) {
        final a = i * 2 * pi / n + off - pi / 2;
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(a);
        canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(-size * w, -size * 0.38, 0, -size * len)
            ..quadraticBezierTo(size * w, -size * 0.38, 0, 0),
          paint,
        );
        canvas.restore();
      }
    }
  }

  /// Crescent moon (cutout approach).
  void _drawCrescent(Canvas canvas, Offset center, double size, Paint paint) {
    final outer = Path()
      ..addOval(Rect.fromCircle(center: center, radius: size));
    final inner = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(center.dx + size * 0.38, center.dy - size * 0.10),
        radius: size * 0.76,
      ));
    canvas.drawPath(
        Path.combine(PathOperation.difference, outer, inner), paint);
  }

  /// Soft cloud silhouette.
  void _drawCloud(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawPath(
      Path()
        ..addOval(Rect.fromCircle(
            center: Offset(center.dx - size * 0.28, center.dy + size * 0.06),
            radius: size * 0.28))
        ..addOval(Rect.fromCircle(
            center: Offset(center.dx + size * 0.28, center.dy + size * 0.06),
            radius: size * 0.28))
        ..addOval(Rect.fromCircle(
            center: Offset(center.dx, center.dy - size * 0.08),
            radius: size * 0.35))
        ..addOval(Rect.fromCircle(
            center: Offset(center.dx - size * 0.50, center.dy + size * 0.12),
            radius: size * 0.20))
        ..addOval(Rect.fromCircle(
            center: Offset(center.dx + size * 0.50, center.dy + size * 0.12),
            radius: size * 0.20)),
      paint,
    );
  }

  /// Layered pine / Christmas tree.
  void _drawPineTree(Canvas canvas, Offset center, double size, Paint paint) {
    for (var i = 0; i < 3; i++) {
      final w = size * (0.26 + i * 0.14);
      final h = size * 0.28;
      final y = center.dy - size * 0.42 + i * h * 0.62;
      canvas.drawPath(
        Path()
          ..moveTo(center.dx, y)
          ..lineTo(center.dx - w, y + h)
          ..lineTo(center.dx + w, y + h)
          ..close(),
        paint,
      );
    }
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size * 0.42),
        width: size * 0.10,
        height: size * 0.14,
      ),
      paint,
    );
  }

  /// Candle / incense flame.
  void _drawFlame(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - size)
        ..cubicTo(
            center.dx + size * 0.40,
            center.dy - size * 0.40,
            center.dx + size * 0.35,
            center.dy + size * 0.30,
            center.dx,
            center.dy + size * 0.50)
        ..cubicTo(
            center.dx - size * 0.35,
            center.dy + size * 0.30,
            center.dx - size * 0.40,
            center.dy - size * 0.40,
            center.dx,
            center.dy - size),
      paint,
    );
  }

  /// Botanical leaf with central vein.
  void _drawLeaf(
      Canvas canvas, Offset center, double size, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawPath(
      Path()
        ..moveTo(0, -size)
        ..quadraticBezierTo(size * 0.45, -size * 0.22, 0, size)
        ..quadraticBezierTo(-size * 0.45, -size * 0.22, 0, -size),
      paint,
    );
    canvas.drawLine(
      Offset(0, -size * 0.72),
      Offset(0, size * 0.72),
      Paint()
        ..color = paint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    canvas.restore();
  }

  /// Flowing ribbon path.
  void _drawRibbon(Canvas canvas, Size s, double y, double amp,
      double wavelength, Paint paint) {
    final path = Path()..moveTo(-20, y);
    var x = -20.0;
    while (x < s.width + 40) {
      path.cubicTo(x + wavelength * 0.28, y - amp, x + wavelength * 0.72,
          y + amp, x + wavelength, y);
      x += wavelength;
    }
    canvas.drawPath(path, paint);
  }

  // ── Valentine: layered hearts, ribbon curves, sparkle field ────────────────

  void _paintValentine(Canvas canvas, Size s) {
    // Atmospheric glows
    _paintCircleGlow(canvas, Offset(s.width * 0.22, s.height * 0.12),
        s.width * 0.55, const Color(0xFFFF1744).withOpacity(0.06));
    _paintCircleGlow(canvas, Offset(s.width * 0.78, s.height * 0.82),
        s.width * 0.50, const Color(0xFFFF4081).withOpacity(0.07));
    _paintCircleGlow(canvas, Offset(s.width * 0.50, s.height * 0.48),
        s.width * 0.70, const Color(0xFFD50000).withOpacity(0.04));

    // Flowing ribbon curves
    final ribbon = Paint()
      ..color = const Color(0xFFFF4081).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    _drawRibbon(canvas, s, s.height * 0.22, 40, s.width * 0.38, ribbon);
    _drawRibbon(canvas, s, s.height * 0.64, 35, s.width * 0.42, ribbon);
    _drawRibbon(canvas, s, s.height * 0.88, 28, s.width * 0.34,
        ribbon..color = const Color(0xFFFF80AB).withOpacity(0.06));

    // Large faint background hearts
    for (final cfg in [
      [0.18, 0.10, 95.0, 0.06, -0.15],
      [0.82, 0.72, 105.0, 0.05, 0.12],
      [0.50, 0.42, 80.0, 0.04, -0.08],
    ]) {
      canvas.save();
      final cx = s.width * cfg[0], cy = s.height * cfg[1];
      canvas.translate(cx, cy);
      canvas.rotate(cfg[4]);
      canvas.translate(-cx, -cy);
      _drawHeart(
          canvas,
          Offset(cx, cy),
          cfg[2],
          Paint()
            ..color = const Color(0xFFFF1744).withOpacity(cfg[3])
            ..style = PaintingStyle.fill);
      canvas.restore();
    }

    // Main scattered hearts (filled + outlined)
    const hearts = [
      [0.10, 0.05, 58.0, 0.26, -0.28],
      [0.82, 0.03, 44.0, 0.30, 0.18],
      [0.96, 0.20, 34.0, 0.22, -0.08],
      [0.03, 0.30, 42.0, 0.19, 0.38],
      [0.56, 0.14, 26.0, 0.28, 0.10],
      [0.88, 0.44, 54.0, 0.21, -0.18],
      [0.20, 0.54, 32.0, 0.26, 0.28],
      [0.44, 0.70, 48.0, 0.19, -0.10],
      [0.76, 0.66, 28.0, 0.28, 0.20],
      [0.06, 0.80, 52.0, 0.20, -0.22],
      [0.54, 0.87, 38.0, 0.24, 0.14],
      [0.34, 0.37, 22.0, 0.30, -0.08],
      [0.66, 0.50, 26.0, 0.23, 0.28],
      [0.26, 0.94, 46.0, 0.19, 0.18],
      [0.94, 0.82, 36.0, 0.24, -0.14],
    ];
    for (final cfg in hearts) {
      final cx = s.width * cfg[0], cy = s.height * cfg[1];
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(cfg[4]);
      canvas.translate(-cx, -cy);
      _drawHeart(
          canvas,
          Offset(cx, cy),
          cfg[2],
          Paint()
            ..color = const Color(0xFFFF1744).withOpacity(cfg[3] * 0.65)
            ..style = PaintingStyle.fill);
      _drawHeart(
          canvas,
          Offset(cx, cy),
          cfg[2],
          Paint()
            ..color = const Color(0xFFFF4081).withOpacity(cfg[3] + 0.04)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3);
      canvas.restore();
    }

    // Sparkle twinkles
    final sp = Paint()
      ..color = const Color(0xFFFFCDD2).withOpacity(0.38)
      ..style = PaintingStyle.fill;
    for (final p in [
      [0.15, 0.18, 6.0],
      [0.70, 0.12, 5.0],
      [0.42, 0.28, 7.0],
      [0.90, 0.36, 5.0],
      [0.08, 0.48, 6.0],
      [0.56, 0.42, 4.0],
      [0.28, 0.64, 6.0],
      [0.80, 0.56, 5.0],
      [0.46, 0.80, 7.0],
      [0.12, 0.92, 5.0],
      [0.92, 0.72, 6.0],
      [0.64, 0.94, 4.0],
    ]) {
      _drawSparkle(canvas, Offset(s.width * p[0], s.height * p[1]), p[2], sp);
    }
  }

  // ── March 8: flowers, petals, hearts, ribbons ─────────────────────────────

  void _paintMarch8(Canvas canvas, Size s) {
    // Warm rose glows
    _paintCircleGlow(canvas, Offset(s.width * 0.80, s.height * 0.10),
        s.width * 0.50, const Color(0xFFFF80AB).withOpacity(0.08));
    _paintCircleGlow(canvas, Offset(s.width * 0.20, s.height * 0.85),
        s.width * 0.45, const Color(0xFFE91E8C).withOpacity(0.06));
    _paintCircleGlow(canvas, Offset(s.width * 0.50, s.height * 0.45),
        s.width * 0.65, const Color(0xFFF48FB1).withOpacity(0.04));

    // Gentle ribbon curves
    final ribbon = Paint()
      ..color = const Color(0xFFE91E8C).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    _drawRibbon(canvas, s, s.height * 0.18, 32, s.width * 0.36, ribbon);
    _drawRibbon(canvas, s, s.height * 0.55, 28, s.width * 0.40, ribbon);

    // 5-petal flowers (filled + stroked)
    final flowerFill = Paint()
      ..color = const Color(0xFFE91E8C).withOpacity(0.10)
      ..style = PaintingStyle.fill;
    final flowerStroke = Paint()
      ..color = const Color(0xFFFF80AB).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (final f in [
      [0.14, 0.08, 34.0],
      [0.78, 0.12, 28.0],
      [0.50, 0.22, 22.0],
      [0.08, 0.42, 30.0],
      [0.86, 0.48, 26.0],
      [0.36, 0.60, 32.0],
      [0.68, 0.70, 24.0],
      [0.18, 0.78, 28.0],
      [0.54, 0.88, 30.0],
      [0.90, 0.82, 22.0],
    ]) {
      final c = Offset(s.width * f[0], s.height * f[1]);
      _drawFlower(canvas, c, f[2], flowerFill);
      _drawFlower(canvas, c, f[2], flowerStroke);
    }

    // Small scattered hearts between flowers
    for (final h in [
      [0.40, 0.10, 20.0, 0.15],
      [0.62, 0.30, 18.0, 0.18],
      [0.24, 0.52, 16.0, 0.16],
      [0.80, 0.62, 20.0, 0.14],
      [0.46, 0.74, 18.0, 0.17],
      [0.12, 0.90, 22.0, 0.15],
      [0.72, 0.88, 16.0, 0.18],
      [0.92, 0.28, 14.0, 0.16],
    ]) {
      _drawHeart(
          canvas,
          Offset(s.width * h[0], s.height * h[1]),
          h[2],
          Paint()
            ..color = const Color(0xFFE91E8C).withOpacity(h[3])
            ..style = PaintingStyle.fill);
    }

    // Sparkle accents
    final sp = Paint()
      ..color = const Color(0xFFFCE4EC).withOpacity(0.35)
      ..style = PaintingStyle.fill;
    for (final p in [
      [0.30, 0.15, 5.0],
      [0.65, 0.20, 6.0],
      [0.18, 0.36, 5.0],
      [0.88, 0.40, 4.0],
      [0.42, 0.48, 6.0],
      [0.74, 0.56, 5.0],
      [0.08, 0.65, 4.0],
      [0.56, 0.78, 6.0],
      [0.30, 0.92, 5.0],
    ]) {
      _drawSparkle(canvas, Offset(s.width * p[0], s.height * p[1]), p[2], sp);
    }
  }

  // ── Dynamic: neon circuit network, particle trails, hexagonal accents ──────

  void _paintDynamic(Canvas canvas, Size s) {
    // Deep atmospheric glow
    _paintCircleGlow(canvas, Offset(s.width * 0.72, s.height * 0.18),
        s.width * 0.55, const Color(0xFF0040FF).withOpacity(0.08));
    _paintCircleGlow(canvas, Offset(s.width * 0.25, s.height * 0.75),
        s.width * 0.50, const Color(0xFF00B0FF).withOpacity(0.06));

    // Neon connection lines (curved)
    final linePaint = Paint()
      ..color = const Color(0xFF00B0FF).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final connections = [
      [0.08, 0.06, 0.35, 0.18],
      [0.35, 0.18, 0.62, 0.08],
      [0.62, 0.08, 0.90, 0.22],
      [0.90, 0.22, 0.72, 0.42],
      [0.72, 0.42, 0.48, 0.34],
      [0.48, 0.34, 0.22, 0.48],
      [0.22, 0.48, 0.06, 0.62],
      [0.06, 0.62, 0.28, 0.78],
      [0.28, 0.78, 0.52, 0.68],
      [0.52, 0.68, 0.78, 0.76],
      [0.78, 0.76, 0.92, 0.60],
      [0.92, 0.60, 0.72, 0.42],
      [0.28, 0.78, 0.48, 0.92],
      [0.48, 0.92, 0.72, 0.88],
      [0.15, 0.30, 0.35, 0.18],
      [0.55, 0.52, 0.72, 0.42],
    ];
    for (final c in connections) {
      final x1 = s.width * c[0], y1 = s.height * c[1];
      final x2 = s.width * c[2], y2 = s.height * c[3];
      final cx = (x1 + x2) / 2 + (y2 - y1) * 0.30;
      final cy = (y1 + y2) / 2 - (x2 - x1) * 0.30;
      canvas.drawPath(
          Path()
            ..moveTo(x1, y1)
            ..quadraticBezierTo(cx, cy, x2, y2),
          linePaint);
    }

    // Glowing nodes
    final nodes = [
      [0.08, 0.06],
      [0.35, 0.18],
      [0.62, 0.08],
      [0.90, 0.22],
      [0.72, 0.42],
      [0.48, 0.34],
      [0.22, 0.48],
      [0.06, 0.62],
      [0.28, 0.78],
      [0.52, 0.68],
      [0.78, 0.76],
      [0.92, 0.60],
      [0.48, 0.92],
      [0.72, 0.88],
      [0.15, 0.30],
      [0.55, 0.52],
    ];
    for (final n in nodes) {
      final c = Offset(s.width * n[0], s.height * n[1]);
      _paintCircleGlow(
          canvas, c, 30, const Color(0xFF00B0FF).withOpacity(0.14));
      canvas.drawCircle(
          c, 3.5, Paint()..color = const Color(0xFF00B0FF).withOpacity(0.50));
    }

    // Tiny particle dots scattered
    final dotPaint = Paint()..color = const Color(0xFF80D8FF).withOpacity(0.28);
    for (final d in [
      [0.18, 0.12],
      [0.45, 0.08],
      [0.76, 0.14],
      [0.95, 0.38],
      [0.38, 0.26],
      [0.12, 0.44],
      [0.58, 0.46],
      [0.84, 0.52],
      [0.32, 0.62],
      [0.68, 0.58],
      [0.14, 0.74],
      [0.44, 0.84],
      [0.86, 0.82],
      [0.62, 0.94],
      [0.22, 0.92],
      [0.96, 0.72],
    ]) {
      canvas.drawCircle(Offset(s.width * d[0], s.height * d[1]), 1.8, dotPaint);
    }

    // Hexagonal accent shapes
    final hexPaint = Paint()
      ..color = const Color(0xFF00B0FF).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (final h in [
      [0.15, 0.20, 22.0],
      [0.85, 0.35, 18.0],
      [0.40, 0.55, 20.0],
      [0.70, 0.80, 16.0],
      [0.10, 0.85, 24.0],
    ]) {
      _drawHexagon(
          canvas, Offset(s.width * h[0], s.height * h[1]), h[2], hexPaint);
    }
  }

  // ── Linear: data-matrix grid, scan pulses, glowing intersections ──────────

  void _paintLinear(Canvas canvas, Size s) {
    // Atmospheric glow
    _paintCircleGlow(canvas, Offset(s.width * 0.50, s.height * 0.10),
        s.width * 0.65, const Color(0xFF0D47A1).withOpacity(0.07));
    _paintCircleGlow(canvas, Offset(s.width * 0.30, s.height * 0.80),
        s.width * 0.45, const Color(0xFF40C4FF).withOpacity(0.05));

    // Horizontal scan lines
    final hPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (final yf in [
      0.08,
      0.16,
      0.24,
      0.32,
      0.40,
      0.50,
      0.58,
      0.66,
      0.74,
      0.82,
      0.90
    ]) {
      hPaint.color =
          const Color(0xFF40C4FF).withOpacity(yf < 0.35 ? 0.16 : 0.10);
      canvas.drawLine(
          Offset(0, s.height * yf), Offset(s.width, s.height * yf), hPaint);
    }

    // Vertical accent lines
    final vPaint = Paint()
      ..color = const Color(0xFF40C4FF).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (final xf in [0.20, 0.40, 0.60, 0.80]) {
      canvas.drawLine(
          Offset(s.width * xf, 0), Offset(s.width * xf, s.height), vPaint);
    }

    // Glowing intersection nodes
    for (final yf in [0.16, 0.32, 0.50, 0.66, 0.82]) {
      for (final xf in [0.20, 0.40, 0.60, 0.80]) {
        final c = Offset(s.width * xf, s.height * yf);
        _paintCircleGlow(
            canvas, c, 20, const Color(0xFF40C4FF).withOpacity(0.14));
        canvas.drawCircle(
            c, 2.5, Paint()..color = const Color(0xFF40C4FF).withOpacity(0.50));
      }
    }

    // "Data pulse" dots flowing along select horizontal lines
    final pulseDot = Paint()..color = const Color(0xFF80D8FF).withOpacity(0.35);
    for (final pulse in [
      [0.12, 0.16],
      [0.34, 0.16],
      [0.68, 0.16],
      [0.88, 0.16],
      [0.22, 0.50],
      [0.52, 0.50],
      [0.78, 0.50],
      [0.16, 0.82],
      [0.44, 0.82],
      [0.72, 0.82],
      [0.94, 0.82],
    ]) {
      canvas.drawCircle(
          Offset(s.width * pulse[0], s.height * pulse[1]), 2.0, pulseDot);
    }

    // Small square accents
    final sqPaint = Paint()
      ..color = const Color(0xFF40C4FF).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final sq in [
      [0.10, 0.24, 14.0],
      [0.50, 0.40, 12.0],
      [0.90, 0.58, 14.0],
      [0.30, 0.74, 10.0],
      [0.70, 0.90, 12.0],
    ]) {
      canvas.save();
      canvas.translate(s.width * sq[0], s.height * sq[1]);
      canvas.rotate(pi / 4);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: sq[2], height: sq[2]),
          sqPaint);
      canvas.restore();
    }
  }

  // ── Modern: constellation map, diagonal lines, diamond ornaments ─────────

  void _paintModern(Canvas canvas, Size s) {
    // Subtle atmospheric glow
    _paintCircleGlow(canvas, Offset(s.width * 0.50, s.height * 0.45),
        s.width * 0.80, const Color(0xFF1565C0).withOpacity(0.05));
    _paintCircleGlow(canvas, Offset(s.width * 0.85, s.height * 0.12),
        s.width * 0.40, const Color(0xFF58A6FF).withOpacity(0.06));

    // Diagonal tech lines
    final diagPaint = Paint()
      ..color = const Color(0xFF58A6FF).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    final spacing = s.width * 0.13;
    final count = (s.width / spacing).ceil() + 10;
    for (var i = -4; i < count; i++) {
      final sx = i * spacing - s.height * 0.5;
      canvas.drawLine(
          Offset(sx, 0), Offset(sx + s.height, s.height), diagPaint);
    }

    // Constellation dots + connections
    final stars = [
      [0.12, 0.08],
      [0.28, 0.14],
      [0.45, 0.06],
      [0.68, 0.10],
      [0.85, 0.16],
      [0.08, 0.32],
      [0.35, 0.28],
      [0.58, 0.22],
      [0.78, 0.34],
      [0.92, 0.42],
      [0.18, 0.50],
      [0.48, 0.46],
      [0.72, 0.52],
      [0.06, 0.68],
      [0.32, 0.64],
      [0.56, 0.70],
      [0.82, 0.66],
      [0.22, 0.82],
      [0.50, 0.86],
      [0.76, 0.80],
      [0.94, 0.76],
      [0.40, 0.94],
      [0.62, 0.92],
      [0.14, 0.96],
    ];
    // Constellation lines between nearby stars
    final constLine = Paint()
      ..color = const Color(0xFF58A6FF).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    final constellations = [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 4],
      [5, 6],
      [6, 7],
      [7, 8],
      [8, 9],
      [10, 11],
      [11, 12],
      [13, 14],
      [14, 15],
      [15, 16],
      [17, 18],
      [18, 19],
      [19, 20],
      [21, 22],
      [1, 6],
      [6, 11],
      [11, 14],
      [3, 7],
      [7, 11],
      [12, 16],
      [14, 17],
      [15, 18],
    ];
    for (final c in constellations) {
      final a = stars[c[0].toInt()], b = stars[c[1].toInt()];
      canvas.drawLine(
        Offset(s.width * a[0], s.height * a[1]),
        Offset(s.width * b[0], s.height * b[1]),
        constLine,
      );
    }
    // Star dots
    for (final st in stars) {
      final c = Offset(s.width * st[0], s.height * st[1]);
      _paintCircleGlow(
          canvas, c, 14, const Color(0xFF58A6FF).withOpacity(0.10));
      canvas.drawCircle(
          c, 2.0, Paint()..color = const Color(0xFF58A6FF).withOpacity(0.45));
    }

    // Diamond ornaments at key intersections
    final dPaint = Paint()
      ..color = const Color(0xFF58A6FF).withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (final d in [
      [0.14, 0.14, 50.0],
      [0.82, 0.24, 38.0],
      [0.56, 0.68, 45.0],
      [0.22, 0.74, 32.0],
      [0.74, 0.88, 40.0],
    ]) {
      canvas.save();
      canvas.translate(s.width * d[0], s.height * d[1]);
      canvas.rotate(pi / 4);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: d[2], height: d[2]),
          dPaint);
      canvas.restore();
    }
  }

  // ── Lunar: golden moon, stars, clouds, lanterns ────────────────────────────

  void _paintLunar(Canvas canvas, Size s) {
    // Large golden moon glow (top right)
    _paintCircleGlow(canvas, Offset(s.width * 0.82, s.height * 0.08),
        s.width * 0.55, const Color(0xFFFFAA00).withOpacity(0.12));
    _paintCircleGlow(canvas, Offset(s.width * 0.82, s.height * 0.08),
        s.width * 0.30, const Color(0xFFFFD54F).withOpacity(0.10));
    // Warm bottom glow
    _paintCircleGlow(canvas, Offset(s.width * 0.30, s.height * 0.90),
        s.width * 0.50, const Color(0xFFFF8F00).withOpacity(0.06));

    // Crescent moon
    _drawCrescent(
      canvas,
      Offset(s.width * 0.84, s.height * 0.07),
      s.width * 0.10,
      Paint()
        ..color = const Color(0xFFFFAA00).withOpacity(0.14)
        ..style = PaintingStyle.fill,
    );

    // Cloud silhouettes
    final cloudPaint = Paint()
      ..color = const Color(0xFFFFCC80).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    _drawCloud(canvas, Offset(s.width * 0.20, s.height * 0.14), 45, cloudPaint);
    _drawCloud(canvas, Offset(s.width * 0.65, s.height * 0.20), 38, cloudPaint);
    _drawCloud(canvas, Offset(s.width * 0.10, s.height * 0.52), 42, cloudPaint);
    _drawCloud(canvas, Offset(s.width * 0.78, s.height * 0.60), 36, cloudPaint);
    _drawCloud(canvas, Offset(s.width * 0.42, s.height * 0.85), 40, cloudPaint);

    // Golden stars scattered
    final starPaint = Paint()
      ..color = const Color(0xFFFFEE58).withOpacity(0.40)
      ..style = PaintingStyle.fill;
    for (final st in [
      [0.14, 0.05, 14.0],
      [0.36, 0.03, 10.0],
      [0.58, 0.08, 12.0],
      [0.04, 0.22, 8.0],
      [0.48, 0.18, 11.0],
      [0.88, 0.28, 10.0],
      [0.24, 0.36, 7.0],
      [0.70, 0.40, 12.0],
      [0.94, 0.48, 8.0],
      [0.06, 0.56, 11.0],
      [0.38, 0.60, 9.0],
      [0.56, 0.72, 8.0],
      [0.80, 0.74, 11.0],
      [0.16, 0.82, 10.0],
      [0.50, 0.88, 13.0],
      [0.84, 0.92, 9.0],
      [0.66, 0.54, 7.0],
      [0.32, 0.16, 10.0],
    ]) {
      _drawStar(canvas, Offset(s.width * st[0], s.height * st[1]), st[2] * 0.40,
          st[2], starPaint);
    }

    // Sparkle accents
    final sparkle = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.32)
      ..style = PaintingStyle.fill;
    for (final sp in [
      [0.28, 0.10, 5.0],
      [0.72, 0.15, 6.0],
      [0.46, 0.30, 4.0],
      [0.14, 0.45, 5.0],
      [0.60, 0.48, 6.0],
      [0.86, 0.55, 4.0],
      [0.34, 0.76, 5.0],
      [0.70, 0.84, 6.0],
    ]) {
      _drawSparkle(
          canvas, Offset(s.width * sp[0], s.height * sp[1]), sp[2], sparkle);
    }

    // Soft aurora arc
    canvas.drawPath(
        Path()
          ..moveTo(0, s.height * 0.28)
          ..quadraticBezierTo(
              s.width * 0.50, s.height * 0.14, s.width, s.height * 0.28),
        Paint()
          ..color = const Color(0xFFFFAA00).withOpacity(0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 55
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
  }

  // ── Visak Bochea: sacred lotus flowers, golden geometry, dharma accents ──

  void _paintVisakBochea(Canvas canvas, Size s) {
    // Sacred golden glow
    _paintCircleGlow(canvas, Offset(s.width * 0.50, s.height * 0.32),
        s.width * 0.65, const Color(0xFFFFD700).withOpacity(0.07));
    _paintCircleGlow(canvas, Offset(s.width * 0.20, s.height * 0.75),
        s.width * 0.40, const Color(0xFFFFAB00).withOpacity(0.05));
    _paintCircleGlow(canvas, Offset(s.width * 0.80, s.height * 0.10),
        s.width * 0.35, const Color(0xFFFFD54F).withOpacity(0.06));

    // Sacred concentric rings
    final ringPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (final r in [
      [0.50, 0.32, 5],
      [0.18, 0.68, 3],
      [0.82, 0.72, 3],
    ]) {
      final c = Offset(s.width * r[0], s.height * r[1]);
      for (var i = 1; i <= r[2].toInt(); i++) {
        canvas.drawCircle(c, i * 30.0, ringPaint);
      }
    }

    // Lotus flowers at key positions
    final lotusFill = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.10)
      ..style = PaintingStyle.fill;
    final lotusStroke = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final l in [
      [0.50, 0.30, 42.0],
      [0.16, 0.54, 30.0],
      [0.84, 0.48, 34.0],
      [0.36, 0.78, 28.0],
      [0.72, 0.82, 32.0],
    ]) {
      final c = Offset(s.width * l[0], s.height * l[1]);
      _drawLotus(canvas, c, l[2], lotusFill);
      _drawLotus(canvas, c, l[2], lotusStroke);
    }

    // Diagonal gold lines (lighter, fewer)
    final diagPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final totalDiag = ((s.width + s.height) / (s.width * 0.16)).ceil() + 3;
    for (var i = -2; i < totalDiag; i++) {
      final sx = -s.height + i * s.width * 0.16;
      canvas.drawLine(
          Offset(sx, 0), Offset(sx + s.height, s.height), diagPaint);
    }

    // Diamond ornaments
    final dPaint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final d in [
      [0.10, 0.12, 28.0],
      [0.88, 0.06, 22.0],
      [0.50, 0.56, 26.0],
      [0.22, 0.90, 20.0],
      [0.78, 0.92, 24.0],
    ]) {
      canvas.save();
      canvas.translate(s.width * d[0], s.height * d[1]);
      canvas.rotate(pi / 4);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: d[2], height: d[2]),
          dPaint);
      canvas.restore();
    }

    // Sparkle accents
    final sp = Paint()
      ..color = const Color(0xFFFFE082).withOpacity(0.35)
      ..style = PaintingStyle.fill;
    for (final p in [
      [0.32, 0.14, 5.0],
      [0.68, 0.20, 6.0],
      [0.10, 0.40, 4.0],
      [0.90, 0.38, 5.0],
      [0.44, 0.64, 6.0],
      [0.58, 0.90, 5.0],
    ]) {
      _drawSparkle(canvas, Offset(s.width * p[0], s.height * p[1]), p[2], sp);
    }
  }

  // ── Smart Glass: hexagonal circuit grid, glowing nodes, data flow ────────

  void _paintSmartGlass(Canvas canvas, Size s) {
    // Subtle atmospheric glow
    _paintCircleGlow(canvas, Offset(s.width * 0.50, s.height * 0.50),
        s.width * 0.90, const Color(0xFF00897B).withOpacity(0.04));
    _paintCircleGlow(canvas, Offset(s.width * 0.15, s.height * 0.20),
        s.width * 0.40, const Color(0xFF4DB6AC).withOpacity(0.06));

    // Hexagonal grid
    final hexPaint = Paint()
      ..color = const Color(0xFF4DB6AC).withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    const hRadius = 28.0;
    final hW = hRadius * sqrt(3);
    final hH = hRadius * 1.5;
    for (var row = -1; row < (s.height / hH).ceil() + 1; row++) {
      for (var col = -1; col < (s.width / hW).ceil() + 1; col++) {
        final cx = col * hW + (row.isOdd ? hW / 2 : 0);
        final cy = row * hH;
        _drawHexagon(canvas, Offset(cx, cy), hRadius * 0.78, hexPaint);
      }
    }

    // Circuit connection lines between key nodes
    final circuitLine = Paint()
      ..color = const Color(0xFF4DB6AC).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final nodePositions = [
      [0.18, 0.12],
      [0.52, 0.18],
      [0.82, 0.08],
      [0.08, 0.38],
      [0.42, 0.42],
      [0.76, 0.36],
      [0.22, 0.62],
      [0.58, 0.66],
      [0.88, 0.58],
      [0.14, 0.84],
      [0.48, 0.88],
      [0.80, 0.82],
    ];
    final connections = [
      [0, 1],
      [1, 2],
      [0, 3],
      [1, 4],
      [2, 5],
      [3, 4],
      [4, 5],
      [3, 6],
      [4, 7],
      [5, 8],
      [6, 7],
      [7, 8],
      [6, 9],
      [7, 10],
      [8, 11],
      [9, 10],
      [10, 11],
    ];
    for (final c in connections) {
      final a = nodePositions[c[0].toInt()], b = nodePositions[c[1].toInt()];
      canvas.drawLine(
        Offset(s.width * a[0], s.height * a[1]),
        Offset(s.width * b[0], s.height * b[1]),
        circuitLine,
      );
    }

    // Glowing circuit-node dots
    for (final n in nodePositions) {
      final c = Offset(s.width * n[0], s.height * n[1]);
      _paintCircleGlow(
          canvas, c, 22, const Color(0xFF4DB6AC).withOpacity(0.14));
      canvas.drawCircle(
          c, 3.5, Paint()..color = const Color(0xFF80CBC4).withOpacity(0.55));
    }

    // Data flow dots along connections
    final flowDot = Paint()..color = const Color(0xFF80CBC4).withOpacity(0.30);
    for (final c in connections) {
      final a = nodePositions[c[0].toInt()], b = nodePositions[c[1].toInt()];
      final mx = (a[0] + b[0]) / 2, my = (a[1] + b[1]) / 2;
      canvas.drawCircle(Offset(s.width * mx, s.height * my), 1.8, flowDot);
    }

    // Diamond accent shapes
    final dPaint = Paint()
      ..color = const Color(0xFF4DB6AC).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (final d in [
      [0.32, 0.28, 18.0],
      [0.68, 0.50, 16.0],
      [0.36, 0.74, 20.0],
      [0.88, 0.38, 14.0],
      [0.12, 0.56, 16.0],
    ]) {
      canvas.save();
      canvas.translate(s.width * d[0], s.height * d[1]);
      canvas.rotate(pi / 4);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: d[2], height: d[2]),
          dPaint);
      canvas.restore();
    }
  }

  // ── Islamic: intricate arabesque, crescent accents, geometric borders ────

  void _paintIslamic(Canvas canvas, Size s) {
    // Atmospheric glow
    _paintCircleGlow(canvas, Offset(s.width * 0.78, s.height * 0.10),
        s.width * 0.45, const Color(0xFF29B6F6).withOpacity(0.07));
    _paintCircleGlow(canvas, Offset(s.width * 0.25, s.height * 0.80),
        s.width * 0.40, const Color(0xFF0288D1).withOpacity(0.05));

    // 8-pointed star arabesque grid
    final starPaint = Paint()
      ..color = const Color(0xFF29B6F6).withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    final starSpacing = s.width * 0.22;
    for (var row = -1; row < (s.height / starSpacing).ceil() + 2; row++) {
      for (var col = -1; col < (s.width / starSpacing).ceil() + 2; col++) {
        final cx = col * starSpacing + (row.isOdd ? starSpacing / 2 : 0);
        final cy = row * starSpacing * 0.85;
        _draw8PointStar(canvas, Offset(cx, cy), starSpacing * 0.28, starPaint);
      }
    }

    // Connecting geometric lines between stars
    final geoLine = Paint()
      ..color = const Color(0xFF29B6F6).withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;
    for (var row = 0; row < (s.height / starSpacing).ceil() + 1; row++) {
      for (var col = 0; col < (s.width / starSpacing).ceil() + 1; col++) {
        final cx = col * starSpacing + (row.isOdd ? starSpacing / 2 : 0);
        final cy = row * starSpacing * 0.85;
        // Small connecting circles
        canvas.drawCircle(Offset(cx, cy), starSpacing * 0.12, geoLine);
      }
    }

    // Crescent + star motifs
    final crescentPaint = Paint()
      ..color = const Color(0xFF29B6F6).withOpacity(0.18)
      ..style = PaintingStyle.fill;
    for (final cm in [
      [0.14, 0.10, 18.0],
      [0.86, 0.22, 14.0],
      [0.50, 0.50, 20.0],
      [0.22, 0.72, 16.0],
      [0.78, 0.80, 14.0],
    ]) {
      final c = Offset(s.width * cm[0], s.height * cm[1]);
      _drawCrescent(canvas, c, cm[2], crescentPaint);
      // Small star next to crescent
      _drawStar(
          canvas,
          Offset(c.dx + cm[2] * 1.5, c.dy - cm[2] * 0.6),
          cm[2] * 0.15,
          cm[2] * 0.35,
          Paint()
            ..color = const Color(0xFF29B6F6).withOpacity(0.30)
            ..style = PaintingStyle.fill);
    }

    // Sparkle accents
    final sp = Paint()
      ..color = const Color(0xFF81D4FA).withOpacity(0.30)
      ..style = PaintingStyle.fill;
    for (final p in [
      [0.36, 0.06, 5.0],
      [0.64, 0.16, 6.0],
      [0.08, 0.38, 4.0],
      [0.92, 0.44, 5.0],
      [0.42, 0.32, 4.0],
      [0.56, 0.78, 6.0],
      [0.28, 0.90, 5.0],
      [0.74, 0.64, 4.0],
    ]) {
      _drawSparkle(canvas, Offset(s.width * p[0], s.height * p[1]), p[2], sp);
    }
  }

  void _draw8PointStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * pi / 4;
      final ia = a + pi / 8;
      final op = Offset(center.dx + size * cos(a), center.dy + size * sin(a));
      final ip = Offset(
          center.dx + size * 0.42 * cos(ia), center.dy + size * 0.42 * sin(ia));
      if (i == 0) path.moveTo(op.dx, op.dy);
      path.lineTo(ip.dx, ip.dy);
      path.lineTo(op.dx, op.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // ── Khmer New Year: festive leaves, lotus rings, water splashes ──────────

  void _paintKhmerNewYear(Canvas canvas, Size s) {
    // Festive golden glow
    _paintCircleGlow(canvas, Offset(s.width * 0.50, 0), s.width * 0.80,
        const Color(0xFFFF8F00).withOpacity(0.10));
    _paintCircleGlow(canvas, Offset(s.width * 0.20, s.height * 0.70),
        s.width * 0.45, const Color(0xFF43A047).withOpacity(0.06));

    // Scattered botanical leaves
    final leafFill = Paint()
      ..color = const Color(0xFF43A047).withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final leafStroke = Paint()
      ..color = const Color(0xFF66BB6A).withOpacity(0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final l in [
      [0.08, 0.06, 22.0, -0.40],
      [0.72, 0.04, 18.0, 0.30],
      [0.92, 0.18, 20.0, -0.50],
      [0.04, 0.34, 24.0, 0.60],
      [0.56, 0.28, 16.0, -0.20],
      [0.82, 0.42, 22.0, 0.40],
      [0.18, 0.56, 18.0, -0.30],
      [0.66, 0.58, 20.0, 0.50],
      [0.38, 0.72, 24.0, -0.60],
      [0.88, 0.76, 16.0, 0.20],
      [0.10, 0.88, 22.0, -0.40],
      [0.52, 0.92, 18.0, 0.30],
    ]) {
      final c = Offset(s.width * l[0], s.height * l[1]);
      _drawLeaf(canvas, c, l[2], l[3], leafFill);
      _drawLeaf(canvas, c, l[2], l[3], leafStroke);
    }

    // Lotus ring formations
    final ringPaint = Paint()
      ..color = const Color(0xFF66BB6A).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final r in [
      [0.50, 0.16, 4],
      [0.18, 0.50, 3],
      [0.80, 0.62, 3],
      [0.44, 0.80, 3],
    ]) {
      final c = Offset(s.width * r[0], s.height * r[1]);
      for (var i = 1; i <= r[2].toInt(); i++) {
        canvas.drawCircle(c, i * 18.0, ringPaint);
      }
    }

    // Water splash curves
    final splashPaint = Paint()
      ..color = const Color(0xFF81C784).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (final sp in [
      [0.12, 0.14, 0.38, 0.08],
      [0.56, 0.20, 0.84, 0.14],
      [0.06, 0.74, 0.34, 0.68],
      [0.64, 0.82, 0.92, 0.76],
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(s.width * sp[0], s.height * sp[1])
          ..quadraticBezierTo((s.width * sp[0] + s.width * sp[2]) / 2,
              s.height * sp[1] - 28, s.width * sp[2], s.height * sp[3]),
        splashPaint,
      );
    }

    // Flower accents
    final flowerPaint = Paint()
      ..color = const Color(0xFFFF8F00).withOpacity(0.14)
      ..style = PaintingStyle.fill;
    for (final f in [
      [0.34, 0.12, 18.0],
      [0.76, 0.32, 14.0],
      [0.28, 0.46, 16.0],
      [0.62, 0.68, 18.0],
      [0.14, 0.76, 12.0],
    ]) {
      _drawFlower(
          canvas, Offset(s.width * f[0], s.height * f[1]), f[2], flowerPaint);
    }

    // Sparkle dots
    final sp = Paint()
      ..color = const Color(0xFFA5D6A7).withOpacity(0.35)
      ..style = PaintingStyle.fill;
    for (final p in [
      [0.42, 0.06, 5.0],
      [0.68, 0.18, 4.0],
      [0.16, 0.30, 5.0],
      [0.86, 0.36, 6.0],
      [0.48, 0.52, 4.0],
      [0.74, 0.72, 5.0],
      [0.24, 0.86, 6.0],
      [0.58, 0.94, 4.0],
    ]) {
      _drawSparkle(canvas, Offset(s.width * p[0], s.height * p[1]), p[2], sp);
    }
  }

  // ── Temple: Angkor arches, stepped pyramids, golden ornaments ───────────

  void _paintTemple(Canvas canvas, Size s) {
    // Warm golden glow from top
    _paintCircleGlow(canvas, Offset(s.width * 0.50, s.height * 0.06),
        s.width * 0.65, const Color(0xFFC8A96E).withOpacity(0.08));
    _paintCircleGlow(canvas, Offset(s.width * 0.20, s.height * 0.75),
        s.width * 0.35, const Color(0xFFD4A854).withOpacity(0.05));
    _paintCircleGlow(canvas, Offset(s.width * 0.80, s.height * 0.65),
        s.width * 0.35, const Color(0xFFD4A854).withOpacity(0.05));

    // Concentric arches from top centre (pointed Khmer style)
    final archPaint = Paint()
      ..color = const Color(0xFFC8A96E).withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (var i = 0; i < 7; i++) {
      final r = 55.0 + i * 52;
      final rect = Rect.fromCenter(
          center: Offset(s.width * 0.50, s.height * 0.06),
          width: r * 2,
          height: r * 1.5);
      canvas.drawArc(rect, 0, pi, false, archPaint);
    }

    // Stepped pyramid layers at bottom
    final pyramidPaint = Paint()
      ..color = const Color(0xFFC8A96E).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (var i = 0; i < 5; i++) {
      final w = s.width * (0.20 + i * 0.15);
      final y = s.height * (0.92 - i * 0.04);
      canvas.drawLine(
        Offset(s.width * 0.50 - w / 2, y),
        Offset(s.width * 0.50 + w / 2, y),
        pyramidPaint,
      );
    }

    // Diamond ornaments
    final dPaint = Paint()
      ..color = const Color(0xFFC8A96E).withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final d in [
      [0.10, 0.48, 22.0],
      [0.90, 0.42, 22.0],
      [0.28, 0.72, 18.0],
      [0.72, 0.68, 18.0],
      [0.50, 0.56, 26.0],
      [0.50, 0.38, 20.0],
    ]) {
      canvas.save();
      canvas.translate(s.width * d[0], s.height * d[1]);
      canvas.rotate(pi / 4);
      canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: d[2], height: d[2]),
          dPaint);
      canvas.restore();
    }

    // Border-style horizontal lines
    final borderPaint = Paint()
      ..color = const Color(0xFFC8A96E).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (final yf in [0.32, 0.44, 0.56, 0.68]) {
      canvas.drawLine(
        Offset(s.width * 0.08, s.height * yf),
        Offset(s.width * 0.92, s.height * yf),
        borderPaint,
      );
    }

    // Sparkle accents
    final sp = Paint()
      ..color = const Color(0xFFE6C87D).withOpacity(0.30)
      ..style = PaintingStyle.fill;
    for (final p in [
      [0.34, 0.20, 5.0],
      [0.66, 0.22, 6.0],
      [0.18, 0.50, 4.0],
      [0.82, 0.52, 5.0],
      [0.44, 0.80, 6.0],
      [0.60, 0.86, 4.0],
    ]) {
      _drawSparkle(canvas, Offset(s.width * p[0], s.height * p[1]), p[2], sp);
    }
  }

  // ── Xmas: snowflakes, pine trees, stars, snowy atmosphere ──────────────

  void _paintXmas(Canvas canvas, Size s) {
    // Snowy atmosphere glows
    _paintCircleGlow(canvas, Offset(s.width * 0.50, 0), s.width * 0.90,
        const Color(0xFF90CAF9).withOpacity(0.07));
    _paintCircleGlow(canvas, Offset(s.width * 0.20, s.height * 0.80),
        s.width * 0.40, const Color(0xFFBBDEFB).withOpacity(0.06));
    _paintCircleGlow(canvas, Offset(s.width * 0.80, s.height * 0.70),
        s.width * 0.35, const Color(0xFFBBDEFB).withOpacity(0.05));

    // Detailed snowflakes scattered
    final snowPaint = Paint()
      ..color = const Color(0xFF90CAF9).withOpacity(0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    for (final sf in [
      [0.14, 0.07, 26.0],
      [0.52, 0.04, 18.0],
      [0.86, 0.11, 22.0],
      [0.06, 0.26, 16.0],
      [0.38, 0.24, 20.0],
      [0.74, 0.28, 14.0],
      [0.94, 0.44, 18.0],
      [0.18, 0.54, 24.0],
      [0.58, 0.50, 16.0],
      [0.08, 0.70, 20.0],
      [0.44, 0.76, 22.0],
      [0.82, 0.68, 14.0],
      [0.28, 0.86, 18.0],
      [0.68, 0.90, 20.0],
      [0.96, 0.84, 16.0],
    ]) {
      _drawSnowflake(
          canvas, Offset(s.width * sf[0], s.height * sf[1]), sf[2], snowPaint);
    }

    // Pine tree silhouettes
    final treePaint = Paint()
      ..color = const Color(0xFF1976D2).withOpacity(0.10)
      ..style = PaintingStyle.fill;
    for (final t in [
      [0.12, 0.40, 30.0],
      [0.88, 0.36, 26.0],
      [0.34, 0.64, 34.0],
      [0.72, 0.60, 28.0],
      [0.50, 0.44, 22.0],
      [0.06, 0.82, 32.0],
      [0.92, 0.78, 24.0],
    ]) {
      _drawPineTree(
          canvas, Offset(s.width * t[0], s.height * t[1]), t[2], treePaint);
    }

    // Stars at treetops and scattered
    final starPaint = Paint()
      ..color = const Color(0xFFFFEE58).withOpacity(0.35)
      ..style = PaintingStyle.fill;
    for (final st in [
      [0.12, 0.26, 8.0],
      [0.88, 0.22, 7.0],
      [0.34, 0.48, 9.0],
      [0.72, 0.44, 7.0],
      [0.50, 0.34, 6.0],
      [0.26, 0.16, 10.0],
      [0.62, 0.14, 8.0],
      [0.46, 0.68, 7.0],
      [0.80, 0.84, 9.0],
    ]) {
      _drawStar(canvas, Offset(s.width * st[0], s.height * st[1]), st[2] * 0.35,
          st[2], starPaint);
    }

    // Snow dots (gentle fall effect)
    final dotPaint = Paint()..color = const Color(0xFFE3F2FD).withOpacity(0.30);
    for (final d in [
      [0.10, 0.14],
      [0.24, 0.08],
      [0.42, 0.18],
      [0.56, 0.12],
      [0.70, 0.06],
      [0.84, 0.20],
      [0.16, 0.38],
      [0.48, 0.32],
      [0.78, 0.40],
      [0.30, 0.52],
      [0.62, 0.58],
      [0.90, 0.54],
      [0.08, 0.66],
      [0.38, 0.70],
      [0.66, 0.74],
      [0.92, 0.68],
      [0.20, 0.84],
      [0.54, 0.88],
      [0.76, 0.92],
      [0.40, 0.96],
    ]) {
      canvas.drawCircle(Offset(s.width * d[0], s.height * d[1]), 2.0, dotPaint);
    }

    // Sparkle accents
    final sp = Paint()
      ..color = const Color(0xFFE3F2FD).withOpacity(0.35)
      ..style = PaintingStyle.fill;
    for (final p in [
      [0.22, 0.10, 5.0],
      [0.60, 0.08, 6.0],
      [0.40, 0.38, 4.0],
      [0.78, 0.50, 5.0],
      [0.16, 0.72, 6.0],
      [0.58, 0.82, 4.0],
    ]) {
      _drawSparkle(canvas, Offset(s.width * p[0], s.height * p[1]), p[2], sp);
    }
  }

  // ── Water Festival: multi-layered waves, drops, splash circles ──────────

  void _paintWaterFestival(Canvas canvas, Size s) {
    // Deep water atmosphere
    _paintCircleGlow(canvas, Offset(s.width * 0.50, s.height * 0.60),
        s.width * 0.85, const Color(0xFF0277BD).withOpacity(0.06));
    _paintCircleGlow(canvas, Offset(s.width * 0.20, s.height * 0.20),
        s.width * 0.40, const Color(0xFF80D8FF).withOpacity(0.07));

    // Multi-layered rolling waves
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final y = s.height * (0.10 + i * 0.11);
      final amp = 12.0 + (i % 3) * 4;
      final wavelength = 65.0 + (i % 2) * 15;
      wavePaint.color = const Color(0xFF80D8FF).withOpacity(0.18 - i * 0.012);
      final path = Path()..moveTo(-10, y);
      var x = -10.0;
      while (x < s.width + wavelength) {
        path.cubicTo(x + wavelength * 0.25, y - amp, x + wavelength * 0.75,
            y + amp, x + wavelength, y);
        x += wavelength;
      }
      canvas.drawPath(path, wavePaint);
    }

    // Splash circles (ripple effects)
    final splashPaint = Paint()
      ..color = const Color(0xFF80D8FF).withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (final sp in [
      [0.22, 0.24, 3],
      [0.68, 0.36, 4],
      [0.40, 0.58, 3],
      [0.82, 0.68, 3],
      [0.14, 0.76, 4],
    ]) {
      final c = Offset(s.width * sp[0], s.height * sp[1]);
      for (var r = 1; r <= sp[2].toInt(); r++) {
        canvas.drawCircle(c, r * 12.0, splashPaint);
      }
    }

    // Water drops scattered
    final dropFill = Paint()
      ..color = const Color(0xFF80D8FF).withOpacity(0.20)
      ..style = PaintingStyle.fill;
    final dropStroke = Paint()
      ..color = const Color(0xFFB3E5FC).withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final d in [
      [0.14, 0.08, 16.0],
      [0.64, 0.14, 14.0],
      [0.88, 0.28, 18.0],
      [0.06, 0.44, 12.0],
      [0.42, 0.38, 16.0],
      [0.78, 0.52, 14.0],
      [0.24, 0.66, 18.0],
      [0.56, 0.72, 12.0],
      [0.88, 0.78, 16.0],
      [0.12, 0.88, 14.0],
      [0.48, 0.90, 12.0],
      [0.74, 0.86, 16.0],
    ]) {
      _drawWaterDrop(
          canvas, Offset(s.width * d[0], s.height * d[1]), d[2], dropFill);
      _drawWaterDrop(
          canvas, Offset(s.width * d[0], s.height * d[1]), d[2], dropStroke);
    }

    // Sparkle accents on water
    final sp2 = Paint()
      ..color = const Color(0xFFE1F5FE).withOpacity(0.35)
      ..style = PaintingStyle.fill;
    for (final p in [
      [0.30, 0.18, 5.0],
      [0.54, 0.26, 6.0],
      [0.76, 0.42, 4.0],
      [0.18, 0.56, 5.0],
      [0.62, 0.62, 4.0],
      [0.40, 0.82, 6.0],
      [0.86, 0.88, 5.0],
    ]) {
      _drawSparkle(canvas, Offset(s.width * p[0], s.height * p[1]), p[2], sp2);
    }
  }

  // ── Pchum Ben: lotus flowers, candle flames, incense smoke ─────────────

  void _paintPchumBen(Canvas canvas, Size s) {
    // Warm candle glows
    for (final g in [
      [0.20, 0.14, 75.0, 0.10],
      [0.76, 0.18, 65.0, 0.08],
      [0.08, 0.50, 55.0, 0.07],
      [0.50, 0.55, 80.0, 0.09],
      [0.88, 0.62, 60.0, 0.07],
      [0.28, 0.84, 70.0, 0.08],
    ]) {
      _paintCircleGlow(canvas, Offset(s.width * g[0], s.height * g[1]), g[2],
          Color(0xFFFF8F00).withOpacity(g[3]));
    }

    // Lotus flowers at key positions
    final lotusFill = Paint()
      ..color = const Color(0xFFFF8F00).withOpacity(0.10)
      ..style = PaintingStyle.fill;
    final lotusStroke = Paint()
      ..color = const Color(0xFFFFB300).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (final l in [
      [0.24, 0.20, 34.0],
      [0.70, 0.28, 28.0],
      [0.14, 0.64, 30.0],
      [0.82, 0.70, 26.0],
      [0.50, 0.48, 38.0],
    ]) {
      final c = Offset(s.width * l[0], s.height * l[1]);
      _drawLotus(canvas, c, l[2], lotusFill);
      _drawLotus(canvas, c, l[2], lotusStroke);
    }

    // Candle flames
    final flameFill = Paint()
      ..color = const Color(0xFFFF8F00).withOpacity(0.16)
      ..style = PaintingStyle.fill;
    final flameStroke = Paint()
      ..color = const Color(0xFFFFCA28).withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (final f in [
      [0.16, 0.36, 14.0],
      [0.84, 0.42, 12.0],
      [0.38, 0.76, 16.0],
      [0.66, 0.82, 13.0],
      [0.50, 0.30, 11.0],
      [0.08, 0.80, 14.0],
      [0.92, 0.86, 12.0],
    ]) {
      _drawFlame(
          canvas, Offset(s.width * f[0], s.height * f[1]), f[2], flameFill);
      _drawFlame(
          canvas, Offset(s.width * f[0], s.height * f[1]), f[2], flameStroke);
    }

    // Incense smoke curves (gentle rising wisps)
    final smokePaint = Paint()
      ..color = const Color(0xFFFFCC80).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (final sm in [
      [0.20, 0.70, 0.18, 0.20],
      [0.50, 0.75, 0.52, 0.15],
      [0.76, 0.68, 0.78, 0.18],
      [0.36, 0.85, 0.34, 0.40],
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(s.width * sm[0], s.height * sm[1])
          ..cubicTo(
            s.width * sm[0] - 12,
            s.height * (sm[1] - 0.15),
            s.width * sm[2] + 12,
            s.height * (sm[3] + 0.10),
            s.width * sm[2],
            s.height * sm[3],
          ),
        smokePaint,
      );
    }

    // Sparkle accents
    final sp = Paint()
      ..color = const Color(0xFFFFE082).withOpacity(0.32)
      ..style = PaintingStyle.fill;
    for (final p in [
      [0.32, 0.10, 5.0],
      [0.62, 0.14, 6.0],
      [0.10, 0.32, 4.0],
      [0.90, 0.38, 5.0],
      [0.44, 0.62, 4.0],
      [0.72, 0.56, 5.0],
      [0.22, 0.90, 6.0],
      [0.58, 0.94, 4.0],
    ]) {
      _drawSparkle(canvas, Offset(s.width * p[0], s.height * p[1]), p[2], sp);
    }

    // Global warm glow
    _paintCircleGlow(canvas, Offset(s.width * 0.50, s.height * 0.50),
        s.width * 0.90, const Color(0xFFFF8F00).withOpacity(0.04));
  }

  // ── Cartoon: playful bubbles, stars, clouds, rainbow accents ────────────

  void _paintCartoon(Canvas canvas, Size s) {
    // Soft playful glows
    _paintCircleGlow(canvas, Offset(s.width * 0.30, s.height * 0.20),
        s.width * 0.50, const Color(0xFFFF80AB).withOpacity(0.06));
    _paintCircleGlow(canvas, Offset(s.width * 0.75, s.height * 0.70),
        s.width * 0.45, const Color(0xFF80DEEA).withOpacity(0.06));

    // Rainbow arc (subtle)
    final rainbowColors = [
      const Color(0xFFFF8A80).withOpacity(0.08),
      const Color(0xFFFFD180).withOpacity(0.08),
      const Color(0xFFFFF176).withOpacity(0.08),
      const Color(0xFFB9F6CA).withOpacity(0.08),
      const Color(0xFF82B1FF).withOpacity(0.08),
      const Color(0xFFCF94DA).withOpacity(0.08),
    ];
    for (var i = 0; i < rainbowColors.length; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(s.width * 0.50, s.height * 0.12),
          width: s.width * 0.90 + i * 14,
          height: s.width * 0.65 + i * 14,
        ),
        0,
        pi,
        false,
        Paint()
          ..color = rainbowColors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
    }

    // Cloud shapes
    final cloudPaint = Paint()
      ..color = const Color(0xFFF8BBD0).withOpacity(0.10)
      ..style = PaintingStyle.fill;
    _drawCloud(canvas, Offset(s.width * 0.16, s.height * 0.10), 36, cloudPaint);
    _drawCloud(canvas, Offset(s.width * 0.78, s.height * 0.08), 32, cloudPaint);
    _drawCloud(canvas, Offset(s.width * 0.10, s.height * 0.60), 28, cloudPaint);
    _drawCloud(canvas, Offset(s.width * 0.86, s.height * 0.56), 34, cloudPaint);
    _drawCloud(canvas, Offset(s.width * 0.44, s.height * 0.88), 30, cloudPaint);

    // Colorful bubbles (filled + stroked)
    const colours = [
      Color(0xFFFF80AB),
      Color(0xFF80DEEA),
      Color(0xFFFFF176),
      Color(0xFFCF94DA),
      Color(0xFF80CBC4),
    ];
    final bubbles = [
      [0.10, 0.07, 34.0, 0],
      [0.78, 0.12, 26.0, 1],
      [0.90, 0.34, 40.0, 2],
      [0.04, 0.44, 28.0, 3],
      [0.54, 0.22, 20.0, 4],
      [0.34, 0.52, 36.0, 0],
      [0.70, 0.62, 24.0, 1],
      [0.18, 0.74, 32.0, 2],
      [0.86, 0.76, 18.0, 3],
      [0.50, 0.84, 26.0, 4],
      [0.40, 0.32, 16.0, 0],
      [0.94, 0.54, 22.0, 1],
      [0.24, 0.92, 20.0, 2],
      [0.62, 0.44, 14.0, 3],
      [0.46, 0.66, 18.0, 4],
    ];
    for (final b in bubbles) {
      final c = Offset(s.width * (b[0] as double), s.height * (b[1] as double));
      final r = (b[2] as double) / 2;
      final col = colours[(b[3] as int) % colours.length];
      canvas.drawCircle(
          c,
          r,
          Paint()
            ..color = col.withOpacity(0.14)
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          c,
          r,
          Paint()
            ..color = col.withOpacity(0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0);
      // Highlight dot on bubble
      canvas.drawCircle(
        Offset(c.dx - r * 0.25, c.dy - r * 0.25),
        r * 0.15,
        Paint()..color = Colors.white.withOpacity(0.20),
      );
    }

    // Stars scattered
    final starPaint = Paint()
      ..color = const Color(0xFFFFEE58).withOpacity(0.38)
      ..style = PaintingStyle.fill;
    for (final st in [
      [0.20, 0.28, 12.0],
      [0.66, 0.40, 10.0],
      [0.40, 0.68, 14.0],
      [0.80, 0.22, 8.0],
      [0.12, 0.50, 11.0],
      [0.56, 0.78, 9.0],
      [0.88, 0.86, 12.0],
    ]) {
      _drawStar(canvas, Offset(s.width * st[0], s.height * st[1]), st[2] * 0.38,
          st[2], starPaint);
    }

    // Tiny sparkle dots
    final sp = Paint()
      ..color = const Color(0xFFFCE4EC).withOpacity(0.40)
      ..style = PaintingStyle.fill;
    for (final p in [
      [0.28, 0.16, 4.0],
      [0.58, 0.10, 5.0],
      [0.14, 0.38, 4.0],
      [0.84, 0.44, 5.0],
      [0.36, 0.56, 4.0],
      [0.72, 0.72, 5.0],
      [0.24, 0.86, 4.0],
      [0.66, 0.92, 5.0],
    ]) {
      _drawSparkle(canvas, Offset(s.width * p[0], s.height * p[1]), p[2], sp);
    }
  }
}
