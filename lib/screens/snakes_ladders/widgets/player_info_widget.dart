import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';

class PlayerInfoWidget extends StatelessWidget {
  const PlayerInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(state.players.length, (i) {
            final player = state.players[i];
            final isCurrent = i == state.currentPlayerIndex && !state.gameOver;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCurrent
                    ? player.color.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent ? player.color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: player.color,
                    radius: 16,
                    child: Text(
                      player.name[0],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(player.name,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  Text('Pos: ${player.position}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
