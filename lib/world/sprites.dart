import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models.dart';
import '../widgets/bus_icon.dart';

/// Image pré-dessinée d'un élément de décor (rendue une seule fois, à 2x).
/// Le point d'ancrage (pied de l'objet) est en bas au centre, 3 px au-dessus du bord.
class Sprite {
  const Sprite(this.image, this.w, this.h);
  final ui.Image image;
  final double w;
  final double h;
}

typedef _Draw = void Function(Canvas c);

class _Def {
  const _Def(this.key, this.w, this.h, this.draw);
  final String key;
  final double w;
  final double h;
  final _Draw draw;
}

class Sprites {
  static final Map<String, Sprite> _map = <String, Sprite>{};
  static bool ready = false;
  static Future<void>? _loading;

  static Sprite? get(String key) => _map[key];

  static Future<void> ensureLoaded() {
    return _loading ??= _load();
  }

  static Future<void> _load() async {
    for (final d in _defs()) {
      try {
        _map[d.key] = await _render(d);
      } catch (_) {
        // Un sprite raté n'empêche pas de jouer : il sera simplement absent.
      }
    }
    ready = true;
  }

  static Future<Sprite> _render(_Def d) async {
    const k = 2.0;
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    c.scale(k, k);
    c.translate(d.w / 2, d.h - 3);
    d.draw(c);
    final pic = rec.endRecording();
    final img = await pic.toImage((d.w * k).ceil(), (d.h * k).ceil());
    return Sprite(img, d.w, d.h);
  }

  static List<_Def> _defs() {
    final defs = <_Def>[
      const _Def('baobab', 100, 100, drawBaobab),
      const _Def('palm', 76, 96, _drawPalm),
      const _Def('ravenala', 84, 68, _drawRavenala),
      const _Def('forestTree', 66, 82, _drawForestTree),
      const _Def('fern', 40, 24, _drawFern),
      const _Def('bush', 36, 24, _drawBush),
      const _Def('rock', 32, 22, _drawRock),
      _Def('house', 44, 56, (c) => _drawHouse(c, const Color(0xFFB4513A), const Color(0xFF8C3C2B), const Color(0xFF5C4033))),
      _Def('house2', 44, 56, (c) => _drawHouse(c, const Color(0xFFEBD8AE), const Color(0xFFC9B58A), const Color(0xFFC0572B))),
      const _Def('eucalyptus', 30, 80, _drawEucalyptus),
      const _Def('zebu', 64, 40, _drawZebu),
      const _Def('mesa', 84, 60, _drawMesa),
      const _Def('arch', 100, 70, _drawArch),
      const _Def('lemur', 44, 54, _drawLemur),
      const _Def('tsingy1', 76, 88, _drawTsingy1),
      const _Def('tsingy2', 56, 66, _drawTsingy2),
      const _Def('pirogue', 72, 54, _drawPirogue),
      const _Def('grass', 30, 18, _drawGrass),
      const _Def('pra', 56, 64, _drawPra),
      const _Def('finish', 128, 92, _drawFinish),
      const _Def('garage', 360, 84, _drawGarage),
      const _Def('sun', 180, 180, _drawSun),
    ];
    for (var i = 0; i < 7; i++) {
      final letter = 'ABCDEFG'[i];
      defs.add(_Def('sign_$letter', 34, 52, (c) => _drawSign(c, letter, i == 0)));
    }
    for (var r = 0; r < 6; r++) {
      defs.add(_Def('ridge_$r', 512, 34, (c) => _drawRidge(c, r)));
    }
    for (var i = 0; i < busColors.length; i++) {
      final bc = busColors[i];
      defs.add(_Def('bus_$i', 60, 46, (c) {
        c.save();
        c.translate(-30, -43);
        paintTaxiBrousse(c, const Size(60, 43), bc.main, bc.dark);
        c.restore();
      }));
    }
    return defs;
  }
}

// ---------------------------------------------------------------------------
// Petits outils de dessin
// ---------------------------------------------------------------------------

Paint _fill(Color c) => Paint()..color = c;

Paint _line(Color c, double w, {StrokeCap cap = StrokeCap.round}) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = cap;

Paint _hGrad(Rect r, List<Color> colors, [List<double>? stops]) => Paint()
  ..shader = LinearGradient(colors: colors, stops: stops).createShader(r);

Paint _vGrad(Rect r, List<Color> colors) => Paint()
  ..shader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: colors,
  ).createShader(r);

