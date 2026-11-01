import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game_logic/engine.dart';
import 'props.dart';
import 'world.dart';

/// Sol du monde, dessiné une seule fois dans des "Picture" (une par étape),
/// puis rejoué chaque image à travers la caméra en perspective.
///
/// Chaque Picture reste plus petite qu'une étape + marge, afin qu'aucune
/// partie ne passe derrière le plan de la caméra quand la perspective est forte.
class GroundPictures {
  GroundPictures(this.world, this.slotColors) {
    _build();
  }

  final World world;
  final List<Color> slotColors;

  final List<ui.Picture> ground = <ui.Picture>[];
  final List<double> groundMin = <double>[];
  final List<double> groundMax = <double>[];

  final List<ui.Picture> roads = <ui.Picture>[];
  final List<double> roadMin = <double>[];
  final List<double> roadMax = <double>[];

  late final ui.Picture beyond;
  static const double beyondMin = -1100.0;
  static const double beyondMax = 40.0;

  late final List<Prop> _props;

  static const List<Color> _top = [
    Color(0xFF9AD35E), // Hautes Terres
    Color(0xFF2B7A4B), // forêt
    Color(0xFFD9763C), // Isalo
    Color(0xFF8A9A88), // Tsingy
    Color(0xFFF3E2B3), // côte
    Color(0xFFEBB65C), // baobabs
  ];
  static const List<Color> _bottom = [
    Color(0xFF5FA83A),
    Color(0xFF1B5E36),
    Color(0xFFB5532A),
    Color(0xFF66786A),
    Color(0xFFE3CC92),
    Color(0xFFC9792F),
  ];

  void _build() {
    _props = buildProps(world);

    for (var s = 0; s < stripCount; s++) {
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      _paintStrip(c, s);
      ground.add(rec.endRecording());
      groundMin.add(s * stripH - 14);
      groundMax.add((s + 1) * stripH + (s == stripCount - 1 ? 220.0 : 50.0));
    }

    final geo = world.road();
    for (var s = 0; s < stripCount; s++) {
      final rec = ui.PictureRecorder();
      final c = Canvas(rec);
      if (s < segmentCount) {
        final r = segmentCount - 1 - s;
        _paintRoadPiece(c, geo, r);
        roadMin.add((5 - r) * stripH - 40);
        roadMax.add((6 - r) * stripH + 20);
      } else {
        _roadStyle(c, roadPath(geo.points, 0, 1));
        roadMin.add(stripH * 5.4);
        roadMax.add(stripH * 6.8);
      }
      roads.add(rec.endRecording());
    }

    final rec = ui.PictureRecorder();
    _paintBeyond(Canvas(rec));
    beyond = rec.endRecording();
  }

  // -------------------------------------------------------------------------
  // Outils
  // -------------------------------------------------------------------------

  static double _wave(double x, int s) =>
      sin(x * 0.021 + s * 1.9) * 7 + sin(x * 0.053 + s * 0.7) * 3.5;

  static Paint _line(Color c, double w, {StrokeCap cap = StrokeCap.round}) =>
      Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = cap;

  static Path _waveLine(double x0, double x1, double y, double phase,
      double amp, double freq) {
    final p = Path()..moveTo(x0, y + sin(x0 * freq + phase) * amp);
    for (var x = x0; x <= x1; x += 14) {
      p.lineTo(x, y + sin(x * freq + phase) * amp);
    }
    return p;
  }

