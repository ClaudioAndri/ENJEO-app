import 'package:flutter/material.dart';

/// Encre : toutes les couleurs des décors passent ici. Elle applique la brume
/// atmosphérique (les objets lointains se fondent dans l'horizon) et une
/// transparence globale (fondu entre deux ambiances).
class Ink {
  static Color fog = const Color(0xFFFFFFFF);
  static double fogAmt = 0;
  static double alpha = 1;

  static void set(Color fogColor, double amt, [double a = 1]) {
    fog = fogColor;
    fogAmt = amt;
    alpha = a;
  }

  static void reset() {
    fogAmt = 0;
    alpha = 1;
  }

  static Color apply(Color c) {
    var r = c;
    if (fogAmt > 0) {
      final m = Color.lerp(c.withAlpha(255), fog, fogAmt) ?? c;
      r = m.withValues(alpha: c.a);
    }
    if (alpha < 1) r = r.withValues(alpha: r.a * alpha);
    return r;
  }

  static Paint fill(Color c) => Paint()..color = apply(c);

  static Paint stroke(Color c, double w,
          {StrokeCap cap = StrokeCap.round, StrokeJoin join = StrokeJoin.round}) =>
      Paint()
        ..color = apply(c)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = cap
        ..strokeJoin = join;

  /// Dégradé linéaire dans [r].
  static Paint grad(Rect r, List<Color> colors,
      {List<double>? stops,
      Alignment from = Alignment.topCenter,
      Alignment to = Alignment.bottomCenter}) {
    return Paint()
      ..shader = LinearGradient(
        begin: from,
        end: to,
        colors: [for (final c in colors) apply(c)],
        stops: stops,
      ).createShader(r);
  }

  /// Dégradé radial centré en [c].
  static Paint radial(Offset c, double radius, List<Color> colors,
      {List<double>? stops}) {
    return Paint()
      ..shader = RadialGradient(
        colors: [for (final col in colors) apply(col)],
        stops: stops,
      ).createShader(Rect.fromCircle(center: c, radius: radius));
  }
}
