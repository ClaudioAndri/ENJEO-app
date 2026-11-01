import 'dart:math';

import 'package:flutter/material.dart';

/// Petits éléments de décor dessinés par code (aucune image nécessaire).
/// Chaque fonction dessine un objet debout : (x, by) = pied de l'objet.

Paint _f(Color c) => Paint()..color = c;

Paint _line(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round;

void groundShadow(Canvas c, double x, double y, double rx, double ry,
    [int alpha = 70]) {
  c.drawOval(
    Rect.fromCenter(center: Offset(x, y), width: rx * 2, height: ry * 2),
    _f(Color.fromARGB(alpha, 30, 15, 0)),
  );
}

// ───────────────────────── Hautes Terres ─────────────────────────

/// Maison traditionnelle en briques rouges, toit de chaume très pentu.
void drawHouse(Canvas c, double x, double by, double h) {
  final bw = h * 0.56;
  final bh = h * 0.44;
  final dep = h * 0.2;
  final left = x - (bw + dep) / 2;
  final front = Rect.fromLTWH(left, by - bh, bw, bh);
  groundShadow(c, x + dep * 0.3, by + 1, (bw + dep) * 0.62, h * 0.06);

  c.drawRect(front, _f(const Color(0xFFC9532F)));
  final brick = _line(const Color(0x22000000), 1);
  for (var k = 1; k < 4; k++) {
    final yy = front.top + bh * k / 4;
    c.drawLine(Offset(front.left, yy), Offset(front.right, yy), brick);
  }

  final side = Path()
    ..moveTo(front.right, front.top)
    ..lineTo(front.right + dep, front.top - dep * 0.35)
    ..lineTo(front.right + dep, by - dep * 0.35)
    ..lineTo(front.right, by)
    ..close();
  c.drawPath(side, _f(const Color(0xFF8F3622)));

  final roofH = h * 0.5;
  final apex = Offset(front.center.dx, front.top - roofH);
  final apexBack = Offset(apex.dx + dep, apex.dy - dep * 0.35);
  final gable = Path()
    ..moveTo(front.left - 3, front.top + 1)
    ..lineTo(apex.dx, apex.dy)
    ..lineTo(front.right + 3, front.top + 1)
    ..close();
  c.drawPath(gable, _f(const Color(0xFF7A5638)));
  final roofSide = Path()
    ..moveTo(apex.dx, apex.dy)
    ..lineTo(apexBack.dx, apexBack.dy)
    ..lineTo(front.right + dep + 3, front.top - dep * 0.35 + 1)
    ..lineTo(front.right + 3, front.top + 1)
    ..close();
  c.drawPath(roofSide, _f(const Color(0xFF55391F)));
  c.drawLine(apex, apexBack, _line(const Color(0xFFB08A5E), 1.6));
  final thatch = _line(const Color(0x33000000), 1);
  for (var k = 1; k < 4; k++) {
    final t = k / 4;
    c.drawLine(
      Offset(front.left - 3 + (apex.dx - front.left + 3) * t, front.top + 1 - (roofH - 1) * t),
      Offset(front.right + 3 - (front.right + 3 - apex.dx) * t, front.top + 1 - (roofH - 1) * t),
      thatch,
    );
  }

  final win = _f(const Color(0xFFFFD98A));
  final ww = bw * 0.2;
  c.drawRect(
      Rect.fromLTWH(front.left + bw * 0.14, front.top + bh * 0.2, ww, bh * 0.28),
      win);
  c.drawRect(
      Rect.fromLTWH(
          front.right - bw * 0.14 - ww, front.top + bh * 0.2, ww, bh * 0.28),
      win);
  c.drawRect(Rect.fromLTWH(front.left, front.top + bh * 0.52, bw, 2),
      _f(const Color(0xFF5A2A18)));
  c.drawRect(
      Rect.fromLTWH(front.center.dx - bw * 0.09, by - bh * 0.46, bw * 0.18,
          bh * 0.46),
      _f(const Color(0xFF4A2B1C)));
}

void drawEucalyptus(Canvas c, double x, double by, double h) {
  groundShadow(c, x + h * 0.12, by + 1, h * 0.16, h * 0.03, 55);
  final trunk = Path()
    ..moveTo(x - h * 0.02, by)
    ..quadraticBezierTo(x + h * 0.035, by - h * 0.4, x - h * 0.008, by - h * 0.78)
    ..lineTo(x + h * 0.012, by - h * 0.78)
    ..quadraticBezierTo(x + h * 0.07, by - h * 0.4, x + h * 0.022, by)
    ..close();
  c.drawPath(trunk, _f(const Color(0xFFD9CBB2)));
  final cy = by - h * 0.82;
  const cols = [Color(0xFF4F7B4A), Color(0xFF6E9E5D), Color(0xFF93C27A)];
  const blobs = [
    Offset(-0.1, 0.07),
    Offset(0.1, 0.05),
    Offset(0.0, -0.06),
    Offset(-0.06, 0.15),
    Offset(0.08, 0.14),
  ];
  for (var k = 0; k < blobs.length; k++) {
    c.drawOval(
      Rect.fromCenter(
        center: Offset(x + blobs[k].dx * h, cy + blobs[k].dy * h),
        width: h * 0.24,
        height: h * 0.12,
      ),
      _f(cols[k % 3]),
    );
  }
}

// ───────────────────────── Forêt de l'Est ─────────────────────────

void drawRainTree(Canvas c, double x, double by, double h) {
  groundShadow(c, x + h * 0.1, by + 1, h * 0.22, h * 0.04, 60);
  final tw = h * 0.045;
  final trunk = Path()
    ..moveTo(x - tw * 1.4, by)
    ..lineTo(x - tw, by - h * 0.55)
    ..lineTo(x + tw, by - h * 0.55)
    ..lineTo(x + tw * 1.4, by)
    ..close();
  c.drawPath(trunk, _f(const Color(0xFF5A3E2B)));
  final cy = by - h * 0.72;
  final r = h * 0.26;
  c.drawCircle(Offset(x, cy), r, _f(const Color(0xFF1B5E3A)));
  c.drawCircle(Offset(x - r * 0.7, cy + r * 0.2), r * 0.7, _f(const Color(0xFF237048)));
  c.drawCircle(Offset(x + r * 0.7, cy + r * 0.25), r * 0.65, _f(const Color(0xFF237048)));
  c.drawCircle(Offset(x, cy - r * 0.55), r * 0.7, _f(const Color(0xFF2E8B57)));
  c.drawCircle(Offset(x - r * 0.35, cy - r * 0.6), r * 0.42, _f(const Color(0xFF4FAE78)));
  c.drawCircle(Offset(x + r * 0.3, cy - r * 0.8), r * 0.3, _f(const Color(0xFF6FC794)));
  final vine = _line(const Color(0xFF1B5E3A), 1.2);
  for (var k = -2; k <= 2; k++) {
    final vx = x + k * r * 0.35;
    c.drawLine(Offset(vx, cy + r * 0.7),
        Offset(vx + 1, cy + r * 0.7 + h * 0.1 + k.abs() * 2.0), vine);
  }
}

/// Ravinala, l'« arbre du voyageur », emblème de Madagascar.
void drawRavinala(Canvas c, double x, double by, double h) {
  groundShadow(c, x + h * 0.1, by + 1, h * 0.25, h * 0.04, 55);
  final top = Offset(x, by - h * 0.46);
  c.drawRect(Rect.fromLTRB(x - h * 0.025, top.dy, x + h * 0.025, by),
      _f(const Color(0xFF7A5A3C)));
  final reach = h * 0.56;
  for (var k = -5; k <= 5; k++) {
    final a = k * 0.27;
    final dir = Offset(sin(a), -cos(a));
    final perp = Offset(cos(a), sin(a));
    final tip = top + dir * reach + Offset(0, a.abs() * reach * 0.12);
    final mid = top + dir * (reach * 0.5);
    final wd = reach * 0.1;
    final leaf = Path()
      ..moveTo(top.dx, top.dy)
      ..quadraticBezierTo(
          mid.dx + perp.dx * wd, mid.dy + perp.dy * wd, tip.dx, tip.dy)
      ..quadraticBezierTo(
          mid.dx - perp.dx * wd, mid.dy - perp.dy * wd, top.dx, top.dy)
      ..close();
    c.drawPath(leaf,
        _f(k.isEven ? const Color(0xFF2F8C4E) : const Color(0xFF3FA862)));
    c.drawLine(top, tip, _line(const Color(0x667FD69A), 0.8));
  }
}

void drawFern(Canvas c, double x, double by, double s) {
  final p = _line(const Color(0xFF3FA66A), 1.6);
  for (var k = -3; k <= 3; k++) {
    final a = k * 0.36;
    final tip = Offset(x + sin(a) * s, by - cos(a) * s * 0.8);
    final ctrl = Offset(x + sin(a) * s * 0.4, by - s * 0.95);
    final path = Path()
      ..moveTo(x, by)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy);
    c.drawPath(path, p);
  }
}