void _text(Canvas c, String t, Offset center, double size, Color color,
    {FontWeight weight = FontWeight.w900}) {
  final tp = TextPainter(
    text: TextSpan(
      text: t,
      style: TextStyle(fontSize: size, color: color, fontWeight: weight),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
}

/// Feuille en forme de lentille, de [s] vers un point [len] plus loin.
void _leaf(Canvas c, Offset s, double ang, double len, Color col) {
  final dir = Offset(cos(ang), sin(ang));
  final perp = Offset(-dir.dy, dir.dx);
  final tip = s + dir * len + Offset(0, len * 0.28);
  final mid = s + dir * (len * 0.5) + Offset(0, -len * 0.12);
  final path = Path()
    ..moveTo(s.dx, s.dy)
    ..quadraticBezierTo(mid.dx + perp.dx * len * 0.13,
        mid.dy + perp.dy * len * 0.13, tip.dx, tip.dy)
    ..quadraticBezierTo(mid.dx - perp.dx * len * 0.13,
        mid.dy - perp.dy * len * 0.13, s.dx, s.dy);
  c.drawPath(path, _fill(col));
}

// ---------------------------------------------------------------------------
// Végétation
// ---------------------------------------------------------------------------

/// Baobab (Adansonia grandidieri) : tronc en bouteille, couronne aplatie.
/// Si [flat] est fourni, dessine une simple silhouette de cette couleur.
void drawBaobab(Canvas c, {Color? flat}) {
  final trunk = Path()
    ..moveTo(-17, 0)
    ..cubicTo(-20, -14, -12, -30, -9, -50)
    ..lineTo(-8, -62)
    ..lineTo(8, -62)
    ..lineTo(9, -50)
    ..cubicTo(12, -30, 20, -14, 17, 0)
    ..close();
  const trunkRect = Rect.fromLTRB(-20, -62, 20, 0);
  if (flat != null) {
    c.drawPath(trunk, _fill(flat));
  } else {
    c.drawPath(
      trunk,
      _hGrad(
        trunkRect,
        const [Color(0xFF6E4E3E), Color(0xFFA27B63), Color(0xFFCBA78E)],
        const [0.0, 0.55, 1.0],
      ),
    );
    final g = _line(const Color(0x33000000), 1.2);
    c.drawPath(
        Path()
          ..moveTo(-8, -4)
          ..quadraticBezierTo(-9, -30, -5, -58),
        g);
    c.drawPath(
        Path()
          ..moveTo(2, -2)
          ..quadraticBezierTo(4, -28, 3, -58),
        g);
    c.drawPath(
        Path()
          ..moveTo(11, -4)
          ..quadraticBezierTo(10, -26, 6, -56),
        g);
  }
  final branch = _line(flat ?? const Color(0xFF7A5A48), 5);
  const tips = [
    Offset(-32, -76),
    Offset(-15, -85),
    Offset(4, -90),
    Offset(22, -83),
    Offset(35, -72),
  ];
  for (final t in tips) {
    c.drawLine(const Offset(0, -60), t, branch);
  }
  for (final t in tips) {
    final leaf = Rect.fromCenter(center: t + const Offset(0, -3), width: 28, height: 13);
    c.drawOval(leaf, _fill(flat ?? const Color(0xFF2F7A3B)));
    if (flat == null) {
      c.drawOval(
        leaf.shift(const Offset(-2, -2)).deflate(2.5),
        _fill(const Color(0xFF55AA52)),
      );
    }
  }
}

void _drawPalm(Canvas c) {
  final trunk = Path()
    ..moveTo(-3, 0)
    ..quadraticBezierTo(9, -34, 4, -64);
  c.drawPath(trunk, _line(const Color(0xFF8B6B4E), 7, cap: StrokeCap.butt));
  c.drawPath(trunk, _line(const Color(0x33000000), 1.4, cap: StrokeCap.butt));
  const top = Offset(4, -64);
  const angles = [-2.9, -2.4, -1.9, -1.2, -0.7, -0.25, 0.2];
  for (var i = 0; i < angles.length; i++) {
    _leaf(c, top, angles[i], 31,
        i.isEven ? const Color(0xFF2E8B3E) : const Color(0xFF45A64E));
  }
  c.drawCircle(top + const Offset(-3, 3), 3.2, _fill(const Color(0xFF5B3A1E)));
  c.drawCircle(top + const Offset(3, 4), 3.2, _fill(const Color(0xFF5B3A1E)));
}

/// Arbre du voyageur (ravenala) : éventail de larges feuilles.
void _drawRavenala(Canvas c) {
  c.drawPath(
    Path()
      ..moveTo(-2, 0)
      ..quadraticBezierTo(0, -14, 0, -24),
    _line(const Color(0xFF8B6B4E), 5, cap: StrokeCap.butt),
  );
  const base = Offset(0, -22);
  for (var i = 0; i < 9; i++) {
    final ang = -pi + 0.35 + i * (pi - 0.7) / 8;
    final dir = Offset(cos(ang), sin(ang));
    final stalk = base + dir * 18;
    c.drawLine(base, stalk, _line(const Color(0xFF3F8F43), 2.4));
    c.save();
    c.translate(stalk.dx, stalk.dy);
    c.rotate(ang);
    c.drawOval(
      const Rect.fromLTWH(0, -5, 23, 10),
      _fill(i.isEven ? const Color(0xFF2E8B3E) : const Color(0xFF3FA24B)),
    );
    c.drawLine(Offset.zero, const Offset(23, 0), _line(const Color(0x66FFFFFF), 1));
    c.restore();
  }
}

void _drawForestTree(Canvas c) {
  c.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTRB(-4, -36, 4, 0),
      const Radius.circular(2),
    ),
    _fill(const Color(0xFF5B4030)),
  );
  c.drawCircle(const Offset(-14, -46), 15, _fill(const Color(0xFF1F6B3A)));
  c.drawCircle(const Offset(14, -48), 16, _fill(const Color(0xFF1F6B3A)));
  c.drawCircle(const Offset(0, -58), 19, _fill(const Color(0xFF2A8048)));
  c.drawCircle(const Offset(-4, -64), 11, _fill(const Color(0xFF3FA05C)));
  c.drawCircle(const Offset(10, -56), 7, _fill(const Color(0xFF3FA05C)));
  c.drawLine(const Offset(-10, -34), const Offset(-10, -20),
      _line(const Color(0xFF2E7D32), 1.2));
  c.drawLine(const Offset(9, -36), const Offset(9, -24),
      _line(const Color(0xFF2E7D32), 1.2));
}

