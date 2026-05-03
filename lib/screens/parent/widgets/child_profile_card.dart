


// ---------------------------------------------------------------------------
// Child profile card
// ---------------------------------------------------------------------------
import 'package:flutter/material.dart';

import 'dashboard_data.dart';

class ChildProfileCard extends StatelessWidget {
  final DashboardData data;
  const ChildProfileCard({required this.data});

  static const _tealLight  = Color(0xFFE1F5EE);
  static const _tealMid    = Color(0xFF9FE1CB);
  static const _tealDark   = Color(0xFF085041);
  static const _tealAction = Color(0xFF0F6E56);

  @override
  Widget build(BuildContext context) {
    final hasMood = data.todayMood.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _tealLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: _tealMid,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🧒', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),

          // Name + mood
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.childAge > 0
                      ? '${data.childName}, age ${data.childAge}'
                      : data.childName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _tealDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      "Today's mood: ",
                      style: TextStyle(fontSize: 12, color: _tealAction),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _tealMid,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hasMood
                            ? '${data.moodEmoji} ${data.todayMood}'
                            : 'Not logged yet',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _tealDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Streak
          if (data.streakDays > 0)
            Column(
              children: [
                Text(
                  '🔥 ${data.streakDays}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _tealDark,
                  ),
                ),
                const Text(
                  'day streak',
                  style: TextStyle(fontSize: 11, color: _tealAction),
                ),
              ],
            ),
        ],
      ),
    );
  }
}