void drawBush(Canvas c, double x, double by, double r, Color dark, Color light) {
  groundShadow(c, x + r * 0.2, by + 1, r * 1.1, r * 0.25, 50);
  c.drawOval(
      Rect.fromCenter(
          center: Offset(x, by - r * 0.45), width: r * 2.2, height: r * 1.2),
      _f(dark));
  c.drawOval(
      Rect.fromCenter(
          center: Offset(x - r * 0.25, by - r * 0.65),
          width: r * 1.4,
          height: r * 0.8),
      _f(light));
}

// ───────────────────────── Isalo ─────────────────────────

/// Massif de grès : façade à strates colorées + face latérale sombre.
void drawMesa(Canvas c, double x, double by, double h, double fw) {
  final left = x - fw / 2;
  final right = x + fw / 2;
  final dep = fw * 0.22;
  groundShadow(c, x + dep * 0.8, by + 1, fw * 0.62, h * 0.07, 60);

  final outline = Path()
    ..moveTo(left, by)
    ..lineTo(left, by - h * 0.84)
    ..lineTo(left + fw * 0.08, by - h)
    ..lineTo(left + fw * 0.3, by - h * 0.95)
    ..lineTo(left + fw * 0.52, by - h)
    ..lineTo(left + fw * 0.78, by - h * 0.92)
    ..lineTo(right - fw * 0.04, by - h * 0.97)
    ..lineTo(right, by - h * 0.78)
    ..lineTo(right, by)
    ..close();

  final side = Path()
    ..moveTo(right, by - h * 0.78)
    ..lineTo(right + dep, by - h * 0.78 - dep * 0.3)
    ..lineTo(right + dep, by - dep * 0.3)
    ..lineTo(right, by)
    ..close();
  c.drawPath(side, _f(const Color(0xFF8F4A22)));

  c.save();
  c.clipPath(outline);
  const bands = [
    Color(0xFFEBB06C),
    Color(0xFFD98C48),
    Color(0xFFC97A39),
    Color(0xFFE0A05C),
    Color(0xFFB8672D),
  ];
  for (var k = 0; k < bands.length; k++) {
    c.drawRect(
      Rect.fromLTRB(left, by - h + h * k / bands.length - 1, right,
          by - h + h * (k + 1) / bands.length + 1),
      _f(bands[k]),
    );
  }
  final shade = Rect.fromLTRB(left, by - h, right, by);
  c.drawRect(
    shade,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x00000000), Color(0x33000000)],
      ).createShader(shade),
  );
  final crack = _line(const Color(0x33401A00), 1);
  for (var k = 1; k < 5; k++) {
    final cx = left + fw * k / 5;
    c.drawLine(Offset(cx, by - h * 0.9), Offset(cx + fw * 0.02, by), crack);
  }
  c.restore();
  c.drawPath(outline, _line(const Color(0x55FFE2B0), 1.2));
}

