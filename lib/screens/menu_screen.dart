import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'about_screen.dart';
import 'player_count_screen.dart';
import 'rules_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _go(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Backdrop(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const EnjeoLogo(),
              const SizedBox(height: 10),
              Text(
                L10n.tr('meaning'),
                style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 16),
              ),
              const Spacer(flex: 2),
              BigButton(
                label: L10n.tr('play'),
                onTap: () => _go(context, const PlayerCountScreen()),
              ),
              const SizedBox(height: 12),
              BigButton(
                label: L10n.tr('rules'),
                color: AppColors.cream,
                textColor: AppColors.ink,
                onTap: () => _go(context, const RulesScreen()),
              ),
              const SizedBox(height: 12),
              BigButton(
                label: L10n.tr('settings'),
                color: Colors.white24,
                onTap: () => _go(context, const SettingsScreen()),
              ),
              const SizedBox(height: 12),
              BigButton(
                label: L10n.tr('about'),
                color: Colors.white24,
                onTap: () => _go(context, const AboutScreen()),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
