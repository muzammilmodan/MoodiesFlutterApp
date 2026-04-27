import 'dart:math';
import 'package:flutter/material.dart';

import 'GradientText.dart';

class CurvedMoodiesText extends StatefulWidget {
  const CurvedMoodiesText({super.key});

  @override
  State<CurvedMoodiesText> createState() => _CurvedMoodiesTextState();
}

class _CurvedMoodiesTextState extends State<CurvedMoodiesText>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  final String text = "MOODIES";
  final double radius = 120;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 1.5,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(text.length, (index) {
              final progress = controller.value;
              final angleBase =
                  (index - (text.length - 1) / 2) * (pi / 8);

              // 👇 animate left → right
              final animatedAngle = angleBase * progress;

              return Transform.rotate(
                angle: animatedAngle,
                child: Transform.translate(
                  offset: const Offset(0, -120),
                  child: Opacity(
                    opacity: progress,
                    child: GradientText(
                      text[index],
                      size: 30,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}