void _drawFern(Canvas c) {
  for (var i = 0; i < 7; i++) {
    final a = -pi + 0.3 + i * (pi - 0.6) / 6;
    final e = Offset(cos(a) * 16, sin(a) * 14 - 2);
    c.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(cos(a) * 8, sin(a) * 16, e.dx, e.dy),
      _line(i.isEven ? const Color(0xFF2E8B3E) : const Color(0xFF4DB65A), 2.6),
    );
  }
}

void _drawBush(Canvas c) {
  c.drawCircle(const Offset(-8, -7), 8, _fill(const Color(0xFF2C7A3F)));
  c.drawCircle(const Offset(8, -7), 8, _fill(const Color(0xFF2C7A3F)));
  c.drawCircle(const Offset(0, -11), 9.5, _fill(const Color(0xFF3C9650)));
  c.drawCircle(const Offset(-2, -14), 4.5, _fill(const Color(0xFF59B368)));
}

void _drawRock(Canvas c) {
  final p = Path()
    ..moveTo(-13, 0)
    ..lineTo(-11, -10)
    ..lineTo(-3, -18)
    ..lineTo(8, -15)
    ..lineTo(14, -6)
    ..lineTo(12, 0)
    ..close();
  c.drawPath(p, _hGrad(const Rect.fromLTRB(-14, -18, 14, 0), const [Color(0xFFB9B4A8), Color(0xFF7D786E)]));
  c.drawPath(
    Path()
      ..moveTo(-3, -18)
      ..lineTo(8, -15)
      ..lineTo(2, -8)
      ..close(),
    _fill(const Color(0x40FFFFFF)),
  );
}

void _drawGrass(Canvas c) {
  for (var i = 0; i < 7; i++) {
    final x = -10.0 + i * 3.4;
    final lean = (i - 3) * 1.6;
    c.drawPath(
      Path()
        ..moveTo(x, 0)
        ..quadraticBezierTo(x + lean * 0.4, -8, x + lean, -14 + (i % 3) * 2.0),
      _line(i.isEven ? const Color(0xFFB8862B) : const Color(0xFF8A6420), 1.8),
    );
  }
}

void _drawEucalyptus(Canvas c) {
  c.drawPath(
    Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-3, -28, 2, -54),
    _line(const Color(0xFFCFC7B8), 3.2, cap: StrokeCap.butt),
  );
  c.drawOval(Rect.fromCenter(center: const Offset(-3, -56), width: 14, height: 26), _fill(const Color(0xFF5E9E85)));
  c.drawOval(Rect.fromCenter(center: const Offset(6, -62), width: 13, height: 28), _fill(const Color(0xFF7DB79E)));
  c.drawOval(Rect.fromCenter(center: const Offset(0, -68), width: 12, height: 22), _fill(const Color(0xFF6AAA90)));
}

