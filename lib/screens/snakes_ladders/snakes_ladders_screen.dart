import 'package:flutter/material.dart';
import 'package:moodiesapp/screens/snakes_ladders/screens/game_screen.dart';

/// FIX: SnakesAndLaddersApp no longer wraps MaterialApp or provides BlocProvider.
/// GameScreen is now self-contained — it creates its own BlocProvider internally.
///
/// Navigate to the game from ANYWHERE in MoodiesApp like this:
///
///   Navigator.push(
///     context,
///     MaterialPageRoute(builder: (_) => const GameScreen()),
///   );
///
/// No BlocProvider needed at the call site.
///
/// If you want a standalone entry point for testing only, use this widget:
class SnakesAndLaddersApp extends StatelessWidget {
  const SnakesAndLaddersApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GameScreen owns its own BlocProvider — no need to wrap here.
    return const GameScreen();
  }
}
