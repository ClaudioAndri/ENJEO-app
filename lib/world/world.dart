import 'dart:math';
import 'dart:ui';

import '../game_logic/engine.dart';

/// Hauteur d'une étape dans le monde (en pixels, à l'échelle du centre de la caméra).
const double stripH = 170.0;

/// 6 étapes + la bande du garage tout en bas.
const int stripCount = segmentCount + 1;

class Landscape {
  const Landscape({required this.nameKey, required this.fog});
  final String nameKey;
  final Color fog;
}

/// Les 6 paysages de Madagascar traversés, de A vers G.
const List<Landscape> landscapes = [
  Landscape(nameKey: 'stage_0', fog: Color(0xFFCFE8F2)), // Hautes Terres
  Landscape(nameKey: 'stage_1', fog: Color(0xFFBFE3D2)), // Forêt de l'Est
  Landscape(nameKey: 'stage_2', fog: Color(0xFFF3D2B0)), // Isalo
  Landscape(nameKey: 'stage_3', fog: Color(0xFFD5DDD6)), // Tsingy
  Landscape(nameKey: 'stage_4', fog: Color(0xFFBDEBEF)), // Lagon de Nosy Be
  Landscape(nameKey: 'stage_5', fog: Color(0xFFFFD9A0)), // Allée des Baobabs
];

/// Étape (0..5) d'une position de bus ; le garage compte comme l'étape 0.
int stageOf(int pos) {
  if (pos <= 0) return 0;
  final s = (pos - 1) ~/ segLen;
  return s > segmentCount - 1 ? segmentCount - 1 : s;
}

/// Points de la route et plages de points dessinées par chaque morceau.
class RoadGeometry {
  RoadGeometry(this.points, this.starts, this.ends);
  final List<Offset> points;
  final List<int> starts; // premier point de chaque étape
  final List<int> ends; // dernier point de chaque étape
}

/// Géométrie du monde : où se trouve chaque borne, chaque place de garage.
class World {
  World(this.width);

  final double width;

  double get height => stripH * stripCount;
  double get margin => 38.0;
  double get cellW => (width - margin * 2) / segLen;

  /// Centre d'une borne (1..72). Pour pos == 0 : la place de garage [slot].
  Offset cell(int pos, {int slot = 0}) {
    if (pos == garagePos) {
      return Offset(margin + (1.5 + slot * 3) * cellW, stripH * 6.62);
    }
    final r = (pos - 1) ~/ segLen;
    final col = (pos - 1) % segLen;
    final c = r.isEven ? col : segLen - 1 - col;
    final x = margin + (c + 0.5) * cellW;
    final y = (5 - r + 0.5) * stripH + sin((c + r * 2.0) * 0.7) * stripH * 0.11;
    return Offset(x, y);
  }

  RoadGeometry road() {
    final pts = <Offset>[];
    final starts = List<int>.filled(segmentCount, 0);
    final ends = List<int>.filled(segmentCount, 0);
    final first = cell(1);
    pts.add(Offset(first.dx, stripH * 6.62)); // place de garage
    for (var r = 0; r < segmentCount; r++) {
      starts[r] = r == 0 ? 1 : pts.length - 1; // virage précédent
      for (var col = 0; col < segLen; col++) {
        pts.add(cell(r * segLen + col + 1));
      }
      if (r < segmentCount - 1) {
        final a = cell((r + 1) * segLen);
        final b = cell((r + 1) * segLen + 1);
        final dir = r.isEven ? 1.0 : -1.0;
        pts.add(Offset(a.dx + dir * cellW * 0.9, (a.dy + b.dy) / 2));
      }
      ends[r] = pts.length - 1;
    }
    return RoadGeometry(pts, starts, ends);
  }
}

/// Courbe lisse (Catmull-Rom) passant exactement par les points [from]..[to].
Path roadPath(List<Offset> p, int from, int to) {
  final path = Path()..moveTo(p[from].dx, p[from].dy);
  for (var i = from; i < to; i++) {
    final p0 = p[max(i - 1, 0)];
    final p1 = p[i];
    final p2 = p[i + 1];
    final p3 = p[min(i + 2, p.length - 1)];
    final c1 = p1 + (p2 - p0) / 6;
    final c2 = p2 - (p3 - p1) / 6;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path;
}
