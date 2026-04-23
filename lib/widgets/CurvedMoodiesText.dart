import 'dart:math';
import 'package:flutter/material.dart';

import 'GradientText.dart';

class CurvedMoodiesText extends StatelessWidget {
  const CurvedMoodiesText({super.key});

  @override
  Widget build(BuildContext context) {
    const text = "MOODIES";
    const radius = 120.0;

    return SizedBox(
      width: radius * 2,
      height: radius * 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(text.length, (index) {
          final angle = (index - (text.length - 1) / 2) * (pi / 8);

          return Transform.rotate(
            angle: angle,
            child: Transform.translate(
              offset: const Offset(0, -radius),
              child: GradientText(
                text[index],
                size: 28,
              ),
            ),
          );
        }),
      ),
    );
  }
}