import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import 'board_geometry.dart';
import 'scenery_objects.dart';

/// Les six étapes, de bas en haut :
/// 0 Hautes Terres · 1 Forêt de l'Est · 2 Isalo · 3 Tsingy de Bemaraha ·
/// 4 Nosy Be (côte) · 5 Allée des Baobabs (coucher de soleil, arrivée G).

class _Biome {
  const _Biome(this.colors, this.stops);
  final List<Color> colors;
  final List<double> stops;
}

const List<_Biome> _biomes = [
  // 0 : rizières et collines
  _Biome([Color(0xFFA9DA74), Color(0xFF88C558), Color(0xFF6BAF47)],
      [0.0, 0.55, 1.0]),
  // 1 : forêt tropicale humide
  _Biome([Color(0xFF3F8F5B), Color(0xFF2B7048), Color(0xFF1F5A3B)],
      [0.0, 0.5, 1.0]),
  // 2 : grès orangé
  _Biome([Color(0xFFEDB468), Color(0xFFD98B45), Color(0xFFC27237)],
      [0.0, 0.55, 1.0]),
  // 3 : calcaire gris-vert
  _Biome([Color(0xFF93A08A), Color(0xFF7C8A72), Color(0xFF627059)],
      [0.0, 0.5, 1.0]),
  // 4 : lagon turquoise puis sable
  _Biome([
    Color(0xFF1FA5CC),
    Color(0xFF35C4DC),
    Color(0xFF7BE3E6),
    Color(0xFFF0DCA8),
    Color(0xFFE4C98E),
  ], [0.0, 0.3, 0.55, 0.62, 1.0]),
  // 5 : savane dorée
  _Biome([Color(0xFFEFA855), Color(0xFFD98A3E), Color(0xFFB9692D)],
      [0.0, 0.5, 1.0]),
];

Paint _f(Color c) => Paint()..color = c;

class _Item {
  _Item(this.y, this.draw);
  final double y;
  final void Function() draw;
}

int _regionOf(int row) => row == 6 ? 0 : 5 - row;

double _clampD(double v, double lo, double hi) =>
    v < lo ? lo : (v > hi ? hi : v);

List<double> _spread(Random rnd, int n, double xMin, double xMax) {
  final out = <double>[];
  final step = (xMax - xMin) / n;
  for (var k = 0; k < n; k++) {
    out.add(xMin + step * (k + 0.2 + rnd.nextDouble() * 0.6));
  }
  return out;
}

double _baseY(Random rnd, double top, double bottom) =>
    top + (bottom - top) * (0.3 + 0.7 * rnd.nextDouble());

double _wave(double x, int k) =>
    sin(x * 0.028 + k * 1.7) * 4 + sin(x * 0.011 + k) * 3;

Path _wavePath(double w, double y, double amp, double freq, double phase) {
  final p = Path()..moveTo(0, y + sin(phase) * amp);
  for (var x = 8.0; x <= w + 8; x += 8) {
    p.lineTo(x, y + sin(x * freq + phase) * amp);
  }
  return p;
}

/// Dessine tout le décor statique du plateau (ciel, sols, objets, garage).
void paintScenery(Canvas canvas, BoardGeometry g) {
  _paintSky(canvas, g);
  for (var i = 0; i <= 6; i++) {
    _paintGround(canvas, g, i);
  }
  for (var i = 0; i <= 6; i++) {
    _paintGroundDetails(canvas, g, i);
  }
  for (var i = 0; i <= 6; i++) {
    _paintGapObjects(canvas, g, i);
  }
}

// ─────────────────────────── ciel (coucher de soleil) ───────────────────────────

