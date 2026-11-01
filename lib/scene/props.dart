import 'dart:math';

import 'camera.dart' show roadHalf;
import 'road.dart';

enum PropKind {
  house,
  eucalyptus,
  jacaranda,
  rainTree,
  ravinala,
  treeFern,
  bamboo,
  mesa,
  arch,
  satrana,
  lemurRock,
  tsingy,
  baobab,
  palm,
  hut,
  rock,
  bush,
  dryBush,
}

/// Un élément de décor planté au bord de la route (billboard dessiné).
class Prop {
  const Prop(this.kind, this.z, this.x, this.size, this.variant, this.flip);
  final PropKind kind;
  final double z;

  /// Écart latéral à l'axe de la route (m) : négatif = gauche.
  final double x;

  /// Hauteur dans le monde (m).
  final double size;
  final int variant;
  final bool flip;
}

class _Rule {
  const _Rule(this.kind, this.weight, this.hMin, this.hMax, this.xMin, this.xMax);
  final PropKind kind;
  final double weight;
  final double hMin;
  final double hMax;
  final double xMin; // écart minimal au bord de la route
  final double xMax;
}

const List<List<_Rule>> _rules = [
  // 0 Hautes Terres
  [
    _Rule(PropKind.house, 3, 7.5, 9.5, 2.5, 16),
    _Rule(PropKind.eucalyptus, 3, 13, 19, 2.5, 22),
    _Rule(PropKind.jacaranda, 1.2, 8, 10.5, 3, 14),
    _Rule(PropKind.bush, 2, 1.2, 2.2, 1.6, 7),
  ],
  // 1 Forêt de l'Est
  [
    _Rule(PropKind.rainTree, 3.5, 16, 24, 2, 20),
    _Rule(PropKind.ravinala, 2, 9, 12, 2.5, 14),
    _Rule(PropKind.treeFern, 2, 4.5, 7, 1.8, 9),
    _Rule(PropKind.bamboo, 1.5, 8, 11, 2.2, 12),
    _Rule(PropKind.bush, 1.5, 1.4, 2.4, 1.6, 8),
  ],
  // 2 Isalo
  [
    _Rule(PropKind.mesa, 2, 16, 30, 12, 55),
    _Rule(PropKind.arch, 0.5, 20, 30, 24, 55),
    _Rule(PropKind.satrana, 2.2, 8, 11, 2.5, 16),
    _Rule(PropKind.lemurRock, 0.7, 3.2, 3.8, 2.2, 6),
    _Rule(PropKind.rock, 2, 1.8, 3.4, 2, 12),
    _Rule(PropKind.dryBush, 2, 1.0, 1.8, 1.6, 9),
  ],
  // 3 Tsingy
  [
    _Rule(PropKind.tsingy, 4, 10, 22, 4, 38),
    _Rule(PropKind.baobab, 0.8, 9, 13, 5, 18),
    _Rule(PropKind.rock, 2, 1.8, 3.2, 2, 12),
    _Rule(PropKind.dryBush, 2.4, 1.0, 1.9, 1.6, 10),
  ],
  // 4 Nosy Be (la mer est à gauche)
  [
    _Rule(PropKind.palm, 4, 9, 13, 2.4, 9),
    _Rule(PropKind.hut, 1, 4.2, 5.2, 4, 12),
    _Rule(PropKind.bush, 1.5, 1.2, 2.2, 1.6, 6),
  ],
  // 5 Allée des baobabs
  [
    _Rule(PropKind.baobab, 5, 20, 29, 6, 15),
    _Rule(PropKind.dryBush, 2, 1.0, 1.8, 1.6, 9),
  ],
];

/// Espacement moyen des éléments le long de la route (m) par étape.
const List<double> _spacing = [9, 7, 12, 8, 9, 15];

/// Tous les éléments de décor du parcours, triés par distance.
class PropField {
  PropField._(this.all);
  static final PropField instance = PropField._(_build());
  final List<Prop> all;

  static List<Prop> _build() {
    final out = <Prop>[];
    for (var s = 0; s < stageCount; s++) {
      final rnd = Random(4242 + s * 97);
      final rules = _rules[s];
      final total = rules.fold<double>(0, (a, r) => a + r.weight);
      final z0 = s == 0 ? zMin : s * stageLenM;
      final z1 = s == stageCount - 1 ? zMax : (s + 1) * stageLenM;
      for (var side = -1; side <= 1; side += 2) {
        var z = z0 + rnd.nextDouble() * _spacing[s];
        while (z < z1) {
          var pick = rnd.nextDouble() * total;
          _Rule rule = rules.first;
          for (final r in rules) {
            pick -= r.weight;
            if (pick <= 0) {
              rule = r;
              break;
            }
          }
          // à la côte, la mer occupe la gauche : on n'y plante que des bateaux
          final skip = s == 4 && side < 0;
          if (!skip) {
            final h = rule.hMin + rnd.nextDouble() * (rule.hMax - rule.hMin);
            final dx = rule.xMin + rnd.nextDouble() * (rule.xMax - rule.xMin);
            out.add(Prop(rule.kind, z, side * (roadHalf + dx), h,
                rnd.nextInt(4), rnd.nextBool()));
          }
          z += _spacing[s] * (0.6 + rnd.nextDouble() * 0.8);
        }
      }
    }
    out.sort((a, b) => a.z.compareTo(b.z));
    return out;
  }

  /// Indice du premier élément dont z >= [z].
  int firstAtOrAfter(double z) {
    var lo = 0;
    var hi = all.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (all[mid].z < z) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }
}
