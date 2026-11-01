import 'package:flutter/material.dart';

class BusColor {
  const BusColor(this.key, this.main, this.dark);
  final String key; // clé de localisation
  final Color main;
  final Color dark;
}

const List<BusColor> busColors = [
  BusColor('color_red', Color(0xFFE5483B), Color(0xFF9E2A21)),
  BusColor('color_blue', Color(0xFF1E88C9), Color(0xFF125A87)),
  BusColor('color_yellow', Color(0xFFF2B01E), Color(0xFFB07C0A)),
  BusColor('color_green', Color(0xFF2E9D5B), Color(0xFF1B6B3C)),
];

class PlayerConfig {
  PlayerConfig({
    required this.name,
    required this.colorIndex,
    this.isAi = false,
  });
  final String name;
  final int colorIndex;
  final bool isAi;

  BusColor get color => busColors[colorIndex];
}
