import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/bus_icon.dart';
import '../widgets/common.dart';
import 'game_screen.dart';

class VictoryScreen extends StatelessWidget {
  const VictoryScreen({super.key, required this.players, required this.winner});
  final List<PlayerConfig> players;
  final int winner;

  @override
  Widget build(BuildContext context) {
    final w = players[winner];
    return Scaffold(
      body: Backdrop(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, t, child) =>
                    Transform.scale(scale: t, child: child),
                child: const Text('🏆', style: TextStyle(fontSize: 96)),
              ),
              const SizedBox(height: 12),
              Text(
                L10n.tr('victory_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.orange,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              BusIcon(color: w.color.main, dark: w.color.dark, width: 110),
              const SizedBox(height: 14),
              Text(
                L10n.tr('victory_text', {'name': w.name}),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                L10n.tr('victory_enjeo'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 32),
              BigButton(
                label: L10n.tr('play_again'),
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => GameScreen(players: players),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              BigButton(
                label: L10n.tr('back_menu'),
                color: Colors.white24,
                onTap: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