/// Fenêtre de l'Isalo : un massif percé d'une grande arche.
void drawArch(Canvas c, double x, double by, double h, double fw) {
  drawMesa(c, x, by, h, fw);
  final holeW = fw * 0.34;
  final hl = x - holeW / 2;
  final hr = x + holeW / 2;
  final topY = by - h * 0.62;
  final win = Path()
    ..moveTo(hl, by)
    ..lineTo(hl, topY + holeW * 0.4)
    ..quadraticBezierTo(x, topY - holeW * 0.45, hr, topY + holeW * 0.4)
    ..lineTo(hr, by)
    ..close();
  c.drawPath(win, _f(const Color(0xFFFBD9A4)));
  c.drawPath(win, _line(const Color(0xFF7A3B18), 2));
}

void drawRock(Canvas c, double x, double by, double w, double h) {
  groundShadow(c, x + w * 0.1, by + 1, w * 0.6, h * 0.18, 55);
  final p = Path()
    ..moveTo(x - w / 2, by)
    ..quadraticBezierTo(x - w * 0.55, by - h * 0.8, x - w * 0.1, by - h)
    ..quadraticBezierTo(x + w * 0.4, by - h * 1.02, x + w / 2, by - h * 0.3)
    ..lineTo(x + w * 0.5, by)
    ..close();
  c.drawPath(p, _f(const Color(0xFFB4825A)));
  c.drawPath(
      Path()
        ..moveTo(x - w * 0.35, by - h * 0.55)
        ..quadraticBezierTo(x - w * 0.1, by - h * 1.0, x + w * 0.2, by - h * 0.95),
      _line(const Color(0x66FFE2B0), 1.4));
}

