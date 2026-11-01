// Génère de vraies captures d'écran de l'application (PNG).
// Lancé uniquement par le job « screenshots » de GitHub Actions :
//   flutter test screenshots/capture_test.dart --update-goldens
// Les images sont écrites dans screenshots/out/.
//
// Remarque : dans un test, les emojis ne s'affichent pas (carrés vides) ;
// c'est une limite des captures, pas de l'application.
import 'dart:io';

import 'package:enjeo/models.dart';
import 'package:enjeo/screens/game_screen.dart';
import 'package:enjeo/screens/menu_screen.dart';
import 'package:enjeo/storage/settings_store.dart';
import 'package:enjeo/theme.dart';
import 'package:enjeo/widgets/route_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;
  final dir = '$root/bin/cache/artifacts/material_fonts';
  final loader = FontLoader('Roboto');
  var found = false;
  for (final f in ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf']) {
    final file = File('$dir/$f');
    if (file.existsSync()) {
      found = true;
      loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
    }
  }
  if (found) await loader.load();
}

List<PlayerConfig> _players() => [
      PlayerConfig(name: 'Mino', colorIndex: 0),
      PlayerConfig(name: 'Rado', colorIndex: 1),
    ];

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await SettingsStore.init();
    await _loadFonts();
  });

  Future<void> shot(WidgetTester t, Widget home, String name) async {
    t.view.physicalSize = const Size(780, 1560); // 390 x 780 à l'échelle 2
    t.view.devicePixelRatio = 2.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: home,
    ));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));
  }

  testWidgets('menu', (t) => shot(t, const MenuScreen(), '01_menu'));

  testWidgets('partie', (t) => shot(t, GameScreen(players: _players()), '02_partie'));

  // Un bus placé dans chacune des 6 étapes : la caméra suit le bus et montre
  // chaque paysage (bornes 5, 17, 29, 41, 53, 65).
  const stages = [
    [5, '03_etape_A-B_hautes_terres'],
    [17, '04_etape_B-C_foret_est'],
    [29, '05_etape_C-D_isalo'],
    [41, '06_etape_D-E_tsingy'],
    [53, '07_etape_E-F_nosy_be'],
    [65, '08_etape_F-G_baobabs'],
  ];
  for (final s in stages) {
    final pos = s[0] as int;
    final name = s[1] as String;
    testWidgets('paysage $name', (t) {
      return shot(
        t,
        Scaffold(
          body: SafeArea(
            child: RouteBoard(
              positions: [pos, 0],
              players: _players(),
              current: 0,
              focus: 0,
            ),
          ),
        ),
        name,
      );
    });
  }
}
