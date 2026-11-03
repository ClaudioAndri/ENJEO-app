import 'dart:math';

import 'package:flutter/material.dart';

import '../game_logic/engine.dart';
import '../l10n/strings.dart';
import 'board_geometry.dart';
import 'scenery.dart';

Paint _f(Color c) => Paint()..color = c;

/// Couche statique du plateau : décor, route en relief, bornes 3D, PRA,
/// panneaux d'étape et arrivée G. Les bus sont ajoutés par-dessus (widgets).
class BoardPainter extends CustomPainter {
  BoardPainter(this.g);
  final BoardGeometry g;

  @override
  void paint(Canvas canvas, Size size) {
    paintScenery(canvas, g);
    _paintRoad(canvas);
    paintGarage(canvas, g);
    for (var pos = goalPos; pos >= 1; pos--) {
      _paintBorne(canvas, pos);
    }
    _paintLabels(canvas);
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) => old.g.width != g.width;

  // ───────────────────── route ─────────────────────

  Path _roadPath() {
    final path = Path();
    final start = g.cell(1);
    path.moveTo(start.dx, g.rowY(6));
    path.lineTo(start.dx, start.dy);
    for (var r = 0; r < segmentCount; r++) {
      final end = g.cell(r * segLen + segLen);
      path.lineTo(end.dx, end.dy);
      if (r < segmentCount - 1) {
        final next = g.cell((r + 1) * segLen + 1);
        path.lineTo(next.dx, next.dy);
      }
    }
    return path;
  }

  void _paintRoad(Canvas canvas) {
    final path = _roadPath();
    final roadW = g.roadHalf * 2;

    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // ombre portée floue : la route semble surélevée
    canvas.save();
    canvas.translate(0, 8);
    canvas.drawPath(
      path,
      stroke(const Color(0x66000000), roadW + 8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.restore();

    // tranche de la route (épaisseur)
    canvas.save();
    canvas.translate(0, 5);
    canvas.drawPath(path, stroke(const Color(0xFF3B2F2A), roadW + 6));
    canvas.restore();

    // accotement en terre, puis bitume
    canvas.drawPath(path, stroke(const Color(0xFFC9AB80), roadW + 6));
    canvas.drawPath(path, stroke(const Color(0xFF4D4F58), roadW));
    canvas.drawPath(path, stroke(const Color(0x22FFFFFF), roadW * 0.45));

    // ligne médiane pointillée
    final dash = stroke(const Color(0x66FFFFFF), 1.6)..strokeCap = StrokeCap.butt;
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        final next = min(d + 6.0, m.length);
        canvas.drawPath(m.extractPath(d, next), dash);
        d += 14.0;
      }
    }
  }

  // ───────────────────── bornes ─────────────────────