// ---------------------------------------------------------------------------
// Hautes Terres : maisons de briques, zébu
// ---------------------------------------------------------------------------

void _drawHouse(Canvas c, Color wall, Color side, Color roof) {
  // façade et mur latéral
  c.drawRect(const Rect.fromLTRB(-15, -30, 9, 0), _fill(wall));
  c.drawPath(
    Path()
      ..moveTo(9, -30)
      ..lineTo(16, -27)
      ..lineTo(16, 3)
      ..lineTo(9, 0)
      ..close(),
    _fill(side),
  );
  // toit à deux pans
  c.drawPath(
    Path()
      ..moveTo(-18, -29)
      ..lineTo(-3, -46)
      ..lineTo(12, -29)
      ..close(),
    _fill(roof),
  );
  c.drawPath(
    Path()
      ..moveTo(-3, -46)
      ..lineTo(18, -27)
      ..lineTo(12, -29)
      ..close(),
    _fill(Color.lerp(roof, Colors.black, 0.3)!),
  );
  // fenêtres, balcon, porte
  final win = _fill(const Color(0xFFCFE9F6));
  c.drawRect(const Rect.fromLTRB(-11, -25, -5, -19), win);
  c.drawRect(const Rect.fromLTRB(-1, -25, 5, -19), win);
  c.drawRect(const Rect.fromLTRB(-11, -12, -5, -6), win);
  c.drawLine(const Offset(-14, -15), const Offset(8, -15), _line(Colors.white, 1.6, cap: StrokeCap.butt));
  c.drawRect(const Rect.fromLTRB(-1, -10, 5, 0), _fill(const Color(0xFF4A2F22)));
}

void _drawZebu(Canvas c) {
  // pattes
  final leg = _fill(const Color(0xFFD2BFA2));
  for (final x in [-14.0, -8.0, 8.0, 14.0]) {
    c.drawRect(Rect.fromLTWH(x - 1.8, -13, 3.6, 13), leg);
  }
  // corps, bosse, taches
  c.drawOval(Rect.fromCenter(center: const Offset(0, -21), width: 38, height: 19), _fill(const Color(0xFFEBDDC8)));
  c.drawCircle(const Offset(-9, -30), 6.5, _fill(const Color(0xFFEBDDC8)));
  c.drawOval(Rect.fromCenter(center: const Offset(5, -22), width: 11, height: 7), _fill(const Color(0xFF9B6B43)));
  // tête et cornes
  c.drawOval(Rect.fromCenter(center: const Offset(-22, -22), width: 14, height: 10), _fill(const Color(0xFFD9C7AB)));
  c.drawPath(
    Path()
      ..moveTo(-23, -26)
      ..quadraticBezierTo(-27, -34, -21, -34),
    _line(const Color(0xFF6B5A44), 1.8),
  );
  c.drawCircle(const Offset(-25, -23), 1.1, _fill(Colors.black));
  // queue
  c.drawLine(const Offset(18, -24), const Offset(22, -11), _line(const Color(0xFF8A6A48), 1.4));
}

// ---------------------------------------------------------------------------
// Isalo : mesas de grès, fenêtre, lémurien catta
// ---------------------------------------------------------------------------

void _drawMesa(Canvas c) {
  final left = Path()
    ..moveTo(-40, 0)
    ..lineTo(-36, -44)
    ..lineTo(-22, -52)
    ..lineTo(-4, -52)
    ..lineTo(-2, 0)
    ..close();
  final right = Path()
    ..moveTo(-2, 0)
    ..lineTo(-4, -52)
    ..lineTo(14, -54)
    ..lineTo(30, -46)
    ..lineTo(36, 0)
    ..close();
  c.drawPath(left, _vGrad(const Rect.fromLTRB(-40, -52, 0, 0), const [Color(0xFFE59655), Color(0xFFC9683A)]));
  c.drawPath(right, _vGrad(const Rect.fromLTRB(0, -54, 36, 0), const [Color(0xFFC25E33), Color(0xFF8A3B1E)]));
  for (var k = 1; k <= 5; k++) {
    final y = -k * 8.0;
    final xl = -40 + 4 * (-y) / 44;
    final xr = 36 - 6 * (-y) / 46;
    c.drawLine(
      Offset(xl + 1, y),
      Offset(xr - 1, y),
      _line(k.isEven ? const Color(0x33FFFFFF) : const Color(0x33000000), 1.6, cap: StrokeCap.butt),
    );
  }
  for (final x in [-26.0, -12.0, 10.0, 22.0]) {
    c.drawLine(Offset(x, -6), Offset(x + 1, -44), _line(const Color(0x22000000), 1.4, cap: StrokeCap.butt));
  }
}

