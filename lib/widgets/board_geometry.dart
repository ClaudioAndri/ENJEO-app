import 'dart:math';

import 'package:flutter/material.dart';

import '../game_logic/engine.dart';

/// Géométrie du plateau : une route en serpentin qui monte du garage (bas)
/// jusqu'à G (haut). Rangée 0 = tout en haut (segment F→G), rangée 5 = segment
/// A→B, rangée 6 = garage.
class BoardGeometry {
  BoardGeometry(this.width);

  final double width;

  /// Distance verticale entre deux rangées de route.
  double get sh => min(170.0, max(120.0, width * 0.38));
  double get margin => 18.0;
  double get cellW => (width - margin * 2) / segLen;
  double get roadHalf => cellW * 0.6;

  /// Espace de ciel au-dessus de la dernière rangée.
  double get topPad => sh * 0.55;
  double get horizon => topPad * 0.9;

  double rowY(int i) => topPad + (i + 0.5) * sh;
  double get totalHeight => rowY(6) + roadHalf + 34;

  /// Centre d'une borne (1..72) ou d'un emplacement de garage (pos == 0).
  Offset cell(int pos, {int slot = 0}) {
    if (pos == garagePos) {
      return Offset(margin + (1.5 + slot * 3) * cellW, rowY(6));
    }
    final r = (pos - 1) ~/ segLen;
    final col = (pos - 1) % segLen;
    final c = r.isEven ? col : segLen - 1 - col;
    return Offset(margin + (c + 0.5) * cellW, rowY(5 - r));
  }

  /// Zone de décor située juste au-dessus de la route de la rangée [i].
  double gapTop(int i) => i == 0 ? horizon + 6 : rowY(i - 1) + roadHalf + 6;
  double gapBottom(int i) => rowY(i) - roadHalf - 4;

  /// Bande de sol associée à la rangée [i] (décor + route).
  double bandTop(int i) => i == 0 ? horizon : rowY(i - 1) + roadHalf + 2;
  double bandBottom(int i) =>
      i == 6 ? totalHeight : rowY(i) + roadHalf + 14;
}
