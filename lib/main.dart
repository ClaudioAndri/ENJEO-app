import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash_screen.dart';
import 'storage/settings_store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SettingsStore.init();
  runApp(const EnjeoApp());
}

class EnjeoApp extends StatelessWidget {
  const EnjeoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENJEO',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashScreen(),
    );
  }
}
