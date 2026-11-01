import 'package:flutter/material.dart';

/// Taxi-brousse dessiné par code, avec dégradés pour un rendu en volume.
/// Le bus regarde vers la droite ; retourner horizontalement pour l'autre sens.
class BusIcon extends StatelessWidget {
  const BusIcon({
    super.key,
    required this.color,
    required this.dark,
    this.width = 44,
  });

  final Color color;
  final Color dark;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 0.72,
      child: CustomPaint(painter: _BusPainter(color, dark)),
    );
  }
}

class _BusPainter extends CustomPainter {
  _BusPainter(this.color, this.dark);
  final Color color;
  final Color dark;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final light = Color.lerp(color, Colors.white, 0.38)!;

    // bagages sur la galerie de toit
    const bagColors = [Color(0xFFE8C07D), Color(0xFF8FB5A0), Color(0xFFC9785C)];
    final bagW = w * 0.17;
    for (var k = 0; k < 3; k++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.13 + k * w * 0.2, h * 0.01, bagW, h * 0.15),
          Radius.circular(h * 0.04),
        ),
        Paint()..color = bagColors[k],
      );
    }
    // galerie + corde
    canvas.drawRect(
      Rect.fromLTWH(w * 0.1, h * 0.14, w * 0.68, h * 0.035),
      Paint()..color = dark,
    );

    // carrosserie en dégradé
    final bodyRect = Rect.fromLTWH(0, h * 0.17, w, h * 0.63);
    final body = RRect.fromRectAndRadius(bodyRect, Radius.circular(h * 0.16));
    canvas.drawRRect(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [light, color, dark],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(bodyRect),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.045
        ..color = dark,
    );

    // reflet sur le toit
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.2, w * 0.7, h * 0.04),
        Radius.circular(h * 0.02),
      ),
      Paint()..color = const Color(0x66FFFFFF),
    );

    // vitres
    final glass = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEAF8FF), Color(0xFF9BCBE3)],
      ).createShader(Rect.fromLTWH(0, h * 0.28, w, h * 0.22));
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * (0.08 + i * 0.22), h * 0.28, w * 0.18, h * 0.21),
          Radius.circular(h * 0.04),
        ),
        glass,
      );
    }
    // pare-brise incliné
    final windshield = Path()
      ..moveTo(w * 0.76, h * 0.28)
      ..lineTo(w * 0.92, h * 0.28)
      ..lineTo(w * 0.96, h * 0.5)
      ..lineTo(w * 0.76, h * 0.5)
      ..close();
    canvas.drawPath(windshield, glass);

    // bande blanche + bas de caisse
    canvas.drawRect(
      Rect.fromLTWH(w * 0.03, h * 0.55, w * 0.94, h * 0.05),
      Paint()..color = const Color(0xD9FFFFFF),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.02, h * 0.68, w * 0.96, h * 0.09),
      Paint()..color = const Color(0x33000000),
    );

    // roues avec ombre dans le passage de roue
    final wheel = Paint()..color = const Color(0xFF1E1E22);
    final hub = Paint()..color = const Color(0xFFD0D0D6);
    for (final cx in [w * 0.24, w * 0.76]) {
      canvas.drawCircle(Offset(cx, h * 0.82), h * 0.19, Paint()..color = const Color(0x55000000));
      canvas.drawCircle(Offset(cx, h * 0.84), h * 0.15, wheel);
      canvas.drawCircle(Offset(cx, h * 0.84), h * 0.065, hub);
    }

    // phare + pare-chocs
    canvas.drawCircle(Offset(w * 0.975, h * 0.62), h * 0.055,
        Paint()..color = const Color(0xFFFFE680));
    canvas.drawRect(Rect.fromLTWH(w * 0.93, h * 0.7, w * 0.07, h * 0.05),
        Paint()..color = const Color(0xFF8A8A92));
  }

  @override
  bool shouldRepaint(covariant _BusPainter old) =>
      old.color != color || old.dark != dark;
}
