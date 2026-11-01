import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models.dart';
import '../storage/settings_store.dart';
import '../theme.dart';
import '../widgets/bus_icon.dart';
import '../widgets/common.dart';
import 'game_screen.dart';

/// [choice] = 1 (contre l'ordinateur) ou 2..4 (joueurs humains).
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, required this.choice});
  final int choice;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late final List<TextEditingController> names;
  late final List<int> colors;

  @override
  void initState() {
    super.initState();
    names = List.generate(
      widget.choice,
      (i) => TextEditingController(text: SettingsStore.playerName(i)),
    );
    colors = List<int>.generate(widget.choice, (i) => i);
  }

  @override
  void dispose() {
    for (final c in names) {
      c.dispose();
    }
    super.dispose();
  }

  void _pickColor(int player, int color) {
    setState(() {
      final other = colors.indexOf(color);
      if (other != -1 && other != player) {
        colors[other] = colors[player];
      }
      colors[player] = color;
    });
  }

  void _start() {
    final players = <PlayerConfig>[];
    for (var i = 0; i < widget.choice; i++) {
      final typed = names[i].text.trim();
      SettingsStore.setPlayerName(i, typed);
      players.add(PlayerConfig(
        name: typed.isEmpty ? L10n.tr('default_player', {'n': '${i + 1}'}) : typed,
        colorIndex: colors[i],
      ));
    }
    if (widget.choice == 1) {
      var aiColor = 0;
      while (colors.contains(aiColor)) {
        aiColor++;
      }
      players.add(PlayerConfig(
        name: L10n.tr('computer'),
        colorIndex: aiColor,
        isAi: true,
      ));
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(players: players)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Backdrop(
        child: Column(
          children: [
            ScreenHeader(title: L10n.tr('setup_title')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (var i = 0; i < widget.choice; i++) _playerCard(i),
                  if (widget.choice == 1)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        L10n.tr('ai_level'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
              child: BigButton(label: L10n.tr('start'), onTap: _start),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerCard(int i) {
    return Card(
      color: AppColors.cream,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: names[i],
              maxLength: 12,
              decoration: InputDecoration(
                labelText: widget.choice == 1
                    ? L10n.tr('your_name')
                    : L10n.tr('player_name', {'n': '${i + 1}'}),
                counterText: '',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              L10n.tr('bus_color'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var c = 0; c < busColors.length; c++)
                  GestureDetector(
                    onTap: () => _pickColor(i, c),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors[i] == c ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors[i] == c ? AppColors.ink : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: BusIcon(
                        color: busColors[c].main,
                        dark: busColors[c].dark,
                        width: 52,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
