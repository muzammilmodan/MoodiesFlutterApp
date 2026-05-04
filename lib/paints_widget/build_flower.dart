
import 'package:flutter/cupertino.dart';

Widget buildFlower(Color color) {
  return SizedBox(
    width: 16,
    height: 20,
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        // Petals
        ...List.generate(4, (i) {
          return Transform.rotate(
            angle: i * 3.14159 / 2,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
        // Center
        Center(
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE066),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Stem
        Positioned(
          bottom: 0,
          child: Container(
            width: 2,
            height: 8,
            color: const Color(0xFF7DC35B),
          ),
        ),
      ],
    ),
  );
}