/// Maki catta (lémurien à queue annelée), l'emblème de l'Isalo.
void drawLemur(Canvas c, double x, double by, double s) {
  final p0 = Offset(x - s * 0.15, by - s * 0.12);
  final p1 = Offset(x - s * 0.95, by - s * 0.05);
  final p2 = Offset(x - s * 0.55, by - s * 1.15);
  Offset bez(double t) {
    final u = 1 - t;
    return Offset(
      u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx,
      u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy,
    );
  }

  for (var k = 0; k < 8; k++) {
    c.drawLine(
      bez(k / 8),
      bez((k + 1) / 8),
      _line(k.isOdd ? const Color(0xFF2B2B30) : const Color(0xFFF1F1F1), s * 0.16),
    );
  }
  c.drawOval(
      Rect.fromCenter(
          center: Offset(x, by - s * 0.4), width: s * 0.5, height: s * 0.72),
      _f(const Color(0xFF9B9BA3)));
  c.drawOval(
      Rect.fromCenter(
          center: Offset(x + s * 0.06, by - s * 0.36),
          width: s * 0.28,
          height: s * 0.46),
      _f(const Color(0xFFF2F2F2)));
  final head = Offset(x + s * 0.04, by - s * 0.88);
  c.drawCircle(head + Offset(-s * 0.13, -s * 0.16), s * 0.07,
      _f(const Color(0xFF9B9BA3)));
  c.drawCircle(head + Offset(s * 0.1, -s * 0.18), s * 0.07,
      _f(const Color(0xFF9B9BA3)));
  c.drawCircle(head, s * 0.2, _f(const Color(0xFFB5B5BC)));
  c.drawOval(
      Rect.fromCenter(
          center: head + Offset(s * 0.1, s * 0.05),
          width: s * 0.2,
          height: s * 0.14),
      _f(const Color(0xFFFFFFFF)));
  c.drawCircle(head + Offset(s * 0.19, s * 0.03), s * 0.03,
      _f(const Color(0xFF111111)));
  c.drawOval(
      Rect.fromCenter(
          center: head + Offset(-s * 0.02, -s * 0.03),
          width: s * 0.11,
          height: s * 0.08),
      _f(const Color(0xFF2B2B30)));
  c.drawOval(
      Rect.fromCenter(
          center: head + Offset(s * 0.12, -s * 0.03),
          width: s * 0.1,
          height: s * 0.08),
      _f(const Color(0xFF2B2B30)));
}