void _drawArch(Canvas c) {
  final outer = Path()
    ..moveTo(-48, 0)
    ..lineTo(-46, -40)
    ..cubicTo(-40, -66, 40, -66, 46, -40)
    ..lineTo(48, 0)
    ..close();
  final hole = Path()
    ..moveTo(-16, 0)
    ..lineTo(-16, -22)
    ..arcTo(Rect.fromCenter(center: const Offset(0, -22), width: 32, height: 40), pi, pi, false)
    ..lineTo(16, 0)
    ..close();
  final p = Path()
    ..fillType = PathFillType.evenOdd
    ..addPath(outer, Offset.zero)
    ..addPath(hole, Offset.zero);
  c.drawPath(p, _vGrad(const Rect.fromLTRB(-48, -64, 48, 0), const [Color(0xFFE59655), Color(0xFFA6492A)]));
  for (var k = 1; k <= 5; k++) {
    final y = -k * 9.0;
    c.drawLine(
      Offset(-44 + k * 0.8, y),
      Offset(-18, y),
      _line(k.isEven ? const Color(0x33FFFFFF) : const Color(0x33000000), 1.6, cap: StrokeCap.butt),
    );
    c.drawLine(
      Offset(18, y),
      Offset(44 - k * 0.8, y),
      _line(k.isEven ? const Color(0x33FFFFFF) : const Color(0x33000000), 1.6, cap: StrokeCap.butt),
    );
  }
}

void _drawLemur(Canvas c) {
  // rocher
  c.drawPath(
    Path()
      ..moveTo(-16, 0)
      ..lineTo(-13, -8)
      ..lineTo(-2, -13)
      ..lineTo(11, -9)
      ..lineTo(15, 0)
      ..close(),
    _hGrad(const Rect.fromLTRB(-16, -13, 15, 0), const [Color(0xFFC8C2B4), Color(0xFF857F72)]),
  );
  // queue annelée
  final tail = Path()
    ..moveTo(6, -14)
    ..cubicTo(22, -12, 24, -34, 14, -44);
  for (final m in tail.computeMetrics()) {
    var d = 0.0;
    var i = 0;
    while (d < m.length) {
      final e = min(d + 4.0, m.length);
      c.drawPath(
        m.extractPath(d, e),
        _line(i.isEven ? const Color(0xFF2B2B2B) : const Color(0xFFF4F1EA), 4.6, cap: StrokeCap.butt),
      );
      d = e;
      i++;
    }
  }
  // corps, ventre, tête
  c.drawOval(Rect.fromCenter(center: const Offset(-2, -22), width: 14, height: 18), _fill(const Color(0xFFB8B2A7)));
  c.drawOval(Rect.fromCenter(center: const Offset(-3, -20), width: 8, height: 12), _fill(const Color(0xFFF2EFE8)));
  c.drawCircle(const Offset(-3, -35), 6.5, _fill(const Color(0xFFD0CBC0)));
  c.drawOval(Rect.fromCenter(center: const Offset(-3, -33), width: 7, height: 6), _fill(const Color(0xFFF7F5F0)));
  c.drawOval(Rect.fromCenter(center: const Offset(-6, -36), width: 4, height: 5), _fill(const Color(0xFF1E1E1E)));
  c.drawOval(Rect.fromCenter(center: const Offset(0, -36), width: 4, height: 5), _fill(const Color(0xFF1E1E1E)));
  c.drawCircle(const Offset(-3, -32), 1.2, _fill(const Color(0xFF1E1E1E)));
  c.drawCircle(const Offset(-8, -41), 2.4, _fill(const Color(0xFFD0CBC0)));
  c.drawCircle(const Offset(2, -41), 2.4, _fill(const Color(0xFFD0CBC0)));
}

// ---------------------------------------------------------------------------
// Tsingy de Bemaraha : aiguilles calcaires
// ---------------------------------------------------------------------------

void _spike(Canvas c, double x, double w, double h) {
  final tip = Offset(x + w * 0.08, -h);
  c.drawPath(
    Path()
      ..moveTo(x - w / 2, 0)
      ..lineTo(x - w * 0.22, -h * 0.55)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(x, 0)
      ..close(),
    _fill(const Color(0xFFC3C6BF)),
  );
  c.drawPath(
    Path()
      ..moveTo(x, 0)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(x + w * 0.24, -h * 0.5)
      ..lineTo(x + w / 2, 0)
      ..close(),
    _fill(const Color(0xFF8B8F88)),
  );
  c.drawLine(Offset(x - w * 0.1, -h * 0.35), Offset(x + w * 0.1, -h * 0.62), _line(const Color(0x33000000), 1.2, cap: StrokeCap.butt));
}

