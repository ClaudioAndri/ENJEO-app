import 'package:flutter/foundation.dart';

/// Système de localisation simple. Malagasy (langue principale) et français
/// (langue secondaire). Toute clé manquante retombe sur le malagasy puis le
/// français.
class L10n {
  static const String defaultLocale = 'mg';
  static const List<String> supported = ['mg', 'fr'];

  static String locale = defaultLocale;

  /// Notifie les écrans qui doivent se redessiner quand la langue change.
  static final ValueNotifier<String> notifier = ValueNotifier(defaultLocale);

  static void setLocale(String code) {
    if (!supported.contains(code)) return;
    locale = code;
    notifier.value = code;
  }

  static String tr(String key, [Map<String, String> params = const {}]) {
    var s = _tables[locale]?[key] ?? _tables['mg']![key] ?? _tables['fr']![key] ?? key;
    params.forEach((k, v) {
      s = s.replaceAll('{$k}', v);
    });
    return s;
  }

  static const Map<String, Map<String, String>> _tables = {
    'fr': _fr,
    'mg': _mg,
  };

  static const Map<String, String> _fr = {
    'app_name': 'ENJEO',
    'tagline': 'TAXIBE',
    'meaning': '« Poursuis-moi »',
    'play': 'Jouer',
    'settings': 'Paramètres',
    'rules': 'Règles du jeu',
    'about': 'À propos',
    'players_title': 'Combien de joueurs ?',
    'one_player': '1 joueur',
    'one_player_sub': 'Contre l’ordinateur',
    'n_players': '{n} joueurs',
    'n_players_sub': 'Sur le même téléphone',
    'setup_title': 'Configuration',
    'player_name': 'Nom du joueur {n}',
    'your_name': 'Ton nom',
    'default_player': 'Joueur {n}',
    'bus_color': 'Couleur du bus',
    'ai_level': 'Niveau de l’ordinateur : Normal',
    'start': 'Commencer',
    'computer': 'Ordinateur',
    'color_red': 'Rouge',
    'color_blue': 'Bleu',
    'color_yellow': 'Jaune',
    'color_green': 'Vert',
    'pause': 'Pause',
    'resume': 'Continuer',
    'restart': 'Recommencer',
    'quit': 'Quitter',
    'turn_of': 'Au tour de {name}',
    'computer_choosing': '{name} choisit…',
    'pick_box': 'Choisis une box',
    'msg_exit': '{name} sort du garage ! Il rejoue.',
    'msg_no_six': 'Pas de 6 : le bus de {name} reste au garage.',
    'msg_move': '{name} avance de {n}.',
    'msg_move_replay': '{name} avance de {n} et rejoue !',
    'msg_pra': 'PRA ! {name} retourne au garage.',
    'msg_capture': '{name} rattrape {other} ! {other} retourne au garage.',
    'msg_blocked': '{name} ne peut pas dépasser G : il faut exactement {n}.',
    'progress': 'Progression vers G',
    'garage': 'GARAGE',
    'region_0': 'Hautes Terres',
    'region_1': 'Forêt de l’Est',
    'region_2': 'Massif de l’Isalo',
    'region_3': 'Tsingy de Bemaraha',
    'region_4': 'Nosy Be',
    'region_5': 'Allée des Baobabs',
    'departure': 'DÉPART',
    'victory_title': 'DESTINATION ATTEINTE !',
    'victory_text': '{name} est arrivé à G !',
    'victory_enjeo': 'ENJEO !',
    'play_again': 'Rejouer',
    'back_menu': 'Menu principal',
    'rules_title': 'Comment jouer ?',
    'rules_intro':
        'Course de taxi-brousse de A à G : 6 étapes de 12 bornes, soit 72 bornes.',
    'r1': 'Obtiens un 6 pour sortir ton taxi-brousse du garage.',
    'r2': 'À chaque tour, trois box fermées sont proposées : choisis-en une.',
    'r3': 'Le chiffre révélé indique le nombre de bornes à parcourir.',
    'r4': 'Un 1 ou un 6 te permet de rejouer (au garage, seul le 6 compte).',
    'r5': 'Le PRA se trouve sur la 8ᵉ borne de chaque étape.',
    'r6': 'Tomber pile sur le PRA te renvoie au garage.',
    'r7': 'Si un adversaire tombe pile sur ton bus, tu retournes au garage.',
    'r8': 'Tu ne peux pas dépasser G : le bus reste sur place.',
    'r9': 'Il faut atteindre exactement la dernière borne.',
    'r10': 'Le premier arrivé à G gagne !',
    'settings_title': 'Paramètres',
    'sound': 'Sons',
    'language': 'Langue',
    'lang_mg': 'Malagasy',
    'lang_fr': 'Français',
    'about_title': 'À propos',
    'about_text':
        'ENJEO — TAXIBE est un jeu de course inspiré des taxi-brousse de Madagascar. « ENJEO » signifie « Poursuis-moi » en malagasy.',
    'version': 'Version de test 0.1.0',
  };

