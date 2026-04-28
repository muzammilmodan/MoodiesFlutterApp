part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class GameStarted extends GameEvent {
  final int numberOfPlayers;
  const GameStarted({this.numberOfPlayers = 2});
  @override
  List<Object?> get props => [numberOfPlayers];
}

class DiceRolled extends GameEvent {
  const DiceRolled();
}

class GameReset extends GameEvent {
  const GameReset();
}
