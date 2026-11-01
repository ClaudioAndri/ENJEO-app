import 'package:flutter/material.dart';

/// Un bus tel que la vue 3D doit le dessiner.
class BusView {
  const BusView({
    required this.pos,
    required this.color,
    required this.dark,
    required this.name,
    required this.active,
    required this.lane,
    this.alpha = 1.0,
  });

  /// Position de jeu (0 = garage, 1..72) — peut être fractionnaire pendant
  /// l'animation.
  final double pos;
  final Color color;
  final Color dark;
  final String name;
  final bool active;

  /// Couloir de 0 à (joueurs - 1), de gauche à droite.
  final int lane;
  final double alpha;
}

/// Tout ce qu'il faut pour dessiner une image de la vue de poursuite.
class SceneState {
  const SceneState({
    required this.camPos,
    required this.buses,
    required this.focus,
    required this.players,
    this.time = 0,
    this.speed = 0,
    this.shake = 0,
  });

  /// Position (fractionnaire) du bus suivi par la caméra.
  final double camPos;
  final List<BusView> buses;
  final int focus;
  final int players;
  final double time;

  /// 0..1 : vitesse apparente (traits de vitesse, poussière).
  final double speed;

  /// 0..1 : secousse (arrivée sur un PRA, capture).
  final double shake;
}
