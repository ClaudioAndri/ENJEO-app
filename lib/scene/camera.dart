import 'dart:math';

import 'package:flutter/material.dart';

import 'road.dart';

/// Demi-largeur de la route (m).
const double roadHalf = 5.2;

/// Hauteur de la caméra au-dessus de la route et recul derrière le bus suivi.
const double camHeight = 5.6;
const double camBehind = 11.5;

/// Distance de dessin et taille des tranches de route (m).
const double drawDist = 150.0;
const double segM = 2.0;
const double nearClip = 1.5;

/// Caméra de poursuite : elle suit la route (cap et pente du point où elle se
/// trouve), ce qui garde la route sous le bus toujours droite à l'écran.
class Cam {
  Cam({
    required this.w,
    required this.h,
    required this.camZ,
    required this.camX,
    RoadShape? road,
  }) : road = road ?? RoadShape.instance {
    horizon = h * 0.36;
    focal = w * 1.12;
    _cx0 = this.road.xAt(camZ);
    _cy0 = this.road.yAt(camZ);
    hd0 = this.road.headingAt(camZ);
    _sl0 = this.road.slopeAt(camZ);
  }

  final double w;
  final double h;
  final double camZ;
  final double camX;
  final RoadShape road;
  late final double horizon;
  late final double focal;
  late final double hd0;
  late final double _cx0;
  late final double _cy0;
  late final double _sl0;

  /// Décalage latéral de la route à la distance [z] (m), dans le repère caméra.
  double xRoad(double z) => road.xAt(z) - (_cx0 + hd0 * (z - camZ));

  /// Altitude de la route à la distance [z] (m), dans le repère caméra.
  double yRoad(double z) => road.yAt(z) - (_cy0 + _sl0 * (z - camZ));

  double scaleAt(double z) => focal / (z - camZ);

  bool visible(double z) => z - camZ > nearClip && z - camZ < drawDist;

  /// Projette un point : [x] = écart latéral à l'axe de la route (m),
  /// [y] = hauteur au-dessus de la route (m), [z] = distance (m).
  Offset toScreen(double x, double y, double z) {
    final s = focal / max(z - camZ, 0.05);
    return Offset(
      w / 2 + (xRoad(z) + x - camX) * s,
      horizon + (camHeight - yRoad(z) - y) * s,
    );
  }
}
