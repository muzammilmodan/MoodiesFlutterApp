// lib/screens/parents_mood_list_screen.dart

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class ParentsMoodListScreen extends StatefulWidget {
  const ParentsMoodListScreen({super.key});

  @override
  State<ParentsMoodListScreen> createState() =>
      _ParentsMoodListScreenState();
}

class _ParentsMoodListScreenState extends State<ParentsMoodListScreen> {
  final _svc = FirebaseService();
  List<MoodModel> _moods   = [];
  bool   _loading          = true;
  String _childName        = '';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      // Get the linked child's UID from parent profile
      final childUid = await _svc.getLinkedChildUid();
      if (childUid == null || childUid.isEmpty) {
        // If no child linked yet, show empty state
        if (mounted) setState(() => _loading = false);
        return;
      }

      // Fetch child name
      final childProfile =
          await _svc.getUserProfile(); // own profile (to get the name if needed)
      // Actually fetch child's profile from Firestore directly
      final childDoc = await _svc.getUserProfile();

      // Fetch child's moods
      final moods = await _svc.getChildMoods(childUid);
      if (mounted) {
        setState(() {
          _moods    = moods;
          _loading  = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── color & icon per mood ───────────────────────────────────────────────
  Color _color(String m) {
    switch (m.toLowerCase()) {
      case 'happy':
      case 'excited':
      case 'loved':
        return Colors.green;
      case 'sad':
      case 'scared':
      case 'worried':
        return Colors.blueAccent;
      case 'mad':
        return Colors.redAccent;
      case 'tired':
        return Colors.orange;
      case 'comfortable':
      case 'safe':
        return Colors.teal;
      default:
        return kAppBg;
    }
  }

  IconData _icon(String m) {
    switch (m.toLowerCase()) {
      case 'happy':   return Icons.sentiment_very_satisfied;
      case 'sad':     return Icons.sentiment_dissatisfied;
      case 'mad':     return Icons.sentiment_very_dissatisfied;
      case 'excited': return Icons.celebration;
      case 'scared':  return Icons.warning_amber;
      case 'tired':   return Icons.bedtime;
      case 'loved':   return Icons.favorite;
      case 'smart':   return Icons.lightbulb;
      default:        return Icons.mood;
    }
  }

  // ── mood frequency summary ──────────────────────────────────────────────
  Widget _summary() {
    if (_moods.isEmpty) return const SizedBox();
    final freq = <String, int>{};
    for (final m in _moods) {
      freq[m.mood] = (freq[m.mood] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(3).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Most Frequent Moods',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            ...top.map((e) {
              final pct = e.value / _moods.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _color(e.key),
                      child: Icon(_icon(e.key), color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text('${e.value}x',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: pct,
                            backgroundColor: Colors.grey.shade200,
                            color: _color(e.key),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Child's Mood History")),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAppBg))
          : _moods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mood_bad, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No mood records found',
                          style: TextStyle(
                              color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text(
                          'Your child hasn\'t logged any moods yet.',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _summary(),
                    const Text('All Records',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 10),
                    ..._moods.map(
                      (m) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _color(m.mood),
                            child: Icon(_icon(m.mood), color: Colors.white),
                          ),
                          title: Text(m.mood,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          trailing: Text(
                            m.formattedDate,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