  static void _gtext(Canvas c, String t, Offset center, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(fontSize: size, color: color, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  // -------------------------------------------------------------------------
  // Sol de chaque étape
  // -------------------------------------------------------------------------

  void _paintStrip(Canvas c, int s) {
    final x0 = -world.width * 0.6;
    final x1 = world.width * 1.6;
    final top = s * stripH;
    final bot = (s + 1) * stripH + (s == stripCount - 1 ? 220.0 : 50.0);
    final r = s < segmentCount ? segmentCount - 1 - s : -1;

    final shape = Path()..moveTo(x0, top + _wave(x0, s));
    for (var x = x0; x <= x1; x += 12) {
      shape.lineTo(x, top + _wave(x, s));
    }
    shape.lineTo(x1, bot);
    shape.lineTo(x0, bot);
    shape.close();

    final rnd = Random(100 + s);
    c.save();
    c.clipPath(shape);

    final area = Rect.fromLTRB(x0, top - 14, x1, bot);
    final a = r >= 0 ? _top[r] : const Color(0xFFD8CBB0);
    final b = r >= 0 ? _bottom[r] : const Color(0xFFB9AA8C);
    c.drawRect(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [a, b],
        ).createShader(area),
    );

    switch (r) {
      case 0:
        _terraces(c, x0, x1, top, bot, rnd);
        break;
      case 1:
        _forest(c, x0, x1, top, bot, rnd);
        break;
      case 2:
        _isalo(c, x0, x1, top, bot, rnd);
        break;
      case 3:
        _tsingy(c, x0, x1, top, bot, rnd);
        break;
      case 4:
        _coast(c, x0, x1, top, bot, rnd);
        break;
      case 5:
        _baobabLand(c, x0, x1, top, bot, rnd);
        break;
      default:
        _garage(c, x0, x1, top, bot);
    }
    c.restore();

    // Liseré lumineux le long de la lisière : effet de relief entre deux paysages
    final edge = Path()..moveTo(x0, top + _wave(x0, s));
    for (var x = x0; x <= x1; x += 12) {
      edge.lineTo(x, top + _wave(x, s));
    }
    c.drawPath(edge, _line(const Color(0x66FFFFFF), 2.4));
  }

  void _terraces(Canvas c, double x0, double x1, double top, double bot, Random rnd) {
    const greens = [Color(0xFF93CF52), Color(0xFF74B843)];
    const n = 9;
    final step = (bot - top - 50) / n;
    for (var k = 0; k < n; k++) {
      final y = top + 12 + k * step;
      final line = _waveLine(x0, x1, y, k * 0.9, 5, 0.03);
      final fill = Path.from(line)
        ..lineTo(x1, y + step + 30)
        ..lineTo(x0, y + step + 30)
        ..close();
      c.drawPath(fill, Paint()..color = greens[k % 2]);
      c.drawPath(line, _line(const Color(0xFF3F7F2A), 1.6));
      c.drawPath(line.shift(const Offset(0, -1.5)), _line(const Color(0x66FFFFFF), 1.0));
    }
    for (var i = 0; i < 20; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = top + 14 + rnd.nextDouble() * (bot - top - 60);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: 26 + rnd.nextDouble() * 30, height: 5),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0x80BDE6F2),
      );
    }
  }

  void _forest(Canvas c, double x0, double x1, double top, double bot, Random rnd) {
    const palette = [Color(0xFF2F8F52), Color(0xFF1B5E36), Color(0xFF3FA866)];
    for (var i = 0; i < 90; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = top + rnd.nextDouble() * (bot - top);
      c.drawCircle(Offset(x, y), 7 + rnd.nextDouble() * 16,
          Paint()..color = palette[i % 3].withAlpha(150));
    }
    for (var i = 0; i < 40; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = top + rnd.nextDouble() * (bot - top);
      c.drawPath(
        Path()
          ..moveTo(x, y)
          ..quadraticBezierTo(x + 6, y - 8, x + 12, y - 4),
        _line(const Color(0x8855CC77), 1.6),
      );
    }
    for (var i = 0; i < 4; i++) {
      c.drawOval(
        Rect.fromCenter(
          center: Offset((x0 + x1) / 2 + (i.isEven ? -40.0 : 50.0), top + 30 + i * 40),
          width: 300,
          height: 26,
        ),
        Paint()..color = const Color(0x26FFFFFF),
      );
    }
  }

  void _isalo(Canvas c, double x0, double x1, double top, double bot, Random rnd) {
    const bands = [Color(0xFFD9763C), Color(0xFFB5532A), Color(0xFFE8A05A), Color(0xFFC4673A)];
    for (var k = 0; k < 8; k++) {
      final y = top + k * (bot - top) / 8;
      final p = Path()
        ..moveTo(x0, y)
        ..lineTo(x1, y + 26 + (k % 3) * 8)
        ..lineTo(x1, y + 44)
        ..lineTo(x0, y + 18)
        ..close();
      c.drawPath(p, Paint()..color = bands[k % 4].withAlpha(110));
    }
    for (var i = 0; i < 45; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = top + rnd.nextDouble() * (bot - top);
      c.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 10 + rnd.nextDouble() * 22, height: 5),
        Paint()..color = const Color(0x40702A12),
      );
    }
    for (var i = 0; i < 16; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = top + rnd.nextDouble() * (bot - top);
      c.drawCircle(Offset(x, y), 3 + rnd.nextDouble() * 3, Paint()..color = const Color(0xCC7A8B3A));
    }
  }

  void _tsingy(Canvas c, double x0, double x1, double top, double bot, Random rnd) {
    for (var i = 0; i < 55; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = top + rnd.nextDouble() * (bot - top);
      c.drawPath(
        Path()
          ..moveTo(x, y)
          ..lineTo(x + rnd.nextDouble() * 30 - 15, y + rnd.nextDouble() * 20)
          ..lineTo(x + rnd.nextDouble() * 30 - 15, y - rnd.nextDouble() * 20)
          ..close(),
        Paint()..color = const Color(0x40303A30),
      );
    }
    for (var i = 0; i < 26; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = top + rnd.nextDouble() * (bot - top);
      c.drawPath(
        Path()
          ..moveTo(x, y)
          ..lineTo(x + 8, y + 5)
          ..lineTo(x + 14, y - 2)
          ..lineTo(x + 24, y + 4),
        _line(const Color(0x66222A22), 1.2),
      );
    }
    for (var i = 0; i < 22; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = top + rnd.nextDouble() * (bot - top);
      c.drawCircle(Offset(x, y), 4 + rnd.nextDouble() * 6, Paint()..color = const Color(0x6E4C7A3E));
    }
  }

  void _coast(Canvas c, double x0, double x1, double top, double bot, Random rnd) {
    final shoreY = top + stripH * 0.34;
    final water = Path()
      ..moveTo(x0, top - 20)
      ..lineTo(x1, top - 20);
    for (var x = x1; x >= x0; x -= 14) {
      water.lineTo(x, shoreY + sin(x * 0.035 + 1.0) * 9);
    }
    water.close();
    final wRect = Rect.fromLTRB(x0, top - 20, x1, shoreY + 12);
    c.drawPath(
      water,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF148FA8), Color(0xFF39BFC4), Color(0xFF9BE6E0)],
        ).createShader(wRect),
    );
    final shore = _waveLine(x0, x1, shoreY, 1.0, 9, 0.035);
    c.drawPath(shore, _line(const Color(0xCCFFFFFF), 3.2));
    c.drawPath(shore.shift(const Offset(0, 5)), _line(const Color(0x66FFFFFF), 2));
    for (var i = 0; i < 30; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = top + 4 + rnd.nextDouble() * (stripH * 0.28);
      c.drawPath(
        Path()
          ..moveTo(x, y)
          ..quadraticBezierTo(x + 8, y - 4, x + 16, y),
        _line(const Color(0x99FFFFFF), 1.4),
      );
    }
    for (var i = 0; i < 80; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = shoreY + 14 + rnd.nextDouble() * (bot - shoreY - 14);
      c.drawCircle(Offset(x, y), 0.8 + rnd.nextDouble() * 0.9, Paint()..color = const Color(0x44B8934A));
    }
  }

  void _baobabLand(Canvas c, double x0, double x1, double top, double bot, Random rnd) {
    for (var i = 0; i < 24; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = top + rnd.nextDouble() * (bot - top);
      c.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 40 + rnd.nextDouble() * 80, height: 4),
        Paint()..color = const Color(0x55FFE9B0),
      );
    }
    for (var i = 0; i < 46; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = top + rnd.nextDouble() * (bot - top);
      for (var k = 0; k < 3; k++) {
        c.drawLine(Offset(x + k * 2.2, y), Offset(x + k * 2.2 + (k - 1) * 2.0, y - 6 - k % 2 * 2.0),
            _line(const Color(0xFF9C6B1E), 1.3));
      }
    }
    // Ombres allongées des baobabs (soleil couchant, à droite)
    for (final p in _props) {
      if (p.key != 'baobab' || p.y < top || p.y > bot) continue;
      c.save();
      c.translate(p.x, p.y);
      c.rotate(0.32);
      c.drawOval(
        Rect.fromLTWH(-100 * p.scale, -7 * p.scale, 100 * p.scale, 14 * p.scale),
        Paint()..color = const Color(0x44401800),
      );
      c.restore();
    }
  }

  void _garage(Canvas c, double x0, double x1, double top, double bot) {
    final grid = _line(const Color(0x22000000), 1.0, cap: StrokeCap.butt);
    for (var x = x0; x <= x1; x += 30) {
      c.drawLine(Offset(x, top), Offset(x, bot), grid);
    }
    for (var y = top; y <= bot; y += 30) {
      c.drawLine(Offset(x0, y), Offset(x1, y), grid);
    }
    _gtext(c, 'GARAGE', Offset(world.width / 2, top + stripH * 0.34), 22, const Color(0x55FFFFFF));
    for (var i = 0; i < slotColors.length; i++) {
      final center = world.cell(garagePos, slot: i);
      final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: world.cellW * 2.7, height: 54),
        const Radius.circular(10),
      );
      c.drawRRect(rr, Paint()..color = slotColors[i].withAlpha(50));
      c.drawRRect(rr, _line(slotColors[i], 3));
      _gtext(c, '${i + 1}', center + const Offset(0, 22), 11, slotColors[i]);
    }
  }

  void _paintBeyond(Canvas c) {
    final x0 = -world.width * 0.6;
    final x1 = world.width * 1.6;
    final rnd = Random(77);
    final area = Rect.fromLTRB(x0, beyondMin, x1, beyondMax + 60);
    c.drawRect(
      area,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF0C8), Color(0xFFF5C77A), Color(0xFFEBB65C)],
        ).createShader(area),
    );
    for (var i = 0; i < 90; i++) {
      final x = x0 + rnd.nextDouble() * (x1 - x0);
      final y = beyondMin + rnd.nextDouble() * (beyondMax - beyondMin);
      c.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 60 + rnd.nextDouble() * 120, height: 5),
        Paint()..color = const Color(0x44FFFFFF),
      );
    }
  }

  // -------------------------------------------------------------------------
  // Route et bornes
  // -------------------------------------------------------------------------

  void _roadStyle(Canvas c, Path path) {
    final rw = world.cellW * 1.05;
    c.save();
    c.translate(0, 5);
    c.drawPath(path, _line(const Color(0x59000000), rw + 6, cap: StrokeCap.butt));
    c.restore();
    c.drawPath(path, _line(const Color(0xFFEADFC8), rw + 6, cap: StrokeCap.butt));
    c.drawPath(
      path,
      _line(const Color(0xFF3C3F4A), rw, cap: StrokeCap.round)
        ..strokeJoin = StrokeJoin.round,
    );
    final dash = _line(const Color(0xCCFFFFFF), 1.8, cap: StrokeCap.butt);
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        c.drawPath(m.extractPath(d, min(d + 9, m.length)), dash);
        d += 17;
      }
    }
  }

  void _paintRoadPiece(Canvas c, RoadGeometry g, int r) {
    _roadStyle(c, roadPath(g.points, g.starts[r], g.ends[r]));
    for (var col = 0; col < segLen; col++) {
      _paintCell(c, r * segLen + col + 1, r);
    }
  }

  void _paintCell(Canvas c, int pos, int r) {
    final p = world.cell(pos);
    final rr = world.cellW * 0.42;
    final local = (pos - 1) % segLen + 1;
    c.drawCircle(p + const Offset(0, 1.8), rr, Paint()..color = const Color(0x55000000));
    if (local == praOffset) {
      c.drawCircle(p, rr, Paint()..color = const Color(0xFFD7263D));
      c.drawCircle(p, rr, _line(Colors.white, 1.6));
      _gtext(c, 'PRA', p, rr * 0.95, Colors.white);
    } else if (local == segLen) {
      c.drawCircle(p, rr * 1.12, Paint()..color = const Color(0xFFF28C28));
      c.drawCircle(p, rr * 1.12, _line(Colors.white, 2));
      _gtext(c, 'BCDEFG'[r], p, rr * 1.35, Colors.white);
    } else {
      c.drawCircle(p, rr, Paint()..color = const Color(0xFFFFFAF0));
      c.drawCircle(p, rr, _line(const Color(0xFFB7AA90), 1.0));
      _gtext(c, '$local', p, rr * 1.05, const Color(0xFF2A2A2A));
    }
  }
}
