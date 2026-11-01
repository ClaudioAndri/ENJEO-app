import 'dart:math';

/// Moteur de règles ENJEO — aucune dépendance à l'interface.

const int segLen = 12; // bornes par segment
const int segmentCount = 6; // A→B, B→C, ..., F→G
const int goalPos = segLen * segmentCount; // 72 = G
const int praOffset = 8; // le PRA est sur la 8e borne de chaque segment
const int garagePos = 0;

bool isPra(int pos) => pos != garagePos && pos % segLen == praOffset;

/// Résultat d'un choix de box.
class TurnEvent {
  TurnEvent({required this.player, required this.value, required this.from})
      : to = from;

  final int player;
  final int value;
  final int from;

  /// Borne d'arrivée avant l'effet éventuel du PRA.
  int to;
  bool moved = false;
  bool exited = false;
  bool pra = false;
  bool win = false;
  bool replay = false;

  /// Garage et aucun 6 choisi : le bus reste au garage.
  bool noSix = false;

  /// Dépassement de G : le bus ne bouge pas.
  bool blocked = false;
  int remaining = 0;
  List<int> captured = [];
}

class Game {
  Game(this.playerCount, {int Function()? dice, Random? rng})
      : assert(playerCount >= 2 && playerCount <= 4),
        _rng = rng ?? Random(),
        pos = List<int>.filled(playerCount, garagePos) {
    _dice = dice ?? (() => _rng.nextInt(6) + 1);
    boxes = _draw();
  }

  final int playerCount;
  final Random _rng;
  late final int Function() _dice;

  /// Position de chaque bus : 0 = garage, 1..72 = bornes.
  final List<int> pos;
  int current = 0;
  int? winner;

  /// Valeurs cachées des 3 box (le joueur ne les voit pas).
  late List<int> boxes;

  List<int> _draw() => List<int>.generate(3, (_) => _dice());

  TurnEvent play(int boxIndex) {
    if (winner != null) throw StateError('Partie terminée');
    if (boxIndex < 0 || boxIndex > 2) {
      throw RangeError.range(boxIndex, 0, 2);
    }
    final p = current;
    final v = boxes[boxIndex];
    final ev = TurnEvent(player: p, value: v, from: pos[p]);

    if (pos[p] == garagePos) {
      if (v == 6) {
        pos[p] = 1;
        ev.to = 1;
        ev.moved = true;
        ev.exited = true;
        ev.replay = true;
      } else {
        ev.noSix = true;
      }
    } else {
      final target = pos[p] + v;
      if (target > goalPos) {
        ev.blocked = true;
        ev.remaining = goalPos - pos[p];
      } else {
        pos[p] = target;
        ev.to = target;
        ev.moved = true;
        if (target == goalPos) {
          winner = p;
          ev.win = true;
        } else if (isPra(target)) {
          pos[p] = garagePos;
          ev.pra = true;
        } else {
          for (var q = 0; q < playerCount; q++) {
            if (q != p && pos[q] == target) {
              pos[q] = garagePos;
              ev.captured.add(q);
            }
          }
          ev.replay = v == 1 || v == 6;
        }
      }
    }

    if (winner == null) {
      boxes = _draw();
      if (!ev.replay) current = (current + 1) % playerCount;
    }
    return ev;
  }
}
