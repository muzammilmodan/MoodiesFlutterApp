
// ─── Colorful Kids Menu Card ─────────────────────────────────────────────────

import 'package:flutter/material.dart';

class KidsMenuCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final String emoji;
  final Color cardColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const KidsMenuCard({
    required this.label,
    required this.subtitle,
    required this.emoji,
    required this.cardColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Emoji inside circular coloured bg
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'ChocoCooky',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'ChocoCooky',
                          fontSize: 13,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow circle
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}