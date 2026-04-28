import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final Color color;
  final int position; // 0 = start, 100 = win

  const Player({
    required this.id,
    required this.name,
    required this.color,
    this.position = 0,
  });

  Player copyWith({int? position}) {
    return Player(
      id: id,
      name: name,
      color: color,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [id, name, color, position];
}
