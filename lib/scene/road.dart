import 'dart:math';

/// Mètres par borne : la distance réelle entre deux bornes dans la vue 3D.
const double borneM = 8.0;

/// Une étape (A→B, B→C…) fait 12 bornes.
const double stageLenM = 12 * borneM;
const int stageCount = 6;

/// Position (z) du garage : les bus y attendent avant la borne 1.
const double garageZ = -6.0;

/// Limites du monde en mètres.
const double zMin = -90.0;
const double zMax = 72 * borneM + 320.0;

/// Convertit une position de jeu (0 = garage, 1..72 = bornes) en mètres.
/// Entre 0 et 1, le bus sort du garage et glisse jusqu'à la borne 1.
double posToZ(double pos) {
  if (pos <= 0) return garageZ;
  if (pos < 1) return garageZ + (borneM - garageZ) * pos;
  return pos * borneM;
}

/// Étape (0..5) à la distance [z]. Avant le départ : étape 0 ; après G : étape 5.
int stageOfZ(double z) {
  final s = (z / stageLenM).floor();
  return s < 0 ? 0 : (s > stageCount - 1 ? stageCount - 1 : s);
}

double smooth01(double t) {
  final x = t < 0 ? 0.0 : (t > 1 ? 1.0 : t);
  return x * x * (3 - 2 * x);
}

class _Shape {
  const _Shape(this.curveAmp, this.curveLen, this.hillAmp, this.hillLen,
      this.phase);
  final double curveAmp; // rad/m
  final double curveLen; // m
  final double hillAmp; // pente max
  final double hillLen; // m
  final double phase;
}

/// Caractère de la route à chaque étape (virages et collines).
const List<_Shape> _shapes = [
  _Shape(0.0021, 210, 0.060, 130, 0.4), // Hautes Terres : collines douces
  _Shape(0.0030, 150, 0.045, 110, 1.9), // Forêt : sinueuse
  _Shape(0.0010, 320, 0.040, 210, 3.1), // Isalo : longs rubans
  _Shape(0.0028, 130, 0.055, 120, 0.9), // Tsingy : tortueuse
  _Shape(0.0016, 250, 0.020, 220, 2.2), // Côte : courbes larges, plat
  _Shape(0.0002, 400, 0.010, 300, 0.0), // Allée des baobabs : toute droite
];

/// Tracé de la route : abscisse, altitude, cap et pente à chaque mètre.
class RoadShape {
  RoadShape._() {
    _build();
  }

  static final RoadShape instance = RoadShape._();

  static const double step = 0.5;
  late final List<double> _x;
  late final List<double> _y;
  late final List<double> _hd;
  late final List<double> _sl;

  void _build() {
    final n = ((zMax - zMin) / step).ceil() + 3;
    _x = List<double>.filled(n, 0);
    _y = List<double>.filled(n, 0);
    _hd = List<double>.filled(n, 0);
    _sl = List<double>.filled(n, 0);
    var hd = 0.0;
    var x = 0.0;
    var y = 0.0;
    for (var i = 0; i < n; i++) {
      final z = zMin + i * step;
      // mélange des formes autour des frontières d'étape
      final sf = z / stageLenM;
      final s0 = sf.floor();
      final frac = sf - s0;
      final a = _shapes[s0 < 0 ? 0 : (s0 > 5 ? 5 : s0)];
      final b = _shapes[s0 + 1 < 0 ? 0 : (s0 + 1 > 5 ? 5 : s0 + 1)];
      final t = smooth01((frac - 0.85) / 0.15);
      double mix(double p, double q) => p + (q - p) * t;
      final cAmp = mix(a.curveAmp, b.curveAmp);
      final cLen = mix(a.curveLen, b.curveLen);
      final hAmp = mix(a.hillAmp, b.hillAmp);
      final hLen = mix(a.hillLen, b.hillLen);
      final ph = mix(a.phase, b.phase);

      final curve = cAmp * (sin(z * 2 * pi / cLen + ph) +
          0.45 * sin(z * 2 * pi / (cLen * 0.47) + ph * 2.3));
      final slope = hAmp * (sin(z * 2 * pi / hLen + ph * 1.7) +
          0.5 * sin(z * 2 * pi / (hLen * 0.53) + ph));
      hd += curve * step;
      x += hd * step;
      y += slope * step;
      _hd[i] = hd;
      _x[i] = x;
      _y[i] = y;
      _sl[i] = slope;
    }
  }

  double _at(List<double> t, double z) {
    final f = (z - zMin) / step;
    final i = f.floor();
    if (i < 0) return t[0];
    if (i >= t.length - 1) return t[t.length - 1];
    final k = f - i;
    return t[i] + (t[i + 1] - t[i]) * k;
  }

  double xAt(double z) => _at(_x, z);
  double yAt(double z) => _at(_y, z);
  double headingAt(double z) => _at(_hd, z);
  double slopeAt(double z) => _at(_sl, z);
}
