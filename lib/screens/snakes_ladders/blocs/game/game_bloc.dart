import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../utils/constants.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final Random _random = Random();

  GameBloc() : super(const GameState()) {
    on<GameStarted>(_onGameStarted);
    on<DiceRolled>(_onDiceRolled);
    on<GameReset>(_onGameReset);
  }

  void _onGameStarted(GameStarted event, Emitter<GameState> emit) {
    final players = List.generate(
      event.numberOfPlayers,
      (i) => Player(
        id: 'player_$i',
        name: kPlayerNames[i],
        color: kPlayerColors[i],
        position: 0,
      ),
    );

    emit(state.copyWith(
      players: players,
      currentPlayerIndex: 0,
      diceValue: 1,
      status: GameStatus.playing,
      message: '${players[0].name}\'s turn — tap the dice!',
      isRolling: false,
    ));
  }

  Future<void> _onDiceRolled(DiceRolled event, Emitter<GameState> emit) async {
    if (state.gameOver || state.isRolling) return;

    emit(state.copyWith(isRolling: true));

    // Simulate dice roll animation delay
    await Future.delayed(const Duration(milliseconds: 600));

    final roll = _random.nextInt(6) + 1;
    final player = state.currentPlayer!;
    int newPos = player.position + roll;

    GameStatus newStatus = GameStatus.playing;
    String newMessage = '';
    int landingPos = newPos;

    if (newPos > kBoardSize) {
      newMessage = '${player.name} rolled $roll — needs exact roll to win!';
      landingPos = player.position; // stay put
    } else if (newPos == kBoardSize) {
      newStatus = GameStatus.won;
      newMessage = '🎉 ${player.name} wins the game!';
      landingPos = kBoardSize;
    } else {
      if (kSnakes.containsKey(newPos)) {
        landingPos = kSnakes[newPos]!;
        newStatus = GameStatus.snakeBite;
        newMessage =
            '🐍 Snake! ${player.name} slides from $newPos to $landingPos';
      } else if (kLadders.containsKey(newPos)) {
        landingPos = kLadders[newPos]!;
        newStatus = GameStatus.ladderClimb;
        newMessage =
            '🪜 Ladder! ${player.name} climbs from $newPos to $landingPos';
      } else {
        newMessage = '${player.name} moved to $landingPos';
      }
    }

    final updatedPlayers = List<Player>.from(state.players);
    updatedPlayers[state.currentPlayerIndex] =
        player.copyWith(position: landingPos);

    int nextIndex = state.currentPlayerIndex;
    if (newStatus != GameStatus.won) {
      nextIndex = (state.currentPlayerIndex + 1) % state.players.length;
      if (newStatus == GameStatus.playing) {
        newMessage += '\n${updatedPlayers[nextIndex].name}\'s turn!';
      }
    }

    emit(state.copyWith(
      players: updatedPlayers,
      diceValue: roll,
      currentPlayerIndex: nextIndex,
      status: newStatus,
      message: newMessage,
      isRolling: false,
    ));
  }

  void _onGameReset(GameReset event, Emitter<GameState> emit) {
    emit(const GameState());
  }
}
