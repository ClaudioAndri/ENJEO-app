import 'dart:math';

import '../game_logic/engine.dart';
import 'world.dart';

/// Un élément de décor qui se dresse sur le sol (arbre, maison, rocher...).
class Prop {
  const Prop(this.key, this.x, this.y,
      [this.scale = 1.0, this.flip = false, this.width = 0.0]);

  final String key;
  final double x;
  final double y;
  final double scale;
  final bool flip;

  /// Largeur imposée dans le monde (0 = taille naturelle du sprite).
  final double width;
}

const String _letters = 'ABCDEFG';

List<Prop> buildProps(World w) {
  final out = <Prop>[];
  final ww = w.width;

  for (var r = 0; r < segmentCount; r++) {
    final rnd = Random(31 + r * 7);
    final top = (5 - r) * stripH;

    double slotX(int k, int n) =>
        ww * (0.16 + 0.68 * (k + 0.2 + rnd.nextDouble() * 0.6) / n);
    double farY() => top + stripH * (0.10 + rnd.nextDouble() * 0.17);
    double nearY() => top + stripH * (0.71 + rnd.nextDouble() * 0.08);
    void add(String key, double x, double y, [double s = 1.0]) {
      out.add(Prop(key, x, y, s, rnd.nextBool()));
    }

    // Horizon bas de l'étape (collines, mesas, pics...)
    out.add(Prop('ridge_$r', ww / 2, top + stripH * 0.03, 1.0, false, ww * 1.5));

    List<String> far;
    List<String> near;
    double farScale = 1.0;
    double nearScale = 0.85;
    switch (r) {
      case 0: // Hautes Terres d'Antananarivo
        far = ['house', 'eucalyptus', 'house2', 'house', 'eucalyptus', 'house2'];
        near = ['zebu', 'bush', 'rock', 'bush'];
        farScale = 0.95;
        break;
      case 1: // Forêt tropicale de l'Est
        far = ['forestTree', 'ravenala', 'forestTree', 'forestTree', 'ravenala', 'forestTree'];
        near = ['fern', 'ravenala', 'fern', 'bush', 'fern'];
        nearScale = 0.7;
        break;
      case 2: // Massif de l'Isalo
        far = ['mesa', 'arch', 'mesa', 'mesa'];
        near = ['rock', 'lemur', 'rock', 'lemur', 'bush'];
        nearScale = 0.9;
        break;
      case 3: // Tsingy de Bemaraha
        far = ['tsingy1', 'tsingy2', 'tsingy1', 'tsingy1', 'tsingy2', 'tsingy1'];
        near = ['tsingy2', 'bush', 'tsingy2', 'bush'];
        nearScale = 0.62;
        break;
      case 4: // Lagon de Nosy Be
        far = ['pirogue', 'pirogue', 'pirogue'];
        near = ['palm', 'rock', 'palm', 'bush', 'palm'];
        nearScale = 0.85;
        break;
      default: // Allée des Baobabs
        far = ['baobab', 'baobab', 'baobab', 'baobab'];
        near = ['grass', 'baobab', 'grass', 'baobab', 'grass'];
        farScale = 0.95;
        nearScale = 0.8;
    }

    for (var k = 0; k < far.length; k++) {
      add(far[k], slotX(k, far.length), farY(), farScale * (0.9 + rnd.nextDouble() * 0.2));
    }
    for (var k = 0; k < near.length; k++) {
      final isGrass = near[k] == 'grass';
      add(near[k], slotX(k, near.length), nearY(),
          (isGrass ? 1.0 : nearScale) * (0.9 + rnd.nextDouble() * 0.2));
    }

    // Panneau de la borne d'étape (B, C, D, E, F, G)
    final end = w.cell((r + 1) * segLen);
    final dir = r.isEven ? 1.0 : -1.0;
    out.add(Prop('sign_${_letters[r + 1]}', end.dx - dir * 6, end.dy + 20, 1.0));

    // PRA : policier sur la 8e borne
    final pra = w.cell(r * segLen + praOffset);
    out.add(Prop('pra', pra.dx + 4, pra.dy - 12, 0.9));
  }

  // Départ
  final start = w.cell(1);
  out.add(Prop('sign_A', start.dx + 6, start.dy + 20, 1.0));

  // Arche d'arrivée
  final g = w.cell(goalPos);
  out.add(Prop('finish', g.dx, g.dy + 8, 0.8));

  // Garage
  out.add(Prop('garage', ww / 2, stripH * 6.1, 1.0, false, ww * 0.94));

  // Soleil couchant tout au fond, au-delà de G
  out.add(Prop('sun', ww * 0.5, -430, 1.6));

  out.sort((a, b) => a.y.compareTo(b.y));
  return out;
}
