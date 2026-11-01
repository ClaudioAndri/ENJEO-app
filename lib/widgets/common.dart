import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme.dart';
import 'bus_icon.dart';

/// Fond vert dégradé commun aux écrans hors jeu.
class Backdrop extends StatelessWidget {
  const Backdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.deepGreen, AppColors.green],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.color = AppColors.orange,
    this.textColor = Colors.white,
  });

  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            if (subtitle != null)
              Text(subtitle!, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class EnjeoLogo extends StatelessWidget {
  const EnjeoLogo({super.key, this.scale = 1.0});
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BusIcon(
          color: AppColors.orange,
          dark: const Color(0xFF9A5410),
          width: 96 * scale,
        ),
        SizedBox(height: 8 * scale),
        Text(
          L10n.tr('app_name'),
          style: TextStyle(
            fontSize: 58 * scale,
            fontWeight: FontWeight.w900,
            letterSpacing: 6 * scale,
            color: Colors.white,
            shadows: const [
              Shadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 4 * scale),
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            L10n.tr('tagline'),
            style: TextStyle(
              fontSize: 20 * scale,
              fontWeight: FontWeight.w800,
              letterSpacing: 5 * scale,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Barre de titre simple avec bouton retour pour les écrans hors jeu.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
