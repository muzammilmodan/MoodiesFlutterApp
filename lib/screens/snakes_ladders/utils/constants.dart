import 'package:flutter/material.dart';

// Snake positions: head -> tail
const Map<int, int> kSnakes = {
  17: 7,
  32: 10,
  54: 34,
  62: 19,
  64: 60,
  87: 24,
  93: 73,
  95: 75,
  99: 78,
};

// Ladder positions: base -> top
const Map<int, int> kLadders = {
  4: 14,
  9: 31,
  20: 38,
  28: 84,
  40: 59,
  51: 67,
  63: 81,
  71: 91,
};

const int kBoardSize = 100;
const int kGridCount = 10;

const List<Color> kPlayerColors = [
  Color(0xFF2196F3),
  Color(0xFFE91E63),
  Color(0xFF4CAF50),
  Color(0xFFFF9800),
];

const List<String> kPlayerNames = ['Player 1', 'Player 2', 'Player 3', 'Player 4'];
