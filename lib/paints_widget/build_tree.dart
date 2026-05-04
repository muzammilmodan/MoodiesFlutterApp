
import 'package:flutter/material.dart';

Widget buildTree({required double height, required Color trunkColor}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: height * 0.6,
        height: height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF7DC35B),
          shape: BoxShape.circle,
        ),
      ),
      Container(
        width: 6,
        height: height * 0.35,
        decoration: BoxDecoration(
          color: trunkColor,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    ],
  );
}
