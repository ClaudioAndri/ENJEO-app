import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../widgets/common.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Backdrop(
        child: Column(
          children: [
            ScreenHeader(title: L10n.tr('about_title')),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EnjeoLogo(scale: 0.9),
                    const SizedBox(height: 24),
                    Text(
                      L10n.tr('about_text'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      L10n.tr('version'),
                      style: const TextStyle(color: Colors.white70),
                    ),
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