void _drawTsingy1(Canvas c) {
  _spike(c, -26, 16, 50);
  _spike(c, 24, 16, 44);
  _spike(c, 8, 18, 66);
  _spike(c, -10, 20, 84);
  _spike(c, -2, 12, 40);
  c.drawOval(Rect.fromCenter(center: const Offset(-24, -2), width: 20, height: 8), _fill(const Color(0xFF4C7A3E)));
  c.drawOval(Rect.fromCenter(center: const Offset(20, -2), width: 18, height: 7), _fill(const Color(0xFF5A8C48)));
}

void _drawTsingy2(Canvas c) {
  _spike(c, -14, 14, 46);
  _spike(c, 18, 12, 38);
  _spike(c, 2, 18, 62);
  c.drawOval(Rect.fromCenter(center: const Offset(-2, -2), width: 26, height: 7), _fill(const Color(0xFF4C7A3E)));
}

// ---------------------------------------------------------------------------
// Nosy Be : pirogue à balancier
// ---------------------------------------------------------------------------

void _drawPirogue(Canvas c) {
  // balancier (flotteur latéral)
  c.drawLine(const Offset(-6, -9), const Offset(-16, 4), _line(const Color(0xFF6B4A2B), 1.8));
  c.drawLine(const Offset(10, -9), const Offset(2, 4), _line(const Color(0xFF6B4A2B), 1.8));
  c.drawOval(Rect.fromCenter(center: const Offset(-8, 4), width: 36, height: 5), _fill(const Color(0xFFE8F2F4)));
  // coque
  c.drawPath(
    Path()
      ..moveTo(-30, -9)
      ..quadraticBezierTo(0, 3, 30, -11)
      ..lineTo(28, -15)
      ..quadraticBezierTo(0, -7, -28, -14)
      ..close(),
    _fill(const Color(0xFF8B5A2B)),
  );
  c.drawPath(
    Path()
      ..moveTo(-27, -12)
      ..quadraticBezierTo(0, -4, 27, -13),
    _line(const Color(0xFFF4F1EA), 1.6, cap: StrokeCap.butt),
  );
  // mât et voile latine
  c.drawLine(const Offset(2, -12), const Offset(2, -48), _line(const Color(0xFF5B3A1E), 1.8));
  c.drawPath(
    Path()
      ..moveTo(3, -48)
      ..lineTo(27, -17)
      ..lineTo(3, -17)
      ..close(),
    _fill(const Color(0xFFF28C28)),
  );
  c.drawPath(
    Path()
      ..moveTo(3, -38)
      ..lineTo(15, -17)
      ..lineTo(3, -17)
      ..close(),
    _fill(const Color(0x55FFFFFF)),
  );
  c.drawPath(
    Path()
      ..moveTo(1, -44)
      ..lineTo(-14, -17)
      ..lineTo(1, -17)
      ..close(),
    _fill(const Color(0xFFFFD166)),
  );
}

// ---------------------------------------------------------------------------
// Éléments de jeu : PRA, panneaux, arrivée, garage, soleil
// ---------------------------------------------------------------------------

void _drawPra(Canvas c) {
  // cabine
  c.drawRect(const Rect.fromLTRB(-22, -24, 2, 0), _fill(const Color(0xFF2F5FBF)));
  c.drawPath(
    Path()
      ..moveTo(2, -24)
      ..lineTo(8, -21)
      ..lineTo(8, 3)
      ..lineTo(2, 0)
      ..close(),
    _fill(const Color(0xFF1F3F85)),
  );
  c.drawRect(const Rect.fromLTRB(-25, -28, 10, -24), _fill(Colors.white));
  c.drawRect(const Rect.fromLTRB(-18, -19, -6, -9), _fill(const Color(0xFFBFE6FF)));
  // panneau PRA
  c.drawLine(const Offset(-11, -28), const Offset(-11, -44), _line(const Color(0xFF666666), 2));
  final board = RRect.fromRectAndRadius(const Rect.fromLTRB(-22, -57, 0, -43), const Radius.circular(3));
  c.drawRRect(board, _fill(const Color(0xFFD7263D)));
  c.drawRRect(board, _line(Colors.white, 1.2));
  _text(c, 'PRA', const Offset(-11, -50), 9.5, Colors.white);
  // policier
  c.drawRect(const Rect.fromLTRB(14, -22, 20, 0), _fill(const Color(0xFF1B2A4A)));
  c.drawCircle(const Offset(17, -26), 3.4, _fill(const Color(0xFFE0A87C)));
  c.drawRect(const Rect.fromLTRB(13, -31, 21, -28), _fill(const Color(0xFF1B2A4A)));
  c.drawLine(const Offset(20, -18), const Offset(26, -30), _line(const Color(0xFF1B2A4A), 2.2));
  c.drawCircle(const Offset(26, -33), 4.2, _fill(const Color(0xFFD7263D)));
  c.drawCircle(const Offset(26, -33), 4.2, _line(Colors.white, 1));
}

