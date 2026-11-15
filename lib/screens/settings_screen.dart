import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../storage/settings_store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool sound = SettingsStore.soundOn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Backdrop(
        child: Column(
          children: [
            ScreenHeader(title: L10n.tr('settings_title')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Card(
                color: AppColors.cream,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(L10n.tr('sound')),
                      value: sound,
                      onChanged: (v) {
                        setState(() => sound = v);
                        SettingsStore.setSoundOn(v);
                      },
                    ),
                    ListTile(
                      title: Text(L10n.tr('language')),
                      trailing: SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: [
                          for (final c in L10n.supported)
                            ButtonSegment(value: c, label: Text(L10n.tr('lang_$c'))),
                        ],
                        selected: {L10n.locale},
                        onSelectionChanged: (s) {
                          L10n.setLocale(s.first);
                          SettingsStore.setLang(s.first);
                          setState(() {});
                        },
                      ),
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
