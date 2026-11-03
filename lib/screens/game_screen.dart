import 'dart:math';

import 'package:flutter/material.dart';

import '../game_logic/ai.dart';
import '../game_logic/engine.dart';
import '../l10n/strings.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/bus_icon.dart';
import '../widgets/common.dart';
import '../widgets/route_board.dart';
import 'victory_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.players});
  final List<PlayerConfig> players;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Game game;
  late List<int> viz; // positions affichées (animées case par case)
  final AiPlayer ai = AiPlayer();

  int? revealedIndex;
  int? revealedValue;
  bool busy = false;
  bool paused = false;
  bool disposed = false;
  int gen = 0; // change à chaque nouvelle partie : annule les animations en cours
  String message = '';
  int focus = 0; // joueur dont le bus est suivi par la caméra

  PlayerConfig get currentPlayer => widget.players[game.current];

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  bool _stale(int g) => g != gen || disposed || !mounted;

  void _newGame() {
    gen++;
    game = Game(widget.players.length);
    viz = List<int>.filled(widget.players.length, garagePos);
    focus = 0;
    revealedIndex = null;
    revealedValue = null;
    busy = false;
    paused = false;
    message = L10n.tr('turn_of', {'name': widget.players[0].name});
    final g = gen;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_stale(g)) _maybeAi();
    });
  }

  Future<void> _wait(int ms) => Future.delayed(Duration(milliseconds: ms));

  Future<void> _waitWhilePaused() async {
    while (paused && !disposed) {
      await _wait(100);
    }
  }

  Future<void> _maybeAi() async {
    final g = gen;
    if (_stale(g) || game.winner != null) return;
    if (!currentPlayer.isAi) return;
    setState(() => busy = true);
    await _wait(900);
    await _waitWhilePaused();
    if (_stale(g)) return;
    await _playBox(ai.chooseBox());
  }

  void _onBoxTap(int i) {
    if (busy || game.winner != null || currentPlayer.isAi) return;
    _playBox(i);
  }

  Future<void> _playBox(int index) async {
    final g = gen;
    setState(() {
      busy = true;
      focus = game.current;
      revealedIndex = index;
      revealedValue = game.boxes[index];
    });
    await _wait(700);
    await _waitWhilePaused();
    if (_stale(g)) return;

    final ev = game.play(index);
    final name = widget.players[ev.player].name;

    // Déplacement case par case
    if (ev.exited) {
      setState(() => viz[ev.player] = 1);
      await _wait(350);
    } else if (ev.moved) {
      for (var c = ev.from + 1; c <= ev.to; c++) {
        if (_stale(g)) return;
        setState(() => viz[ev.player] = c);
        await _wait(150);
      }
    }
    if (_stale(g)) return;

    // Effets et message
    var msg = '';
    if (ev.win) {
      // pas de message : écran de victoire
    } else if (ev.pra) {
      msg = L10n.tr('msg_pra', {'name': name});
      setState(() => message = msg);
      await _wait(900);
      if (_stale(g)) return;
      setState(() => viz[ev.player] = garagePos);
    } else if (ev.captured.isNotEmpty) {
      final other = widget.players[ev.captured.first].name;
      msg = L10n.tr('msg_capture', {'name': name, 'other': other});
      setState(() {
        message = msg;
        for (final q in ev.captured) {
          viz[q] = garagePos;
        }
      });
    } else if (ev.exited) {
      msg = L10n.tr('msg_exit', {'name': name});
      setState(() => message = msg);
    } else if (ev.noSix) {
      msg = L10n.tr('msg_no_six', {'name': name});
      setState(() => message = msg);
    } else if (ev.blocked) {
      msg = L10n.tr('msg_blocked', {'name': name, 'n': '${ev.remaining}'});
      setState(() => message = msg);
    } else {
      msg = L10n.tr(ev.replay ? 'msg_move_replay' : 'msg_move',
          {'name': name, 'n': '${ev.value}'});
      setState(() => message = msg);
    }

    await _wait(ev.win ? 300 : 1100);
    await _waitWhilePaused();
    if (_stale(g)) return;

    if (game.winner != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) =>
            VictoryScreen(players: widget.players, winner: game.winner!),
      ));
      return;
    }

    setState(() {
      revealedIndex = null;
      revealedValue = null;
      busy = false;
      focus = game.current;
      message = L10n.tr('turn_of', {'name': currentPlayer.name});
    });
    _maybeAi();
  }

  Future<void> _pause() async {
    setState(() => paused = true);
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.tr('pause')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BigButton(
              label: L10n.tr('resume'),
              onTap: () => Navigator.pop(ctx, 'resume'),
            ),
            const SizedBox(height: 10),
            BigButton(
              label: L10n.tr('restart'),
              color: AppColors.green,
              onTap: () => Navigator.pop(ctx, 'restart'),
            ),
            const SizedBox(height: 10),
            BigButton(
              label: L10n.tr('quit'),
              color: const Color(0xFF8A8A8A),
              onTap: () => Navigator.pop(ctx, 'quit'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'restart') {
      setState(_newGame);
    } else if (action == 'quit') {
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      setState(() => paused = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _pause();
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: RouteBoard(
                      positions: viz,
                      players: widget.players,
                      current: focus,
                      focus: focus,
                    ),
                  ),
                ),
              ),
              _bottomPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.pause_circle_filled_rounded,
                size: 32, color: AppColors.green),
            onPressed: _pause,
          ),
          for (var i = 0; i < widget.players.length; i++)
            Expanded(child: _playerChip(i)),
        ],
      ),
    );
  }

  Widget _playerChip(int i) {
    final p = widget.players[i];
    // `focus` = joueur qui agit : il ne change qu'une fois le résultat affiché.
    final active = i == focus;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.color.main.withAlpha(active ? 70 : 25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? AppColors.ink : Colors.transparent,
          width: 2.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BusIcon(color: p.color.main, dark: p.color.dark, width: 26),
          Text(
            p.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w900 : FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: viz[i] / goalPos,
              minHeight: 5,
              color: p.color.main,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomPanel() {
    final p = widget.players[focus];
    final canTap = !busy && game.winner == null && !p.isAi;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < 3; i++) _boxCard(i, p, canTap),
            ],
          ),
          const SizedBox(height: 8),
          // L'invite « Choisis une box » disparaît pendant que le résultat s'affiche.
          Opacity(
            opacity: (busy && !p.isAi) ? 0.0 : 1.0,
            child: Text(
              p.isAi
                  ? L10n.tr('computer_choosing', {'name': p.name})
                  : L10n.tr('pick_box'),
              style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _boxCard(int i, PlayerConfig p, bool canTap) {
    final isRevealed = revealedIndex == i;
    final dimmed = revealedIndex != null && !isRevealed;
    final value = isRevealed ? (revealedValue ?? 0) : 0;
    return GestureDetector(
      onTap: canTap ? () => _onBoxTap(i) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: dimmed ? 0.5 : 1,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: isRevealed ? 1 : 0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOut,
          builder: (context, t, _) {
            final showValue = t > 0.5;
            final lift = sin(t * pi) * 10;
            return Transform.translate(
              offset: Offset(0, -lift),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateY(t * pi),
                child: showValue
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: _cubeFace(p, '$value', true),
                      )
                    : _cubeFace(p, '?', false),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Face d'une box : bloc en relief (face, tranche sombre, reflet).
  Widget _cubeFace(PlayerConfig p, String text, bool revealed) {
    final face = revealed ? Colors.white : p.color.main;
    final faceLight = revealed
        ? const Color(0xFFFFF3D6)
        : Color.lerp(p.color.main, Colors.white, 0.35)!;
    return SizedBox(
      width: 88,
      height: 96,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 88,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: p.color.dark,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 8,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 88,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [faceLight, face],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.color.dark, width: 3),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: revealed ? p.color.dark : Colors.white,
                    shadows: const [
                      Shadow(
                        color: Color(0x55000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 6,
            width: 40,
            height: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x55FFFFFF),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
