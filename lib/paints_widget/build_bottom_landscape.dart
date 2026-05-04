

// ──────────────────────────────────────────────
//  BOTTOM LANDSCAPE
// ──────────────────────────────────────────────
import 'package:flutter/cupertino.dart';
import 'package:moodiesapp/paints_widget/rainbow_painter.dart';

import 'build_flower.dart';
import 'build_tree.dart';
import 'landscape_painter.dart';

Widget buildBottomLandscape() {
  return SizedBox(
    height: 120,
    child: CustomPaint(
      painter: LandscapePainter(),
      child: Stack(
        children: [
          // Rainbow
          Positioned(
            bottom: 40,
            right: 60,
            child: CustomPaint(
              size: const Size(70, 40),
              painter: RainbowPainter(),
            ),
          ),
          // Trees
          Positioned(
            bottom: 30,
            left: 20,
            child: buildTree(height: 55, trunkColor: const Color(0xFF8B5E3C)),
          ),
          Positioned(
            bottom: 30,
            left: 60,
            child: buildTree(height: 42, trunkColor: const Color(0xFF8B5E3C)),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: buildTree(height: 50, trunkColor: const Color(0xFF8B5E3C)),
          ),
          // Flowers
          Positioned(
            bottom: 22,
            left: 100,
            child: buildFlower(const Color(0xFFFFB3D1)),
          ),
          Positioned(
            bottom: 20,
            right: 100,
            child: buildFlower(const Color(0xFFFFF3B0)),
          ),
          Positioned(
            bottom: 18,
            right: 130,
            child: buildFlower(const Color(0xFFFFB3D1)),
          ),
        ],
      ),
    ),
  );
}