void _paintSky(Canvas canvas, BoardGeometry g) {
  final w = g.width;
  final sky = Rect.fromLTWH(0, 0, w, g.horizon + 12);
  canvas.drawRect(
    sky,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF3A2C63),
          Color(0xFFB5476F),
          Color(0xFFF08A5D),
          Color(0xFFFFC66E),
          Color(0xFFFFE7A8),
        ],
        stops: [0.0, 0.35, 0.65, 0.88, 1.0],
      ).createShader(sky),
  );

  // lueur et disque du soleil
  final sun = Offset(w * 0.66, g.horizon - 2);
  final glowR = g.sh * 0.95;
  canvas.drawCircle(
    sun,
    glowR,
    Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xCCFFF3C4), Color(0x66FFD27A), Color(0x00FFD27A)],
        stops: [0.15, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: sun, radius: glowR)),
  );
  canvas.drawCircle(sun, g.sh * 0.2, _f(const Color(0xFFFFF1B8)));
  canvas.drawCircle(sun, g.sh * 0.15, _f(const Color(0xFFFFFAD9)));

  // nuages étirés
  _cloud(canvas, w * 0.18, g.horizon * 0.38, g.sh * 0.5, const Color(0xBBFF9C7A));
  _cloud(canvas, w * 0.78, g.horizon * 0.25, g.sh * 0.42, const Color(0x99FFC08A));
  _cloud(canvas, w * 0.45, g.horizon * 0.62, g.sh * 0.34, const Color(0x88FFD7A0));

  // oiseaux
  final bird = Paint()
    ..color = const Color(0xCC2B1A3A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..strokeCap = StrokeCap.round;
  for (final b in [
    Offset(w * 0.3, g.horizon * 0.52),
    Offset(w * 0.36, g.horizon * 0.45),
    Offset(w * 0.86, g.horizon * 0.5),
  ]) {
    final p = Path()
      ..moveTo(b.dx - 6, b.dy)
      ..quadraticBezierTo(b.dx - 3, b.dy - 4, b.dx, b.dy)
      ..quadraticBezierTo(b.dx + 3, b.dy - 4, b.dx + 6, b.dy);
    canvas.drawPath(p, bird);
  }

  // collines lointaines (silhouettes violettes)
  for (var layer = 0; layer < 2; layer++) {
    final amp = g.sh * (layer == 0 ? 0.16 : 0.09);
    final base = g.horizon + 6;
    final hills = Path()..moveTo(0, base);
    for (var x = 0.0; x <= w + 6; x += 6) {
      final y = base -
          amp * (0.55 + 0.45 * sin(x * (0.018 + layer * 0.012) + layer * 2.1)) -
          amp * 0.25 * sin(x * 0.05 + layer);
      hills.lineTo(x, y);
    }
    hills.lineTo(w, base + 6);
    hills.lineTo(0, base + 6);
    hills.close();
    canvas.drawPath(
        hills, _f(layer == 0 ? const Color(0xCC7A4560) : const Color(0xFF5E3350)));
  }
}

void _cloud(Canvas c, double x, double y, double s, Color col) {
  c.drawOval(Rect.fromCenter(center: Offset(x, y), width: s * 1.4, height: s * 0.22), _f(col));
  c.drawOval(
      Rect.fromCenter(center: Offset(x + s * 0.3, y - s * 0.07), width: s * 0.8, height: s * 0.2),
      _f(col));
  c.drawOval(
      Rect.fromCenter(center: Offset(x - s * 0.35, y + s * 0.05), width: s * 0.7, height: s * 0.16),
      _f(col));
}

// ─────────────────────────── sols ───────────────────────────

void _paintGround(Canvas canvas, BoardGeometry g, int i) {
  final biome = _biomes[_regionOf(i)];
  final top = g.bandTop(i);
  final bottom = g.bandBottom(i);
  const fade = 20.0;
  final fadeBottom = i != 6;
  final bandH = bottom - top;
  final total = bandH + fade + (fadeBottom ? fade : 0.0);
  final rect = Rect.fromLTRB(0, top - fade, g.width, top - fade + total);

  final colors = <Color>[biome.colors.first.withAlpha(0)];
  final stops = <double>[0.0];
  for (var k = 0; k < biome.colors.length; k++) {
    colors.add(biome.colors[k]);
    stops.add((fade + biome.stops[k] * bandH) / total);
  }
  if (fadeBottom) {
    colors.add(biome.colors.last.withAlpha(0));
    stops.add(1.0);
  }
  canvas.drawRect(
    rect,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
        stops: stops,
      ).createShader(rect),
  );
}