  static const Map<String, String> _mg = {
    'app_name': 'ENJEO',
    'tagline': 'TAXIBE',
    'meaning': '« Enjeo aho »',
    'play': 'Hilalao',
    'settings': 'Fanamboarana',
    'rules': 'Fitsipika',
    'about': 'Momba ny lalao',
    'players_title': 'Mpilalao firy?',
    'one_player': 'Mpilalao 1',
    'one_player_sub': 'Hanohitra ny solosaina',
    'n_players': 'Mpilalao {n}',
    'n_players_sub': 'Amin’ny telefaona iray',
    'setup_title': 'Fanomanana',
    'player_name': 'Anaran’ny mpilalao {n}',
    'your_name': 'Ny anaranao',
    'default_player': 'Mpilalao {n}',
    'bus_color': 'Ny lokon’ny taxi-be',
    'ai_level': 'Haavon’ny solosaina : Antonony',
    'start': 'Hanomboka',
    'computer': 'Solosaina',
    'color_red': 'Mena',
    'color_blue': 'Manga',
    'color_yellow': 'Mavo',
    'color_green': 'Maitso',
    'pause': 'Fiatoana',
    'resume': 'Hanohy',
    'restart': 'Hanomboka indray',
    'quit': 'Hiala',
    'turn_of': 'Ny anjaran’i {name}',
    'computer_choosing': '{name} mifidy…',
    'pick_box': 'Mifidiana boaty iray',
    'msg_exit': 'Nivoaka ny garazy i {name} ! Milalao indray izy.',
    'msg_no_six': 'Tsy misy 6 : mijanona ao amin’ny garazy ny taxi-ben’i {name}.',
    'msg_move': 'Mandroso {n} i {name}.',
    'msg_move_replay': 'Mandroso {n} i {name} ary milalao indray !',
    'msg_pra': 'PRA ! Miverina any amin’ny garazy i {name}.',
    'msg_capture': 'Nahatratra an’i {other} i {name} ! Miverina any amin’ny garazy i {other}.',
    'msg_blocked': 'Tsy afaka mihoatra ny G i {name} : mila {n} marina.',
    'progress': 'Fandrosoana mankany G',
    'garage': 'GARAZY',
    'region_0': 'Tany Ambony',
    'region_1': 'Ala Atsinanana',
    'region_2': 'Tendrombohitra Isalo',
    'region_3': 'Tsingin’i Bemaraha',
    'region_4': 'Nosy Be',
    'region_5': 'Lalan’ny Renala',
    'departure': 'FIAROVANA',
    'victory_title': 'TONGA NY FARANY !',
    'victory_text': 'Tonga any G i {name} !',
    'victory_enjeo': 'ENJEO !',
    'play_again': 'Hilalao indray',
    'back_menu': 'Fandraisana',
    'rules_title': 'Ahoana ny fomba filalaovana?',
    'rules_intro':
        'Fifaninanana taxi-be manomboka amin’ny A mankany G : dingana 6 misy borne 12, dia borne 72 daholo.',
    'r1': 'Mila 6 ianao mba hivoahan’ny taxi-benao avy ao amin’ny garazy.',
    'r2': 'Isaky ny anjara dia misy boaty telo mikatona : mifidiana iray.',
    'r3': 'Ny isa miseho no isan’ny borne handehanana.',
    'r4': 'Ny 1 na ny 6 dia ahafahanao milalao indray (ao amin’ny garazy, ny 6 ihany no raisina).',
    'r5': 'Ny PRA dia eo amin’ny borne faha-8 isaky ny dingana.',
    'r6': 'Raha mijanona marina eo amin’ny PRA ianao dia miverina any amin’ny garazy.',
    'r7': 'Raha misy mpifaninana mijanona marina eo amin’ny taxi-benao dia miverina any amin’ny garazy ianao.',
    'r8': 'Tsy afaka mihoatra ny G ianao : mijanona eo ny taxi-be.',
    'r9': 'Tsy maintsy tonga marina eo amin’ny borne farany.',
    'r10': 'Ny voalohany tonga any G no mandresy !',
    'settings_title': 'Fanamboarana',
    'sound': 'Feo',
    'language': 'Fiteny',
    'lang_mg': 'Malagasy',
    'lang_fr': 'Français',
    'about_title': 'Momba ny lalao',
    'about_text':
        'ENJEO — TAXIBE dia lalao fifaninanana nahazo aingam-panahy avy amin’ny taxi-be eto Madagasikara.',
    'version': 'Dikan-teny fitsapana 0.1.0',
  };
}
