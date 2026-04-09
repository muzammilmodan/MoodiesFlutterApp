// lib/screens/chill_music_screen.dart

import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class ChillMusicScreen extends StatefulWidget {
  const ChillMusicScreen({super.key});

  @override
  State<ChillMusicScreen> createState() => _ChillMusicScreenState();
}

class _ChillMusicScreenState extends State<ChillMusicScreen>
    with SingleTickerProviderStateMixin {
  int  _current  = -1;
  bool _playing  = false;
  late AnimationController _spin;

  final _tracks = [
    {'title': 'Morning Calm',    'artist': 'Relaxation',   'dur': '3:24', 'emoji': '🌅'},
    {'title': 'Soft Breeze',     'artist': 'Nature Sounds','dur': '4:12', 'emoji': '🌿'},
    {'title': 'Gentle Rain',     'artist': 'Ambient',      'dur': '5:00', 'emoji': '🌧️'},
    {'title': 'Forest Walk',     'artist': 'Nature',       'dur': '3:45', 'emoji': '🌲'},
    {'title': 'Ocean Waves',     'artist': 'Sea Sounds',   'dur': '6:10', 'emoji': '🌊'},
    {'title': 'Happy Kids',      'artist': 'Kids Music',   'dur': '2:30', 'emoji': '😊'},
    {'title': 'Dreamy Night',    'artist': 'Sleep Music',  'dur': '4:55', 'emoji': '🌙'},
    {'title': 'Sunny Day',       'artist': 'Pop',          'dur': '3:15', 'emoji': '☀️'},
    {'title': 'Butterfly Dance', 'artist': 'Classical',    'dur': '4:30', 'emoji': '🦋'},
  ];

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _spin.stop();
  }

  @override
  void dispose() { _spin.dispose(); super.dispose(); }

  void _playPause(int idx) {
    setState(() {
      if (_current == idx) {
        _playing = !_playing;
      } else {
        _current = idx;
        _playing = true;
      }
      _playing ? _spin.repeat() : _spin.stop();
    });
  }

  void _next() {
    if (_current < _tracks.length - 1) _playPause(_current + 1);
  }

  void _prev() {
    if (_current > 0) _playPause(_current - 1);
  }

  @override
  Widget build(BuildContext context) {
    final hasCurrent = _current >= 0;
    final track = hasCurrent ? _tracks[_current] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2027),
        title: const Text('Chill Music 🎵'),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Now playing panel ─────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasCurrent
                    ? [const Color(0xFF1A3A4A), const Color(0xFF0F2027)]
                    : [const Color(0xFF0F2027), const Color(0xFF0F2027)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Album art spinner
                RotationTransition(
                  turns: _spin,
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: hasCurrent
                            ? [kAppBg, const Color(0xFF00796B)]
                            : [Colors.grey.shade700, Colors.grey.shade800],
                      ),
                      boxShadow: hasCurrent && _playing
                          ? [BoxShadow(
                              color: kAppBg.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 4)]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        track?['emoji'] ?? '🎵',
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  track?['title'] ?? 'Select a track',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  track?['artist'] ?? '',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 16),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous,
                          color: Colors.white, size: 32),
                      onPressed: hasCurrent ? _prev : null,
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: hasCurrent ? () => _playPause(_current) : null,
                      child: Container(
                        width: 62, height: 62,
                        decoration: BoxDecoration(
                          color: hasCurrent ? kAppBg : Colors.grey,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: kAppBg.withOpacity(0.4),
                                blurRadius: 12)
                          ],
                        ),
                        child: Icon(
                          _playing ? Icons.pause : Icons.play_arrow,
                          color: Colors.white, size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.skip_next,
                          color: Colors.white, size: 32),
                      onPressed: hasCurrent ? _next : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Track list ────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _tracks.length,
              itemBuilder: (_, i) {
                final t      = _tracks[i];
                final active = i == _current;
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  tileColor: active
                      ? kAppBg.withOpacity(0.15)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  leading: CircleAvatar(
                    backgroundColor:
                        active ? kAppBg : const Color(0xFF1A3A4A),
                    child: Text(t['emoji']!,
                        style: const TextStyle(fontSize: 18)),
                  ),
                  title: Text(
                    t['title']!,
                    style: TextStyle(
                      color: active ? kAppBg : Colors.white,
                      fontWeight: active
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(t['artist']!,
                      style: const TextStyle(color: Colors.white38,
                          fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t['dur']!,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12)),
                      const SizedBox(width: 8),
                      Icon(
                        active && _playing
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        color: active ? kAppBg : Colors.white38,
                      ),
                    ],
                  ),
                  onTap: () => _playPause(i),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