void _terraces(Canvas c, double w, double top, double bottom, int n,
    List<Color> cols) {
  final height = bottom - top;
  for (var k = 0; k < n; k++) {
    final y0 = top + height * k / n;
    final edge = Path()..moveTo(0, y0 + _wave(0, k));
    for (var x = 8.0; x <= w + 8; x += 8) {
      edge.lineTo(x, y0 + _wave(x, k));
    }
    final fill = Path()..addPath(edge, Offset.zero);
    fill.lineTo(w + 8, bottom + 10);
    fill.lineTo(0, bottom + 10);
    fill.close();
    c.drawPath(fill, _f(cols[k % cols.length]));
    // talus : ombre sous l'arête, lumière sur l'arête (effet de relief)
    c.drawPath(
        edge.shift(const Offset(0, 3)),
        Paint()
          ..color = const Color(0x55103A10)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);
    c.drawPath(
        edge,
        Paint()
          ..color = const Color(0x77E8FFB8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
  }
}

void _paintGroundDetails(Canvas canvas, BoardGeometry g, int i) {
  final region = _regionOf(i);
  final top = i == 0 ? g.horizon + 6 : g.gapTop(i);
  final bottom = g.gapBottom(i);
  final rnd = Random(500 + i * 17);
  final w = g.width;

  switch (region) {
    case 0:
      _terraces(canvas, w, top + 14, bottom + 4, i == 6 ? 2 : 3, const [
        Color(0xFF8CCB4E),
        Color(0xFFD9C45A),
        Color(0xFF6FB04A),
      ]);
      break;
    case 1:
      // brume matinale entre les arbres
      for (var k = 0; k < 3; k++) {
        final y = top + (bottom - top) * (0.25 + 0.3 * k);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(w * (0.25 + 0.25 * k), y),
                width: w * 0.55,
                height: 16),
            _f(const Color(0x2EFFFFFF)));
      }
      break;
    case 2:
      for (var k = 0; k < 16; k++) {
        final x = rnd.nextDouble() * w;
        final y = top + rnd.nextDouble() * (bottom - top);
        canvas.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: 10, height: 3),
            _f(const Color(0x33803A10)));
      }
      break;
    case 3:
      for (var k = 0; k < 14; k++) {
        final x = rnd.nextDouble() * w;
        final y = top + rnd.nextDouble() * (bottom - top);
        canvas.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: 14, height: 4),
            _f(const Color(0x335A7A4A)));
      }
      break;
    case 4:
      final shoreY = bottom - 14;
      final shore = _wavePath(w, shoreY, 3, 0.05, 0.0);
      final beach = Path()..addPath(shore, Offset.zero);
      beach.lineTo(w + 8, bottom + 8);
      beach.lineTo(0, bottom + 8);
      beach.close();
      canvas.drawPath(beach, _f(const Color(0xFFF2E1B0)));
      canvas.drawPath(
          shore.shift(const Offset(0, -2)),
          Paint()
            ..color = const Color(0xCCFFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
      final spark = Paint()
        ..color = const Color(0x77FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      for (var k = 0; k < 24; k++) {
        final x = rnd.nextDouble() * w;
        final y = top + 4 + rnd.nextDouble() * (shoreY - top - 12);
        canvas.drawLine(Offset(x, y), Offset(x + 7, y), spark);
      }
      break;
    case 5:
      for (var k = 0; k < 10; k++) {
        final x = rnd.nextDouble() * w;
        final y = top + 10 + rnd.nextDouble() * (bottom - top - 10);
        drawTuft(canvas, x, y, 7, const Color(0xFF8A5A22));
      }
      break;
  }
}

// ─────────────────────────── objets de décor ───────────────────────────

void _paintGapObjects(Canvas canvas, BoardGeometry g, int i) {
  if (i == 6) return; // la zone du garage est occupée par le bâtiment
  final region = _regionOf(i);
  final rnd = Random(1000 + i * 31);
  final top = i == 0 ? g.horizon + 12 : g.gapTop(i) + 18.0;
  final bottom = g.gapBottom(i);
  final left = g.margin + 34.0;
  final right = g.width - g.margin - 34.0;
  final items = <_Item>[];

  void add(double y, void Function() fn) => items.add(_Item(y, fn));

  switch (region) {
    case 0:
      {
        final nHouse = i == 6 ? 2 : 3;
        for (final x in _spread(rnd, nHouse, left, right)) {
          final by = _baseY(rnd, top, bottom);
          final h = _clampD((by - top) * 1.05, 34.0, 68.0);
          add(by, () => drawHouse(canvas, x, by, h));
        }
        for (final x in _spread(rnd, i == 6 ? 2 : 4, left, right)) {
          final by = _baseY(rnd, top, bottom);
          final h = _clampD((by - top) * 1.1, 34.0, 70.0);
          add(by, () => drawEucalyptus(canvas, x, by, h));
        }
      }
      break;
    case 1:
      {
        for (final x in _spread(rnd, 3, left, right)) {
          final by = _baseY(rnd, top, bottom);
          final h = _clampD((by - top) * 1.1, 36.0, 72.0);
          add(by, () => drawRainTree(canvas, x, by, h));
        }
        for (final x in _spread(rnd, 2, left, right)) {
          final by = _baseY(rnd, top, bottom);
          final h = _clampD((by - top) * 1.0, 34.0, 64.0);
          add(by, () => drawRavinala(canvas, x, by, h));
        }
        for (final x in _spread(rnd, 5, left - 10, right + 10)) {
          final by = _baseY(rnd, top + 20, bottom);
          add(by, () => drawFern(canvas, x, by, 12));
        }
      }
      break;
    case 2:
      {
        final xs = _spread(rnd, 3, left, right);
        for (var k = 0; k < xs.length; k++) {
          final x = xs[k];
          final by = _baseY(rnd, top + 8, bottom);
          final h = _clampD((by - top) * 0.95, 34.0, 66.0);
          final fw = h * (1.0 + 0.4 * rnd.nextDouble());
          if (k == 1) {
            add(by, () => drawArch(canvas, x, by, h, fw * 1.15));
          } else {
            add(by, () => drawMesa(canvas, x, by, h, fw));
          }
        }
        for (final x in _spread(rnd, 2, left, right)) {
          final by = _baseY(rnd, top + 14, bottom);
          final h = _clampD((by - top) * 0.95, 30.0, 58.0);
          final lean = rnd.nextBool() ? 0.3 : -0.3;
          add(by, () => drawPalm(canvas, x, by, h, lean));
        }
        // un maki catta perché sur un rocher, au premier plan
        final lx = right - 24;
        final lby = bottom - 2;
        add(lby, () {
          drawRock(canvas, lx, lby, 34, 14);
          drawLemur(canvas, lx + 2, lby - 10, 30);
        });
      }
      break;
    case 3:
      {
        for (final x in _spread(rnd, 4, left, right)) {
          final by = _baseY(rnd, top + 10, bottom);
          final h = _clampD((by - top) * 1.05, 34.0, 68.0);
          final hs = <double>[
            for (var k = 0; k < 6; k++)
              (0.45 + 0.55 * rnd.nextDouble()) * (1 - ((k - 2.5).abs() / 2.5) * 0.35)
          ];
          add(by, () => drawTsingy(canvas, x, by, h, hs));
        }
        for (final x in _spread(rnd, 5, left - 10, right + 10)) {
          final by = _baseY(rnd, top + 22, bottom);
          add(by, () => drawBush(canvas, x, by, 7,
              const Color(0xFF3E6B3A), const Color(0xFF5E9A4E)));
        }
      }
      break;
    case 4:
      {
        final shoreY = bottom - 14;
        // îlot lointain
        add(top + 6, () => drawIsland(canvas, left + 20, top + 22, 70));
        // boutres
        add(top + 40, () => drawDhow(canvas, right - 70, top + 46, 36, const Color(0xFFFFF4E0)));
        add(top + 30, () => drawDhow(canvas, left + 110, top + 34, 26, const Color(0xFFF2994A)));
        // cocotiers sur la plage
        for (final x in _spread(rnd, 3, left - 10, right + 10)) {
          final by = shoreY + 2 + rnd.nextDouble() * 8;
          final h = _clampD(40 + rnd.nextDouble() * 18, 36.0, 60.0);
          final lean = rnd.nextBool() ? 0.35 : -0.35;
          add(by, () => drawPalm(canvas, x, by, h, lean));
        }
      }
      break;
    case 5:
      {
        final topBase = g.horizon + 14;
        // baobabs lointains (petits) puis proches (grands) : effet de profondeur
        final xs = _spread(rnd, 6, left - 14, right + 14);
        for (final x in xs) {
          final by = _baseY(rnd, topBase, bottom);
          final reach = by - 4;
          final h = _clampD(reach * 0.85, 34.0, 118.0);
          add(by, () => drawBaobab(canvas, x, by, h));
        }
        for (final x in _spread(rnd, 4, left, right)) {
          final by = _baseY(rnd, topBase + 8, bottom);
          add(by, () => drawTuft(canvas, x, by, 9, const Color(0xFF7A4A18)));
        }
      }
      break;
  }

  items.sort((a, b) => a.y.compareTo(b.y));
  for (final it in items) {
    it.draw();
  }
}

// ─────────────────────────── garage ───────────────────────────

/// Le garage est dessiné après la route : elle semble en sortir.
void paintGarage(Canvas canvas, BoardGeometry g) {
  final y = g.rowY(6);
  final left = g.margin - 6;
  final right = g.width - g.margin + 6;
  final floorTop = y - g.roadHalf * 0.9;
  final floorBottom = y + g.roadHalf + 6;
  final wallTop = floorTop - 44;

  // ombre portée du bâtiment
  canvas.drawRRect(
      RRect.fromLTRBR(left + 4, wallTop + 10, right + 4, floorBottom + 8,
          const Radius.circular(10)),
      _f(const Color(0x44000000)));

  // mur du fond
  canvas.drawRect(Rect.fromLTRB(left, wallTop, right, floorTop + 2),
      _f(const Color(0xFFB98355)));
  // sol
  canvas.drawRRect(
      RRect.fromLTRBR(left, floorTop, right, floorBottom, const Radius.circular(8)),
      _f(const Color(0xFF55565E)));
  canvas.drawRRect(
      RRect.fromLTRBR(left, floorTop, right, floorBottom, const Radius.circular(8)),
      Paint()
        ..color = const Color(0x66FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);

  // 4 baies (une par bus)
  for (var k = 0; k < 4; k++) {
    final cx = g.cell(0, slot: k).dx;
    canvas.drawRRect(
        RRect.fromLTRBAndCorners(cx - g.cellW * 1.3, wallTop + 8, cx + g.cellW * 1.3,
            floorTop + 2,
            topLeft: const Radius.circular(10), topRight: const Radius.circular(10)),
        _f(const Color(0xFF3D2B22)));
    canvas.drawRect(
        Rect.fromLTRB(cx - g.cellW * 1.3, floorTop - 3, cx + g.cellW * 1.3, floorTop + 2),
        _f(const Color(0xFFE8C94A)));
  }

  // toit en tôle ondulée
  final roof = Path()
    ..moveTo(left - 6, wallTop + 4)
    ..lineTo(left + 12, wallTop - 14)
    ..lineTo(right - 12, wallTop - 14)
    ..lineTo(right + 6, wallTop + 4)
    ..close();
  canvas.drawPath(roof, _f(const Color(0xFFC0452F)));
  final rib = Paint()
    ..color = const Color(0x33000000)
    ..strokeWidth = 1;
  for (var x = left + 14; x < right - 12; x += 9) {
    canvas.drawLine(Offset(x, wallTop - 13), Offset(x - 3, wallTop + 3), rib);
  }
  canvas.drawRect(Rect.fromLTRB(left - 6, wallTop + 1, right + 6, wallTop + 6),
      _f(const Color(0xFF8F2F20)));

  // enseigne
  final sign = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(g.width / 2, wallTop - 24), width: 118, height: 22),
      const Radius.circular(11));
  canvas.drawRRect(sign, _f(const Color(0xFF0F6B4F)));
  canvas.drawRRect(
      sign,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
  final tp = TextPainter(
    text: TextSpan(
      text: '${L10n.tr('garage')} · A',
      style: const TextStyle(
          fontSize: 12, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset(g.width / 2 - tp.width / 2, wallTop - 24 - tp.height / 2));
}
