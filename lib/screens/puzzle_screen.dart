// lib/screens/puzzle_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  static const int _n = 3; // 3×3 grid

  late List<int> _tiles;
  bool _solved = false;
  int  _moves  = 0;
  int  _best   = 0;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _tiles  = List.generate(_n * _n, (i) => i);
    _solved = false;
    _moves  = 0;
    _shuffle();
    setState(() {});
  }

  void _shuffle() {
    final rng = Random();
    // Make 200 random valid moves to ensure solvability
    for (int k = 0; k < 200; k++) {
      final blank = _tiles.indexOf(0);
      final bRow  = blank ~/ _n;
      final bCol  = blank  % _n;
      final moves = <int>[];
      if (bRow > 0) moves.add(blank - _n);
      if (bRow < _n - 1) moves.add(blank + _n);
      if (bCol > 0) moves.add(blank - 1);
      if (bCol < _n - 1) moves.add(blank + 1);
      final pick = moves[rng.nextInt(moves.length)];
      final tmp  = _tiles[blank];
      _tiles[blank] = _tiles[pick];
      _tiles[pick]  = tmp;
    }
  }

  void _tap(int idx) {
    if (_solved) return;
    final blank = _tiles.indexOf(0);
    final bRow  = blank ~/ _n;
    final bCol  = blank  % _n;
    final tRow  = idx   ~/ _n;
    final tCol  = idx    % _n;

    final adjacent = (tRow == bRow && (tCol - bCol).abs() == 1) ||
                     (tCol == bCol && (tRow - bRow).abs() == 1);
    if (!adjacent) return;

    setState(() {
      _tiles[blank] = _tiles[idx];
      _tiles[idx]   = 0;
      _moves++;
      _check();
    });
  }

  void _check() {
    if (_tiles.join() == List.generate(_n * _n, (i) => i).join()) {
      _solved = true;
      if (_best == 0 || _moves < _best) _best = _moves;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('🎉 Puzzle Solved!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Moves: $_moves'),
                if (_best > 0) Text('Best: $_best moves'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () { Navigator.pop(context); _reset(); },
                child: const Text('Play Again'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  // Tile gradient colors
  final _colors = [
    [const Color(0xFF4DB6AC), const Color(0xFF26A69A)],
    [const Color(0xFF66BB6A), const Color(0xFF43A047)],
    [const Color(0xFF42A5F5), const Color(0xFF1E88E5)],
    [const Color(0xFFAB47BC), const Color(0xFF8E24AA)],
    [const Color(0xFFEF5350), const Color(0xFFE53935)],
    [const Color(0xFFFF7043), const Color(0xFFE64A19)],
    [const Color(0xFFFFCA28), const Color(0xFFFFB300)],
    [const Color(0xFF26C6DA), const Color(0xFF00ACC1)],
  ];

  @override
  Widget build(BuildContext context) {
    final size = (MediaQuery.of(context).size.width - 64) / _n;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Game 🧩'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'New Puzzle',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statCard('Moves', '$_moves', Icons.swipe),
                _statCard('Best',  _best == 0 ? '-' : '$_best', Icons.star),
                _statCard(
                  'Status',
                  _solved ? '✅' : '🎮',
                  _solved ? Icons.check_circle : Icons.play_circle,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Puzzle board
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _n,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemCount: _n * _n,
                itemBuilder: (_, i) {
                  final val = _tiles[i];
                  if (val == 0) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }
                  final c = _colors[(val - 1) % _colors.length];
                  return GestureDetector(
                    onTap: () => _tap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: c,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: c.first.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$val',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black26)
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),
            const Text(
              'Tap tiles next to the blank space to slide them.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: '🔀  New Puzzle',
              onTap: _reset,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6)
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: kAppBg, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      );
}