/// Palmier : [lean] > 0 penche vers la droite, < 0 vers la gauche.
void drawPalm(Canvas c, double x, double by, double h, double lean) {
  groundShadow(c, x + h * 0.15, by + 1, h * 0.28, h * 0.035, 50);
  final top = Offset(x + lean * h * 0.3, by - h * 0.86);
  final trunk = Path()
    ..moveTo(x, by)
    ..quadraticBezierTo(x + lean * h * 0.05, by - h * 0.5, top.dx, top.dy);
  c.drawPath(trunk, _line(const Color(0xFF8A6A4A), h * 0.05));
  final reach = h * 0.5;
  for (final s in const [-1.0, 1.0]) {
    for (final a in const [0.15, 0.6, 1.0]) {
      final end = top + Offset(s * cos(a) * reach, sin(a) * reach * 0.75 - reach * 0.1);
      final ctrl = top + Offset(s * cos(a) * reach * 0.55, -reach * 0.38 + sin(a) * reach * 0.1);
      final wd = reach * 0.1;
      final frond = Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy - wd, end.dx, end.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy + wd, top.dx, top.dy)
        ..close();
      c.drawPath(frond,
          _f(a > 0.5 ? const Color(0xFF2F8C4E) : const Color(0xFF45A765)));
    }
  }
  c.drawLine(top, top + Offset(0, -reach * 0.5), _line(const Color(0xFF3FA862), 2.4));
  c.drawCircle(top + const Offset(-2, 3), 2.2, _f(const Color(0xFF5A3E2B)));
  c.drawCircle(top + const Offset(2.5, 3.5), 2.2, _f(const Color(0xFF5A3E2B)));
}

// ───────────────────────── Tsingy de Bemaraha ─────────────────────────

/// Aiguilles de calcaire : [hs] = hauteurs relatives de chaque pic (0..1).
void drawTsingy(Canvas c, double x, double by, double h, List<double> hs) {
  final n = hs.length;
  final spacing = h * 0.13;
  final bw = h * 0.1;
  groundShadow(c, x + h * 0.1, by + 1, n * spacing * 0.7, h * 0.05, 55);
  for (var k = 0; k < n; k++) {
    final sx = x + (k - (n - 1) / 2) * spacing;
    final top = by - h * hs[k];
    final lean = (k.isEven ? -1.0 : 1.0) * bw * 0.18;
    final left = Path()
      ..moveTo(sx - bw, by)
      ..lineTo(sx + lean, top)
      ..lineTo(sx, by)
      ..close();
    final right = Path()
      ..moveTo(sx, by)
      ..lineTo(sx + lean, top)
      ..lineTo(sx + bw, by)
      ..close();
    c.drawPath(left, _f(const Color(0xFFCBCFC6)));
    c.drawPath(right, _f(const Color(0xFF7F867A)));
    c.drawLine(Offset(sx + lean, top),
        Offset(sx + lean * 0.4, by - h * hs[k] * 0.35),
        _line(const Color(0x55303A2E), 0.9));
  }
}

// ───────────────────────── Nosy Be / côte ─────────────────────────

/// Boutre (voilier traditionnel à voile latine).
void drawDhow(Canvas c, double x, double y, double s, Color sail) {
  c.drawOval(
      Rect.fromCenter(
          center: Offset(x, y + s * 0.12), width: s * 1.3, height: s * 0.16),
      _f(const Color(0x33FFFFFF)));
  final hull = Path()
    ..moveTo(x - s * 0.6, y - s * 0.1)
    ..quadraticBezierTo(x, y + s * 0.3, x + s * 0.65, y - s * 0.12)
    ..lineTo(x + s * 0.55, y - s * 0.18)
    ..lineTo(x - s * 0.5, y - s * 0.17)
    ..close();
  c.drawPath(hull, _f(const Color(0xFF8B4A2B)));
  c.drawLine(Offset(x - s * 0.5, y - s * 0.17), Offset(x + s * 0.55, y - s * 0.18),
      _line(const Color(0xFFFFF4E0), 1.4));
  c.drawLine(Offset(x + s * 0.04, y - s * 0.17), Offset(x + s * 0.04, y - s * 1.0),
      _line(const Color(0xFF5A3E2B), 1.4));
  final sailP = Path()
    ..moveTo(x + s * 0.07, y - s * 0.2)
    ..lineTo(x + s * 0.07, y - s * 0.98)
    ..lineTo(x + s * 0.62, y - s * 0.25)
    ..close();
  c.drawPath(sailP, _f(sail));
  final jib = Path()
    ..moveTo(x + s * 0.01, y - s * 0.2)
    ..lineTo(x + s * 0.01, y - s * 0.8)
    ..lineTo(x - s * 0.5, y - s * 0.22)
    ..close();
  c.drawPath(jib, _f(Color.lerp(sail, const Color(0xFFFFFFFF), 0.45)!));
}