void _drawSign(Canvas c, String letter, bool isStart) {
  c.drawRect(const Rect.fromLTRB(-1.5, -30, 1.5, 0), _fill(const Color(0xFF7A7A7A)));
  final board = RRect.fromRectAndRadius(const Rect.fromLTRB(-14, -50, 14, -26), const Radius.circular(5));
  c.drawRRect(board, _fill(isStart ? const Color(0xFF2E9D5B) : const Color(0xFFF28C28)));
  c.drawRRect(board, _line(Colors.white, 1.6));
  _text(c, letter, const Offset(0, -38), 17, Colors.white);
}

void _drawFinish(Canvas c) {
  // piliers rayés
  for (final x in [-56.0, 46.0]) {
    for (var i = 0; i < 9; i++) {
      c.drawRect(
        Rect.fromLTWH(x, -72.0 + i * 8, 10, 8),
        _fill(i.isEven ? const Color(0xFFD7263D) : Colors.white),
      );
    }
  }
  // poutre à damier
  const cols = 16;
  const rows = 3;
  const bw = 116.0 / cols;
  const bh = 22.0 / rows;
  for (var r = 0; r < rows; r++) {
    for (var k = 0; k < cols; k++) {
      c.drawRect(
        Rect.fromLTWH(-58.0 + k * bw, -86.0 + r * bh, bw, bh),
        _fill((r + k).isEven ? Colors.black : Colors.white),
      );
    }
  }
  // médaillon G
  c.drawCircle(const Offset(0, -75), 14, _fill(const Color(0xFFF28C28)));
  c.drawCircle(const Offset(0, -75), 14, _line(Colors.white, 2));
  _text(c, 'G', const Offset(0, -75), 17, Colors.white);
}

void _drawGarage(Canvas c) {
  c.drawRect(const Rect.fromLTRB(-170, -46, 170, 0), _vGrad(const Rect.fromLTRB(-170, -46, 170, 0), const [Color(0xFFF0E2C2), Color(0xFFD9C9A4)]));
  c.drawPath(
    Path()
      ..moveTo(-176, -46)
      ..lineTo(-160, -62)
      ..lineTo(160, -62)
      ..lineTo(176, -46)
      ..close(),
    _fill(const Color(0xFF2C6E63)),
  );
  _text(c, 'GARAGE', const Offset(0, -54), 12, Colors.white);
  for (final x in [-135.0, -45.0, 45.0, 135.0]) {
    final door = RRect.fromRectAndCorners(
      Rect.fromLTRB(x - 33, -36, x + 33, 0),
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
    );
    c.drawRRect(door, _fill(const Color(0xFF3A3A3A)));
    c.drawRRect(door, _line(const Color(0xFFB9A57E), 2.4));
  }
}

void _drawSun(Canvas c) {
  const center = Offset(0, -88);
  c.drawCircle(
    center,
    90,
    Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF3C4), Color(0xBBFFC857), Color(0x00FFA040)],
        stops: [0.25, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 90)),
  );
  c.drawCircle(center, 34, _fill(const Color(0xFFFFE08A)));
}

// ---------------------------------------------------------------------------
// Lignes d'horizon propres à chaque paysage
// ---------------------------------------------------------------------------

