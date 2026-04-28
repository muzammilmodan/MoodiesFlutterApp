import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';
import '../widgets/board_widget.dart';
import '../widgets/dice_widget.dart';
import '../widgets/player_info_widget.dart';

/// FIX: GameScreen now owns its own BlocProvider.
/// This means it works correctly when navigated to from ANY route —
/// including from MoodiesApp via Navigator.push — without needing
/// a BlocProvider higher up in the tree.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(),
      child: const _GameScreenBody(), // ← separate widget so its context is BELOW the provider
    );
  }
}

/// Private widget. Its BuildContext is a child of BlocProvider<GameBloc>,
/// so every BlocBuilder / context.read<GameBloc>() inside works correctly.
class _GameScreenBody extends StatelessWidget {
  const _GameScreenBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text(
          'Snakes & Ladders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              if (state.status == GameStatus.initial) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    context.read<GameBloc>().add(const GameReset()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state.status == GameStatus.initial) {
            return const _SetupScreen();
          }
          return const _GameView();
        },
      ),
    );
  }
}

class _SetupScreen extends StatelessWidget {
  const _SetupScreen();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🐍🪜', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            const Text(
              'Snakes & Ladders',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'How many players?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ...List.generate(3, (i) {
              final count = i + 2;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context
                        .read<GameBloc>()
                        .add(GameStarted(numberOfPlayers: count)),
                    child: Text(
                      '$count Players',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 8),
        PlayerInfoWidget(),
        SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: BoardWidget(),
          ),
        ),
        SizedBox(height: 12),
        _MessageBanner(),
        SizedBox(height: 12),
        DiceWidget(),
        SizedBox(height: 16),
        _WinBanner(),
      ],
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state.message.isEmpty) return const SizedBox();
        Color bgColor;
        switch (state.status) {
          case GameStatus.snakeBite:
            bgColor = Colors.red.shade100;
            break;
          case GameStatus.ladderClimb:
            bgColor = Colors.green.shade100;
            break;
          default:
            bgColor = Colors.deepPurple.shade50;
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            state.message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        );
      },
    );
  }
}

class _WinBanner extends StatelessWidget {
  const _WinBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (!state.gameOver) return const SizedBox();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade400),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    state.message.replaceAll('🎉 ', ''),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<GameBloc>().add(const GameReset()),
                    child: const Text('Play Again'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
