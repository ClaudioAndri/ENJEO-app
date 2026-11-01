import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../widgets/common.dart';
import 'setup_screen.dart';

class PlayerCountScreen extends StatelessWidget {
  const PlayerCountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void go(int n) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SetupScreen(choice: n)),
        );
    return Scaffold(
      body: Backdrop(
        child: Column(
          children: [
            ScreenHeader(title: L10n.tr('players_title')),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BigButton(
                      label: L10n.tr('one_player'),
                      subtitle: L10n.tr('one_player_sub'),
                      onTap: () => go(1),
                    ),
                    for (var n = 2; n <= 4; n++) ...[
                      const SizedBox(height: 14),
                      BigButton(
                        label: L10n.tr('n_players', {'n': '$n'}),
                        subtitle: L10n.tr('n_players_sub'),
                        onTap: () => go(n),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
