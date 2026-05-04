
// ──────────────────────────────────────────────
//  LOGO
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../screens/abc_game/utils/app_theme.dart';

Widget buildLogo() {
  final letters = [
    ('M', const Color(0xFF4ECDC4)),
    ('o', const Color(0xFFFF6B9D)),
    ('o', const Color(0xFFFFB347)),
    ('d', const Color(0xFF4ECDC4)),
    ('i', const Color(0xFFFF6B9D)),
    ('e', const Color(0xFFFFB347)),
    ('s', const Color(0xFF6C63FF)),
  ];

  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ...letters.map(
            (e) => Text(
          e.$1,
          style: TextStyle(
            fontFamily: FontName.ChocoCooky,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: e.$2,
            height: 1.1,
          ),
        ),
      ),
      const SizedBox(width: 2),
      // Heart icon
      const Icon(
        Icons.favorite,
        color: Color(0xFFFF6B9D),
        size: 18,
      ),
    ],
  );
}