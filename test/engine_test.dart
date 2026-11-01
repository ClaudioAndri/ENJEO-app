import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:enjeo/game_logic/engine.dart';

/// Crée une partie avec des tirages scriptés (3 valeurs par tirage).
Game mk(int n, List<int> draws, {List<int>? pos}) {
  final it = draws.iterator;
  final g = Game(n, dice: () {
    if (!it.moveNext()) throw StateError('tirages épuisés');
    return it.current;
  });
  if (pos != null) {
    for (var i = 0; i < pos.length; i++) {
      g.pos[i] = pos[i];
    }
  }
  return g;
}

void main() {
  test('structure : 72 bornes, PRA aux bornes 8,20,32,44,56,68', () {
    expect(goalPos, 72);
    expect([for (var b = 1; b <= goalPos; b++) if (isPra(b)) b],
        [8, 20, 32, 44, 56, 68]);
  });

  group('garage', () {
    test('un 6 fait sortir le bus et fait rejouer', () {
      final g = mk(2, [6, 2, 3, 1, 1, 1]);
      final e = g.play(0);
      expect(g.pos[0], 1);
      expect(e.exited && e.replay, true);
      expect(g.current, 0);
    });
    test('1 à 5 : le bus reste au garage, pas de rejeu (même avec 1)', () {
      for (var v = 1; v <= 5; v++) {
        final g = mk(2, [v, 6, 6, 1, 1, 1]);
        g.play(0);
        expect(g.pos[0], garagePos);
        expect(g.current, 1);
      }
    });
    test('choix à l\'aveugle sans 6 : le tour passe', () {
      final g = mk(2, [2, 3, 4, 1, 1, 1]);
      g.play(1);
      expect(g.pos[0], garagePos);
      expect(g.current, 1);
    });
    test('sortie sur la borne 1 sans capture (borne partagée)', () {
      final g = mk(2, [6, 1, 1, 1, 1, 1], pos: [garagePos, 1]);
      g.play(0);
      expect(g.pos[0], 1);
      expect(g.pos[1], 1);
    });
  });

  group('rejouer et nouveau tirage', () {
    test('enchaînement 6, 1 puis 4', () {
      final g = mk(2, [2, 6, 4, 1, 3, 5, 4, 2, 5, 1, 1, 1],
          pos: [garagePos, garagePos]);
      g.play(1);
      expect(g.pos[0], 1);
      expect(g.current, 0);
      expect(g.boxes, [1, 3, 5]);
      g.play(0);
      expect(g.pos[0], 2);
      expect(g.current, 0);
      expect(g.boxes, [4, 2, 5]);
      g.play(0);
      expect(g.pos[0], 6);
      expect(g.current, 1);
    });
    test('déplacements de 1 à 6', () {
      for (var v = 1; v <= 6; v++) {
        final g = mk(2, [v, 1, 1, 1, 1, 1], pos: [20, 0]);
        g.play(0);
        expect(g.pos[0], 20 + v);
        expect(g.current, (v == 1 || v == 6) ? 0 : 1);
      }
    });
  });

  group('PRA', () {
    test('retour au garage puis nécessité d\'un 6', () {
      final g = mk(2, [3, 1, 1, 5, 5, 5, 6, 1, 1, 1, 1, 1], pos: [5, 0]);
      final e = g.play(0);
      expect(e.pra, true);
      expect(g.pos[0], garagePos);
      expect(g.current, 1);
      g.current = 0;
      g.play(0);
      expect(g.pos[0], garagePos);
      g.current = 0;
      g.play(0);
      expect(g.pos[0], 1);
    });
    test('PRA atteint avec un 6 ou un 1 : pas de rejeu', () {
      for (final c in [
        [2, 6],
        [7, 1]
      ]) {
        final g = mk(2, [c[1], 1, 1, 1, 1, 1], pos: [c[0], 0]);
        final e = g.play(0);
        expect(e.pra, true);
        expect(g.pos[0], garagePos);
        expect(g.current, 1);
      }
    });
    test('PRA du dernier segment (borne 68)', () {
      final g = mk(2, [2, 1, 1, 1, 1, 1], pos: [66, 0]);
      expect(g.play(0).pra, true);
    });
    test('passer par-dessus le PRA sans s\'y arrêter : aucun effet', () {
      final g = mk(2, [3, 1, 1, 1, 1, 1], pos: [7, 0]);
      g.play(0);
      expect(g.pos[0], 10);
    });
  });

  group('capture', () {
    test('arrivée exacte : l\'adversaire retourne au garage', () {
      final g = mk(2, [5, 1, 1, 1, 1, 1], pos: [20, 25]);
      final e = g.play(0);
      expect(g.pos[0], 25);
      expect(g.pos[1], garagePos);
      expect(e.captured, [1]);
    });
    test('capture avec un 6 : le joueur rejoue', () {
      final g = mk(2, [6, 1, 1, 1, 1, 1], pos: [20, 26]);
      g.play(0);
      expect(g.pos[1], garagePos);
      expect(g.current, 0);
    });
    test('dépasser un bus sans arriver dessus ne le capture pas', () {
      final g = mk(2, [5, 1, 1, 1, 1, 1], pos: [20, 23]);
      g.play(0);
      expect(g.pos[0], 25);
      expect(g.pos[1], 23);
    });
  });

  group('arrivée en G', () {
    test('arrivée exacte = victoire', () {
      final g = mk(2, [3, 1, 1], pos: [69, 0]);
      final e = g.play(0);
      expect(g.winner, 0);
      expect(g.pos[0], goalPos);
      expect(e.win, true);
    });
    test('chiffre trop grand : le bus reste en place', () {
      final g = mk(2, [5, 1, 1, 1, 1, 1], pos: [69, 0]);
      final e = g.play(0);
      expect(g.pos[0], 69);
      expect(g.winner, null);
      expect(g.current, 1);
      expect(e.blocked, true);
      expect(e.remaining, 3);
    });
    test('6 impossible près de G : pas de rejeu', () {
      final g = mk(2, [6, 1, 1, 1, 1, 1], pos: [70, 0]);
      g.play(0);
      expect(g.pos[0], 70);
      expect(g.current, 1);
    });
    test('il faut le nombre exact après avoir attendu', () {
      final g = mk(2, [5, 1, 1, 2, 1, 1, 1, 1, 1], pos: [70, 0]);
      g.play(0);
      g.current = 0;
      g.play(0);
      expect(g.winner, 0);
    });
    test('victoire avec un 6 et avec un 1', () {
      for (final c in [
        [66, 6],
        [71, 1]
      ]) {
        final g = mk(2, [c[1], 1, 1], pos: [c[0], 0]);
        g.play(0);
        expect(g.winner, 0);
      }
    });
    test('arrêt immédiat après la victoire', () {
      final g = mk(2, [1, 1, 1], pos: [71, 0]);
      g.play(0);
      expect(() => g.play(0), throwsStateError);
    });
  });

  group('joueurs et box', () {
    test('ordre circulaire à 2, 3 et 4 joueurs', () {
      for (final n in [2, 3, 4]) {
        final g = mk(n, List<int>.filled(3 * (n + 2), 2));
        final seq = <int>[];
        for (var i = 0; i < n + 1; i++) {
          seq.add(g.current);
          g.play(0);
        }
        expect(seq, [...List<int>.generate(n, (i) => i), 0]);
      }
    });
    test('3 valeurs entre 1 et 6 par tirage, doublons possibles', () {
      final g = Game(2, rng: Random(1));
      var dup = false;
      for (var i = 0; i < 2000; i++) {
        g.play(Random(i).nextInt(3));
        expect(g.boxes.length, 3);
        expect(g.boxes.every((x) => x >= 1 && x <= 6), true);
        if (g.boxes.toSet().length < 3) dup = true;
        if (g.winner != null) break;
      }
      expect(dup, true);
    });
  });

  test('parties simulées : légales, toujours terminées, un seul vainqueur', () {
    for (final n in [2, 3, 4]) {
      for (var seed = 0; seed < 300; seed++) {
        final rnd = Random(seed);
        final g = Game(n, rng: Random(seed + 10000));
        var turns = 0;
        while (g.winner == null && turns < 200000) {
          g.play(rnd.nextInt(3));
          turns++;
          for (var i = 0; i < n; i++) {
            expect(g.pos[i] >= 0 && g.pos[i] <= goalPos, true);
            expect(isPra(g.pos[i]), false);
            if (g.pos[i] > 1) {
              for (var j = 0; j < n; j++) {
                if (j != i) expect(g.pos[j], isNot(g.pos[i]));
              }
            }
          }
        }
        expect(g.winner, isNotNull, reason: 'n=$n seed=$seed');
        expect(g.pos[g.winner!], goalPos);
        expect(g.pos.where((p) => p == goalPos).length, 1);
      }
    }
  });
}
