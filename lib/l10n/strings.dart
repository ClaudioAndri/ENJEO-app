/// Système de localisation simple. Français complet ; le malagasy (mg) et
/// l'anglais (en) peuvent être ajoutés en remplissant leur table : toute clé
/// manquante retombe automatiquement sur le français.
class L10n {
  static String locale = 'fr';

  static String tr(String key, [Map<String, String> params = const {}]) {
    var s = _tables[locale]?[key] ?? _tables['fr']![key] ?? key;
    params.forEach((k, v) {
      s = s.replaceAll('{$k}', v);
    });
    return s;
  }

  static const Map<String, Map<String, String>> _tables = {
    'fr': _fr,
    'mg': {},
    'en': {},
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
    'lang_fr': 'Français',
    'lang_soon': 'Malagasy et English : bientôt',
    'about_title': 'À propos',
    'about_text':
        'ENJEO — TAXIBE est un jeu de course inspiré des taxi-brousse de Madagascar. « ENJEO » signifie « Poursuis-moi » en malagasy.',
    'version': 'Version de test 0.1.0',
  };
}
