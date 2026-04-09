// lib/screens/awards_screen.dart

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/common_widgets.dart';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  final _svc = FirebaseService();
  int _totalMoods = 0;
  bool _loading   = true;

  // Static awards definition
  final List<Map<String, dynamic>> _all = [
    {'title': 'First Check In',   'desc': 'Logged your first mood',          'icon': '🌟', 'req': 1},
    {'title': 'Mood Explorer',    'desc': 'Logged 5 moods',                  'icon': '🔍', 'req': 5},
    {'title': 'Happy Week',       'desc': 'Logged 7 moods',                  'icon': '😊', 'req': 7},
    {'title': 'Mood Master',      'desc': 'Logged 10 moods',                 'icon': '🏆', 'req': 10},
    {'title': 'Feelings Champion','desc': 'Logged 20 moods',                 'icon': '🎖️', 'req': 20},
    {'title': 'Puzzle Lover',     'desc': 'Keep playing puzzles!',           'icon': '🧩', 'req': 0},
    {'title': 'Artist',           'desc': 'Explored the Color Pages',        'icon': '🎨', 'req': 0},
    {'title': 'Music Fan',        'desc': 'Listened to Chill Music',         'icon': '🎵', 'req': 0},
    {'title': 'Planner Pro',      'desc': 'Used the Planner feature',        'icon': '📅', 'req': 0},
  ];

  @override
  void initState() {
    super.initState();
    _loadMoodCount();
  }

  Future<void> _loadMoodCount() async {
    try {
      final moods = await _svc.getMoods();
      if (mounted) setState(() { _totalMoods = moods.length; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _unlocked(Map<String, dynamic> award) {
    final req = award['req'] as int;
    if (req == 0) return true; // activity-based, always show unlocked
    return _totalMoods >= req;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Awards 🏆')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAppBg))
          : Column(
              children: [
                // Progress banner
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Text('🌈',
                          style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Keep going!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text('$_totalMoods moods logged so far',
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: _all.length,
                    itemBuilder: (_, i) {
                      final a        = _all[i];
                      final isUnlocked = _unlocked(a);
                      return AnimatedOpacity(
                        opacity: isUnlocked ? 1.0 : 0.45,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isUnlocked
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF4DB6AC),
                                      Color(0xFF26A69A)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isUnlocked ? null : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isUnlocked
                                ? [
                                    BoxShadow(
                                      color: kAppBg.withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isUnlocked ? a['icon'] : '🔒',
                                  style: const TextStyle(fontSize: 38),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  a['title'],
                                  style: TextStyle(
                                    color: isUnlocked
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  a['req'] > 0 && !isUnlocked
                                      ? 'Log ${a['req']} moods to unlock'
                                      : a['desc'],
                                  style: TextStyle(
                                    color: isUnlocked
                                        ? Colors.white70
                                        : Colors.grey,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