  void _cylinder(Canvas c, Offset ctr, double rx, double ry, double depth,
      Color top, Color side) {
    // ombre au sol
    c.drawOval(
        Rect.fromCenter(
            center: ctr.translate(2, depth + 2), width: rx * 2.1, height: ry * 2.1),
        _f(const Color(0x55000000)));
    // flanc du cylindre
    c.drawOval(
        Rect.fromCenter(
            center: ctr.translate(0, depth), width: rx * 2, height: ry * 2),
        _f(side));
    c.drawRect(Rect.fromLTRB(ctr.dx - rx, ctr.dy, ctr.dx + rx, ctr.dy + depth), _f(side));
    // dessus
    c.drawOval(
        Rect.fromCenter(center: ctr, width: rx * 2, height: ry * 2), _f(top));
    c.drawOval(
        Rect.fromCenter(center: ctr, width: rx * 2, height: ry * 2),
        Paint()
          ..color = const Color(0x55FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  void _text(Canvas c, String t, Offset center, double size, Color color,
      {FontWeight weight = FontWeight.w800, double spacing = 0}) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(
            fontSize: size,
            color: color,
            fontWeight: weight,
            letterSpacing: spacing),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _paintBorne(Canvas canvas, int pos) {
    final c = g.cell(pos);
    final local = (pos - 1) % segLen + 1;
    final r = (pos - 1) ~/ segLen;
    final rx = g.cellW * 0.4;
    final ry = rx * 0.82;

    if (pos == goalPos) {
      _paintGoal(canvas, c);
    } else if (isPra(pos)) {
      _cylinder(canvas, c, rx, ry, 4, const Color(0xFFE5383B), const Color(0xFF8F1D22));
      _text(canvas, '!', c, rx * 1.3, Colors.white, weight: FontWeight.w900);
      // panneau de police dressé au-dessus de la borne
      final pole = Paint()
        ..color = const Color(0xFF5A5A62)
        ..strokeWidth = 2;
      canvas.drawLine(c.translate(0, -2), c.translate(0, -26), pole);
      final sign = c.translate(0, -33);
      canvas.drawCircle(sign.translate(1, 2), 10, _f(const Color(0x55000000)));
      canvas.drawCircle(sign, 10, _f(const Color(0xFFE5383B)));
      canvas.drawCircle(
          sign,
          10,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8);
      _text(canvas, 'PRA', sign, 7.5, Colors.white, weight: FontWeight.w900);
      // gyrophare
      canvas.drawCircle(sign.translate(-5, -13), 2.6, _f(const Color(0xFF2D7DFF)));
      canvas.drawCircle(sign.translate(5, -13), 2.6, _f(const Color(0xFFFF3B3B)));
    } else if (local == segLen) {
      _cylinder(canvas, c, rx * 1.12, ry * 1.12, 4, const Color(0xFFF28C28),
          const Color(0xFFA85A12));
      _text(canvas, 'BCDEFG'[r], c, rx * 1.35, Colors.white, weight: FontWeight.w900);
    } else {
      _cylinder(canvas, c, rx, ry, 3.5, const Color(0xFFFFF4DE), const Color(0xFFC9B48E));
      _text(canvas, '$local', c, rx * 1.05, const Color(0xFF3B3226));
    }
  }

  void _paintGoal(Canvas canvas, Offset c) {
    final rx = g.cellW * 0.52;
    final ry = rx * 0.82;
    // halo doré
    canvas.drawCircle(
      c,
      rx * 2.4,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x99FFE08A), Color(0x00FFE08A)],
        ).createShader(Rect.fromCircle(center: c, radius: rx * 2.4)),
    );
    _cylinder(canvas, c, rx, ry, 5, const Color(0xFFFFC145), const Color(0xFFB07A10));
    _text(canvas, 'G', c, rx * 1.3, const Color(0xFF5A3A00), weight: FontWeight.w900);
    // mât et drapeau à damier
    final pole = c.translate(rx * 0.7, -4);
    canvas.drawLine(pole, pole.translate(0, -50),
        Paint()
          ..color = const Color(0xFFEEEEEE)
          ..strokeWidth = 2.4);
    const cols = 4;
    const rows = 3;
    const sq = 6.0;
    final origin = pole.translate(1.2, -50);
    for (var ix = 0; ix < cols; ix++) {
      for (var iy = 0; iy < rows; iy++) {
        canvas.drawRect(
          Rect.fromLTWH(origin.dx + ix * sq, origin.dy + iy * sq + sin(ix * 0.9) * 1.2, sq, sq),
          _f((ix + iy).isEven ? const Color(0xFF1B1B1B) : Colors.white),
        );
      }
    }
  }

  // ───────────────────── étiquettes d'étape ─────────────────────

  void _paintLabels(Canvas canvas) {
    for (var r = 0; r < segmentCount; r++) {
      final row = 5 - r;
      final label =
          '${'ABCDEF'[r]} → ${'BCDEFG'[r]}  ·  ${L10n.tr('region_$r')}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
              fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w800),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // En haut de la bande de décor de l'étape (le décor est au-dessus de sa route).
      final cy = g.gapTop(row) + 8;
      final pill = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(g.width / 2, cy), width: tp.width + 22, height: 17),
        const Radius.circular(9),
      );
      canvas.drawRRect(pill.shift(const Offset(0, 2)), _f(const Color(0x44000000)));
      canvas.drawRRect(pill, _f(const Color(0xCC12302A)));
      canvas.drawRRect(
          pill,
          Paint()
            ..color = const Color(0x66FFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
      tp.paint(canvas, Offset(g.width / 2 - tp.width / 2, cy - tp.height / 2));
    }
  }
}
