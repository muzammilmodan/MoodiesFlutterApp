import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../models/player.dart';
import '../utils/constants.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  /// Convert GridView index (0-99) to board cell number (1-100)
  /// Row 0 of grid = row 9 of board (numbers 91-100)
  /// Zigzag: even board rows go left→right, odd go right→left
  int _cellNumber(int index) {
    int row = index ~/ 10;         // 0 = top of grid
    int col = index % 10;
    int boardRow = 9 - row;        // flip: top of grid = row 9 of board
    if (boardRow % 2 == 0) {
      col = col;                   // left to right
    } else {
      col = 9 - col;               // right to left
    }
    return boardRow * 10 + col + 1;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.brown.shade400, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: kGridCount,
              ),
              itemCount: kBoardSize,
              itemBuilder: (ctx, index) {
                final cellNum = _cellNumber(index);
                final playersHere = state.players
                    .where((p) => p.position == cellNum)
                    .toList();
                return _CellWidget(
                  cellNumber: cellNum,
                  players: playersHere,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _CellWidget extends StatelessWidget {
  final int cellNumber;
  final List<Player> players;

  const _CellWidget({required this.cellNumber, required this.players});

  Color _cellColor() {
    if (kSnakes.containsKey(cellNumber)) return const Color(0xFFFFCDD2);
    if (kLadders.containsKey(cellNumber)) return const Color(0xFFC8E6C9);
    return cellNumber % 2 == 0
        ? const Color(0xFFFFF9C4)
        : const Color(0xFFFFFFFF);
  }

  String _cellIcon() {
    if (kSnakes.containsKey(cellNumber)) return '🐍';
    if (kLadders.containsKey(cellNumber)) return '🪜';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cellColor(),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cell number
          Positioned(
            top: 1,
            left: 2,
            child: Text(
              '$cellNumber',
              style: const TextStyle(fontSize: 7, color: Colors.black54),
            ),
          ),
          // Snake or ladder icon
          if (_cellIcon().isNotEmpty)
            Center(
              child: Text(_cellIcon(), style: const TextStyle(fontSize: 10)),
            ),
          // Player tokens
          if (players.isNotEmpty)
            Center(
              child: Wrap(
                spacing: 1,
                children: players.map((p) => _PlayerDot(player: p)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerDot extends StatelessWidget {
  final Player player;
  const _PlayerDot({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: player.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
      ),
    );
  }
}
