import 'dart:math';

import 'package:flutter/material.dart';

import '../game_logic/engine.dart';
import '../models.dart';
import 'board_geometry.dart';
import 'board_painter.dart';
import 'bus_icon.dart';

/// Plateau défilant : la caméra suit le bus du joueur [focus].
class RouteBoard extends StatefulWidget {
  const RouteBoard({
    super.key,
    required this.positions,
    required this.players,
    required this.current,
    required this.focus,
  });

  final List<int> positions;
  final List<PlayerConfig> players;
  final int current;
  final int focus;

  @override
  State<RouteBoard> createState() => _RouteBoardState();
}

class _RouteBoardState extends State<RouteBoard> {
  final ScrollController _scroll = ScrollController();
  BoardGeometry? _geo;
  int _lastFocus = -1;
  int _lastPos = -2;

  @override
  void initState() {
    super.initState();
    _maybeFollow(jump: true);
  }

  @override
  void didUpdateWidget(covariant RouteBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeFollow();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybeFollow({bool jump = false}) {
    final f = widget.focus;
    final p = widget.positions[f];
    if (!jump && f == _lastFocus && p == _lastPos) return;
    _lastFocus = f;
    _lastPos = p;
    WidgetsBinding.instance.addPostFrameCallback((_) => _follow(jump: jump));
  }

  void _follow({bool jump = false}) {
    final g = _geo;
    if (!mounted || g == null || !_scroll.hasClients) return;
    final f = widget.focus;
    final y = g.cell(widget.positions[f], slot: f).dy;
    final pos = _scroll.position;
    final target = (y - pos.viewportDimension * 0.58)
        .clamp(0.0, pos.maxScrollExtent)
        .toDouble();
    if (jump) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final g = BoardGeometry(c.maxWidth);
      _geo = g;
      return Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            child: SizedBox(
              width: c.maxWidth,
              height: g.totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: BoardPainter(g),
                        isComplex: true,
                        willChange: false,
                      ),
                    ),
                  ),
                  ..._buses(g),
                ],
              ),
            ),
          ),
          Positioned(
            right: 3,
            top: 8,
            bottom: 8,
            width: 16,
            child: IgnorePointer(
              child: _Rail(positions: widget.positions, players: widget.players),
            ),
          ),
        ],
      );
    });
  }

  List<Widget> _buses(BoardGeometry g) {
    final n = widget.players.length;
    final busW = min(g.cellW * 1.75, 52.0);
    final spriteH = busW * 0.72 + 8;

    final order = List<int>.generate(n, (i) => i);
    order.sort((a, b) {
      final ya = g.cell(widget.positions[a], slot: a).dy;
      final yb = g.cell(widget.positions[b], slot: b).dy;
      final cmp = ya.compareTo(yb);
      if (cmp != 0) return cmp;
      return (a == widget.current ? 1 : 0) - (b == widget.current ? 1 : 0);
    });

    final out = <Widget>[];
    for (final i in order) {
      final pos = widget.positions[i];
      final center = g.cell(pos, slot: i);
      final same = [
        for (var j = 0; j < n; j++)
          if (pos != garagePos && widget.positions[j] == pos) j
      ];
      final rank = same.indexOf(i);
      final offY = same.length < 2
          ? 0.0
          : (rank - (same.length - 1) / 2) * spriteH * 0.5;
      final facingRight = pos == garagePos ? true : ((pos - 1) ~/ segLen).isEven;
      out.add(AnimatedPositioned(
        key: ValueKey('bus$i'),
        duration: const Duration(milliseconds: 140),
        left: center.dx - busW / 2,
        top: center.dy + 10 - spriteH + offY,
        width: busW,
        height: spriteH,
        child: _BusSprite(
          player: widget.players[i],
          width: busW,
          facingRight: facingRight,
          active: i == widget.current,
        ),
      ));
    }
    return out;
  }
}

/// Bus + ombre portée + anneau lumineux sous le bus actif.
class _BusSprite extends StatelessWidget {
  const _BusSprite({
    required this.player,
    required this.width,
    required this.facingRight,
    required this.active,
  });

  final PlayerConfig player;
  final double width;
  final bool facingRight;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final busH = width * 0.72;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: width * 0.04,
          right: width * 0.04,
          bottom: 0,
          height: 10,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x66000000),
            ),
          ),
        ),
        if (active)
          Positioned(
            left: -5,
            right: -5,
            bottom: -3,
            height: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x44FFFFFF),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        Positioned(
          left: 0,
          top: 0,
          width: width,
          height: busH,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(facingRight ? 1.0 : -1.0, 1.0, 1.0),
            child: BusIcon(
              color: player.color.main,
              dark: player.color.dark,
              width: width,
            ),
          ),
        ),
      ],
    );
  }
}

/// Mini-carte verticale : place de chaque bus entre le garage et G.
class _Rail extends StatelessWidget {
  const _Rail({required this.positions, required this.players});
  final List<int> positions;
  final List<PlayerConfig> players;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final trackH = c.maxHeight - 18;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 6,
            width: 4,
            top: 14,
            bottom: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x66000000),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: -2,
            child: Text(
              'G',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFC145),
                shadows: [Shadow(color: Color(0xAA000000), blurRadius: 3)],
              ),
            ),
          ),
          for (var i = 0; i < players.length; i++)
            Positioned(
              left: 1,
              width: 14,
              height: 14,
              bottom: 4 + (positions[i] / goalPos) * (trackH - 14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: players[i].color.main,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Color(0x66000000), blurRadius: 3),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}
