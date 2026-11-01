import 'package:flutter/material.dart';

/// Ambiance d'une étape : ciel, lumière, sols et route.
/// La journée avance avec le voyage : aube sur les Hautes Terres… coucher de
/// soleil sur l'Allée des Baobabs.
class Biome {
  const Biome({
    required this.id,
    required this.skyTop,
    required this.skyMid,
    required this.skyLow,
    required this.fog,
    required this.sun,
    required this.sunGlow,
    required this.sunX,
    required this.sunY,
    required this.sunSize,
    required this.fields,
    required this.verge,
    required this.road,
    required this.roadAlt,
    required this.line,
    required this.shade,
    this.water,
  });

  final String id;
  final Color skyTop;
  final Color skyMid;
  final Color skyLow;
  final Color fog;
  final Color sun;
  final Color sunGlow;

  /// Position du soleil : x en fraction de la largeur, y en fraction de la
  /// hauteur du ciel (0 = horizon).
  final double sunX;
  final double sunY;
  final double sunSize;

  /// Couleurs des champs / sols qui alternent de chaque côté de la route.
  final List<Color> fields;
  final Color verge;
  final Color road;
  final Color roadAlt;
  final Color line;

  /// Couleur d'ombre portée (ton chaud ou froid selon l'heure).
  final Color shade;

  /// Eau (côte) à gauche de la route.
  final Color? water;
}

const List<Biome> biomes = [
  // 0 · Hautes Terres — matin brumeux, rizières en terrasses
  Biome(
    id: 'highlands',
    skyTop: Color(0xFF5E9BD6),
    skyMid: Color(0xFFA8D0EC),
    skyLow: Color(0xFFFFE2BE),
    fog: Color(0xFFEFE2D2),
    sun: Color(0xFFFFF4D1),
    sunGlow: Color(0xFFFFD9A0),
    sunX: 0.74,
    sunY: 0.16,
    sunSize: 0.055,
    fields: [Color(0xFF7FC04A), Color(0xFF5FA53C), Color(0xFFB6CB5A), Color(0xFF8FD16B)],
    verge: Color(0xFFC4825A),
    road: Color(0xFF5D6069),
    roadAlt: Color(0xFF565A63),
    line: Color(0xFFF4EEDC),
    shade: Color(0xFF2A3A20),
  ),
  // 1 · Forêt de l'Est — humide, lumière verte, brume
  Biome(
    id: 'rainforest',
    skyTop: Color(0xFF7FB4B2),
    skyMid: Color(0xFFB9DCCE),
    skyLow: Color(0xFFE6F0DC),
    fog: Color(0xFFCFE4D6),
    sun: Color(0xFFFFFBE0),
    sunGlow: Color(0xFFE9F6C6),
    sunX: 0.3,
    sunY: 0.28,
    sunSize: 0.05,
    fields: [Color(0xFF2E7D50), Color(0xFF276C45), Color(0xFF3A8C5C), Color(0xFF215F3D)],
    verge: Color(0xFF7B5B3C),
    road: Color(0xFF4A4F57),
    roadAlt: Color(0xFF444951),
    line: Color(0xFFEDEBD6),
    shade: Color(0xFF0E2A1C),
  ),
  // 2 · Isalo — plein midi, grès orange, ciel bleu profond
  Biome(
    id: 'isalo',
    skyTop: Color(0xFF2A78CF),
    skyMid: Color(0xFF6DB2EE),
    skyLow: Color(0xFFF7E6C6),
    fog: Color(0xFFF2DDBA),
    sun: Color(0xFFFFFBE8),
    sunGlow: Color(0xFFFFF0BE),
    sunX: 0.58,
    sunY: 0.62,
    sunSize: 0.05,
    fields: [Color(0xFFD9A35F), Color(0xFFCB8E4A), Color(0xFFE5B67C), Color(0xFFC27F3F)],
    verge: Color(0xFFB4663A),
    road: Color(0xFFA68468),
    roadAlt: Color(0xFF9C7B60),
    line: Color(0xFFF8EBD2),
    shade: Color(0xFF5A2C10),
  ),
  // 3 · Tsingy — après-midi, ciel contrasté, calcaire gris
  Biome(
    id: 'tsingy',
    skyTop: Color(0xFF47699B),
    skyMid: Color(0xFFA2B6CB),
    skyLow: Color(0xFFF0DAB6),
    fog: Color(0xFFD7D0C0),
    sun: Color(0xFFFFF1CB),
    sunGlow: Color(0xFFFFD99A),
    sunX: 0.28,
    sunY: 0.42,
    sunSize: 0.05,
    fields: [Color(0xFF8E9B78), Color(0xFF7E8B69), Color(0xFFA4AE8B), Color(0xFF75825F)],
    verge: Color(0xFFA68668),
    road: Color(0xFF6C6E73),
    roadAlt: Color(0xFF65676C),
    line: Color(0xFFECE6D6),
    shade: Color(0xFF2E3A2A),
  ),
  // 4 · Nosy Be — fin d'après-midi tropicale, lagon turquoise
  Biome(
    id: 'coast',
    skyTop: Color(0xFF23A0E0),
    skyMid: Color(0xFF8DD9F1),
    skyLow: Color(0xFFFFF0CE),
    fog: Color(0xFFE4F5F1),
    sun: Color(0xFFFFFBE0),
    sunGlow: Color(0xFFFFE9A6),
    sunX: 0.7,
    sunY: 0.3,
    sunSize: 0.06,
    fields: [Color(0xFFF1DFAB), Color(0xFFE8D198), Color(0xFFF7EAC2), Color(0xFFE2CB8E)],
    verge: Color(0xFFF5E5B8),
    road: Color(0xFF5F636C),
    roadAlt: Color(0xFF585C65),
    line: Color(0xFFF7F2E0),
    shade: Color(0xFF5A4A28),
    water: Color(0xFF21B8CF),
  ),
  // 5 · Allée des Baobabs — coucher de soleil, piste rouge
  Biome(
    id: 'baobabs',
    skyTop: Color(0xFF3A2B6A),
    skyMid: Color(0xFFC24E6B),
    skyLow: Color(0xFFFFC779),
    fog: Color(0xFFF7B777),
    sun: Color(0xFFFFF0B5),
    sunGlow: Color(0xFFFFB45A),
    sunX: 0.52,
    sunY: 0.07,
    sunSize: 0.11,
    fields: [Color(0xFFD98B40), Color(0xFFCC7C34), Color(0xFFE29B53), Color(0xFFC57030)],
    verge: Color(0xFFB45F2B),
    road: Color(0xFFB66A3B),
    roadAlt: Color(0xFFAC6235),
    line: Color(0xFFF6D9A8),
    shade: Color(0xFF3C1A2E),
  ),
];

Color mix(Color a, Color b, double t) => Color.lerp(a, b, t) ?? a;