void drawIsland(Canvas c, double x, double y, double w) {
  c.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: w, height: w * 0.22),
      _f(const Color(0xFFF2E1B0)));
  final hill = Path()
    ..moveTo(x - w * 0.38, y - w * 0.02)
    ..quadraticBezierTo(x - w * 0.1, y - w * 0.42, x + w * 0.12, y - w * 0.3)
    ..quadraticBezierTo(x + w * 0.3, y - w * 0.2, x + w * 0.38, y - w * 0.02)
    ..close();
  c.drawPath(hill, _f(const Color(0xFF2F8C4E)));
  final light = Path()
    ..moveTo(x - w * 0.3, y - w * 0.05)
    ..quadraticBezierTo(x - w * 0.12, y - w * 0.33, x + w * 0.06, y - w * 0.27)
    ..quadraticBezierTo(x - w * 0.05, y - w * 0.12, x - w * 0.3, y - w * 0.05)
    ..close();
  c.drawPath(light, _f(const Color(0xFF55B27A)));
}

// ───────────────────────── Allée des Baobabs ─────────────────────────

/// Baobab Grandidier : tronc cylindrique, couronne de branches courtes.
/// Le soleil est à droite : tronc éclairé à droite, ombre longue à gauche.
void drawBaobab(Canvas c, double x, double by, double h) {
  final bw = h * 0.115;
  final tw = h * 0.082;
  final topY = by - h * 0.84;
  c.drawOval(
      Rect.fromCenter(
          center: Offset(x - h * 0.5, by + 2), width: h * 1.1, height: h * 0.09),
      _f(const Color(0x55401800)));
  final trunk = Path()
    ..moveTo(x - bw, by)
    ..cubicTo(x - tw * 1.1, by - h * 0.3, x - tw * 1.1, by - h * 0.55, x - tw, topY)
    ..lineTo(x + tw, topY)
    ..cubicTo(x + tw * 1.1, by - h * 0.55, x + tw * 1.1, by - h * 0.3, x + bw, by)
    ..close();
  final box = Rect.fromLTRB(x - bw, topY, x + bw, by);
  c.drawPath(
    trunk,
    Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5E3624), Color(0xFF9B6040), Color(0xFFDC9A63)],
        stops: [0.0, 0.6, 1.0],
      ).createShader(box),
  );
  final bark = _line(const Color(0x33301000), 1);
  for (var k = -2; k <= 2; k++) {
    c.drawLine(Offset(x + k * tw * 0.4, topY + 3), Offset(x + k * bw * 0.42, by - 2), bark);
  }
  const tips = [
    Offset(-0.2, -0.1),
    Offset(-0.12, -0.17),
    Offset(-0.04, -0.2),
    Offset(0.05, -0.19),
    Offset(0.13, -0.15),
    Offset(0.21, -0.08),
  ];
  final branch = _line(const Color(0xFF7A4B31), max(1.5, h * 0.035));
  for (final t in tips) {
    final start = Offset(x + (t.dx / 0.21) * tw * 0.8, topY + 1);
    final end = Offset(x + t.dx * h, topY + t.dy * h);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo((start.dx + end.dx) / 2, end.dy + h * 0.02, end.dx, end.dy);
    c.drawPath(path, branch);
    c.drawOval(
        Rect.fromCenter(center: end, width: h * 0.11, height: h * 0.05),
        _f(const Color(0xFF7E9A3A)));
    c.drawOval(
        Rect.fromCenter(
            center: end + Offset(h * 0.01, -h * 0.012),
            width: h * 0.07,
            height: h * 0.028),
        _f(const Color(0xFFA7B84A)));
  }
}

void drawTuft(Canvas c, double x, double y, double s, Color color) {
  final p = _line(color, 1.3);
  for (var k = -2; k <= 2; k++) {
    c.drawLine(Offset(x, y), Offset(x + k * s * 0.25, y - s * (1 - k.abs() * 0.15)), p);
  }
}