void _drawRidge(Canvas c, int r) {
  final rnd = Random(900 + r);
  const half = 256.0;
  const h = 30.0;

  Path hills(double base, double amp, double f, double ph) {
    final p = Path()..moveTo(-half, 0);
    for (var x = -half; x <= half; x += 8) {
      p.lineTo(x, -(base + amp * (0.5 + 0.5 * sin(x * f + ph))));
    }
    p.lineTo(half, 0);
    p.close();
    return p;
  }

  switch (r) {
    case 0: // collines des Hautes Terres, petites maisons, Rova
      c.drawPath(hills(12, 10, 0.018, 1.0), _fill(const Color(0xFF86B96F)));
      c.drawPath(hills(6, 8, 0.027, 3.0), _fill(const Color(0xFF5FA04A)));
      for (var i = 0; i < 16; i++) {
        final hx = -230.0 + i * 29 + rnd.nextDouble() * 10;
        final hy = -(6 + 8 * (0.5 + 0.5 * sin(hx * 0.027 + 3.0))) + 1;
        c.drawRect(Rect.fromLTWH(hx, hy - 5, 5, 5), _fill(const Color(0xFFB4513A)));
        c.drawPath(
          Path()
            ..moveTo(hx - 1, hy - 5)
            ..lineTo(hx + 2.5, hy - 9)
            ..lineTo(hx + 6, hy - 5)
            ..close(),
          _fill(const Color(0xFF5C4033)),
        );
      }
      c.drawRect(const Rect.fromLTWH(70, -24, 20, 9), _fill(Color(0xFFEBD8AE)));
      c.drawPath(
        Path()
          ..moveTo(68, -24)
          ..lineTo(80, -31)
          ..lineTo(92, -24)
          ..close(),
        _fill(const Color(0xFF8C3C2B)),
      );
      break;
    case 1: // canopée de la forêt de l'Est
      c.drawPath(hills(14, 6, 0.04, 0.5), _fill(const Color(0xFF2B7A4B)));
      for (var i = 0; i < 26; i++) {
        final x = -250.0 + i * 20 + rnd.nextDouble() * 8;
        c.drawCircle(Offset(x, -8 - rnd.nextDouble() * 6), 9 + rnd.nextDouble() * 5,
            _fill(i.isEven ? const Color(0xFF1F6B3A) : const Color(0xFF2A8048)));
      }
      c.drawRect(const Rect.fromLTRB(-half, -h, half, 0), _vGrad(const Rect.fromLTRB(-half, -h, half, 0), const [Color(0x66FFFFFF), Color(0x00FFFFFF)]));
      break;
    case 2: // falaises de grès de l'Isalo
      final steps = Path()..moveTo(-half, 0);
      var sx = -half;
      while (sx < half) {
        final sw = 24.0 + rnd.nextDouble() * 34;
        final sh = 8.0 + rnd.nextDouble() * 20;
        steps.lineTo(sx, -sh);
        steps.lineTo(sx + sw, -sh);
        sx += sw;
      }
      steps.lineTo(half, 0);
      steps.close();
      c.drawPath(steps, _fill(const Color(0xFFB5532A)));
      c.drawRect(const Rect.fromLTRB(-half, -5, half, 0), _fill(const Color(0xFF8A3B1E)));
      break;
    case 3: // crête de tsingy
      final jag = Path()..moveTo(-half, 0);
      var jx = -half;
      while (jx < half) {
        final w = 8.0 + rnd.nextDouble() * 10;
        final hh = 10.0 + rnd.nextDouble() * 20;
        jag.lineTo(jx + w * 0.4, -hh);
        jag.lineTo(jx + w, -4);
        jx += w;
      }
      jag.lineTo(half, 0);
      jag.close();
      c.drawPath(jag, _fill(const Color(0xFF8D9189)));
      c.drawPath(hills(4, 4, 0.05, 2.0), _fill(const Color(0xFF5E7A58)));
      break;
    case 4: // île au loin et plage
      c.drawRect(const Rect.fromLTRB(-half, -4, half, 0), _fill(const Color(0xFFEFDDAE)));
      c.drawOval(Rect.fromCenter(center: const Offset(-120, -8), width: 150, height: 26), _fill(const Color(0xFF3E9B74)));
      c.drawOval(Rect.fromCenter(center: const Offset(150, -6), width: 90, height: 16), _fill(const Color(0xFF5BB38A)));
      c.drawRect(const Rect.fromLTRB(-half, -h, half, 0), _vGrad(const Rect.fromLTRB(-half, -h, half, 0), const [Color(0x55FFFFFF), Color(0x00FFFFFF)]));
      break;
    default: // collines dorées et baobabs lointains
      c.drawPath(hills(12, 9, 0.02, 0.2), _fill(const Color(0xFFE2A94E)));
      c.drawPath(hills(5, 7, 0.03, 2.2), _fill(const Color(0xFFC98B3A)));
      for (var i = 0; i < 9; i++) {
        final bx = -220.0 + i * 55 + rnd.nextDouble() * 20;
        c.save();
        c.translate(bx, -2);
        c.scale(0.2);
        drawBaobab(c, flat: const Color(0xFF7A4A24));
        c.restore();
      }
  }
}
