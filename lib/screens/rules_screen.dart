import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/common.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  static const List<String> _icons = [
    '6️⃣', '📦', '🔢', '🔁', '🚔', '↩️', '💥', '🛑', '🎯', '🏆',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Backdrop(
        child: Column(
          children: [
            ScreenHeader(title: L10n.tr('rules_title')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      L10n.tr('rules_intro'),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  for (var i = 0; i < 10; i++)
                    Card(
                      color: AppColors.cream,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Text(_icons[i], style: const TextStyle(fontSize: 30)),
                        title: Text(
                          L10n.tr('r${i + 1}'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
