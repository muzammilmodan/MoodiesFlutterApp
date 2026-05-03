
// ---------------------------------------------------------------------------
// Stat card
// ---------------------------------------------------------------------------
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color cardColor;

  const StatCard({required this.value, required this.label, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w600, height: 1.1)),
          const SizedBox(height: 4),
          Text(label,
              style:
              const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
