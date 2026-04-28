import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game/game_bloc.dart';

class DiceWidget extends StatefulWidget {
  const DiceWidget({super.key});

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rotationAnim = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _roll(BuildContext context) {
    _controller.forward(from: 0);
    context.read<GameBloc>().add(const DiceRolled());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final canRoll = state.status == GameStatus.playing &&
            !state.isRolling &&
            !state.gameOver;

        return Column(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (ctx, child) {
                return Transform.scale(
                  scale: _scaleAnim.value,
                  child: Transform.rotate(
                    angle: _rotationAnim.value * 3.14159,
                    child: child,
                  ),
                );
              },
              child: GestureDetector(
                onTap: canRoll ? () => _roll(context) : null,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: canRoll ? Colors.white : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: canRoll ? Colors.deepPurple : Colors.grey,
                      width: 2,
                    ),
                    boxShadow: canRoll
                        ? [
                            const BoxShadow(
                              color: Colors.deepPurple,
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            )
                          ]
                        : [],
                  ),
                  child: _DiceFace(value: state.diceValue),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.isRolling ? 'Rolling...' : (canRoll ? 'Tap to roll' : ''),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DiceFace extends StatelessWidget {
  final int value;
  const _DiceFace({required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: _buildDots(value),
    );
  }

  Widget _buildDots(int val) {
    const dot = _Dot();
    const empty = SizedBox(width: 12, height: 12);

    final faces = {
      1: [
        [empty, empty, empty],
        [empty, dot, empty],
        [empty, empty, empty],
      ],
      2: [
        [dot, empty, empty],
        [empty, empty, empty],
        [empty, empty, dot],
      ],
      3: [
        [dot, empty, empty],
        [empty, dot, empty],
        [empty, empty, dot],
      ],
      4: [
        [dot, empty, dot],
        [empty, empty, empty],
        [dot, empty, dot],
      ],
      5: [
        [dot, empty, dot],
        [empty, dot, empty],
        [dot, empty, dot],
      ],
      6: [
        [dot, empty, dot],
        [dot, empty, dot],
        [dot, empty, dot],
      ],
    };

    final rows = faces[val] ?? faces[1]!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: rows
          .map((row) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row,
              ))
          .toList(),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        shape: BoxShape.circle,
      ),
    );
  }
}
