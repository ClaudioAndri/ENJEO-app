import 'dart:math';

enum Difficulty { normal }

/// Les box étant masquées, l'ordinateur ne peut pas les voir non plus :
/// il choisit au hasard, comme un humain. Aucune triche possible.
/// Les niveaux Facile / Difficile pourront être ajoutés plus tard.
class AiPlayer {
  AiPlayer({Random? rng, this.difficulty = Difficulty.normal})
      : _rng = rng ?? Random();

  final Random _rng;
  final Difficulty difficulty;

  int chooseBox() => _rng.nextInt(3);
}
