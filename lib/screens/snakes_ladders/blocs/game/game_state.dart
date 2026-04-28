part of 'game_bloc.dart';

enum GameStatus { initial, playing, snakeBite, ladderClimb, won }

class GameState extends Equatable {
  final List<Player> players;
  final int currentPlayerIndex;
  final int diceValue;
  final GameStatus status;
  final String message;
  final bool isRolling;

  const GameState({
    this.players = const [],
    this.currentPlayerIndex = 0,
    this.diceValue = 1,
    this.status = GameStatus.initial,
    this.message = '',
    this.isRolling = false,
  });

  Player? get currentPlayer =>
      players.isNotEmpty ? players[currentPlayerIndex] : null;

  bool get gameOver => status == GameStatus.won;

  GameState copyWith({
    List<Player>? players,
    int? currentPlayerIndex,
    int? diceValue,
    GameStatus? status,
    String? message,
    bool? isRolling,
  }) {
    return GameState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      diceValue: diceValue ?? this.diceValue,
      status: status ?? this.status,
      message: message ?? this.message,
      isRolling: isRolling ?? this.isRolling,
    );
  }

  @override
  List<Object?> get props => [
        players,
        currentPlayerIndex,
        diceValue,
        status,
        message,
        isRolling,
      ];
}
