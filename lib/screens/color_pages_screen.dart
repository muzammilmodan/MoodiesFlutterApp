// lib/screens/color_pages_screen.dart

import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class ColorPagesScreen extends StatefulWidget {
  const ColorPagesScreen({super.key});

  @override
  State<ColorPagesScreen> createState() => _ColorPagesScreenState();
}

class _ColorPagesScreenState extends State<ColorPagesScreen> {
  Color  _color       = Colors.black;
  double _stroke      = 5.0;
  bool   _isEraser    = false;
  final List<_Stroke> _strokes = [];
  List<Offset?> _current = [];

  final List<Color> _palette = [
    Colors.black, Colors.white,
    const Color(0xFFE53935), const Color(0xFFD81B60),
    const Color(0xFF8E24AA), const Color(0xFF3949AB),
    const Color(0xFF1E88E5), const Color(0xFF00ACC1),
    const Color(0xFF43A047), const Color(0xFFC0CA33),
    const Color(0xFFFDD835), const Color(0xFFFFB300),
    const Color(0xFFFB8C00), const Color(0xFF6D4C41),
  ];

  void _undo() {
    if (_strokes.isNotEmpty) setState(() => _strokes.removeLast());
  }

  void _clear() {
    setState(() { _strokes.clear(); _current.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Pages 🎨'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _undo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear',
            onPressed: _clear,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Canvas ─────────────────────────────────────────────────────
          Expanded(
            child: Container(
              color: Colors.white,
              child: GestureDetector(
                onPanStart: (d) {
                  setState(() => _current = [d.localPosition]);
                },
                onPanUpdate: (d) {
                  setState(() => _current.add(d.localPosition));
                },
                onPanEnd: (_) {
                  setState(() {
                    _strokes.add(_Stroke(
                      points:      List.from(_current),
                      color:       _isEraser ? Colors.white : _color,
                      strokeWidth: _isEraser ? 24.0 : _stroke,
                    ));
                    _current.clear();
                  });
                },
                child: CustomPaint(
                  painter: _CanvasPainter(_strokes, _current,
                      _isEraser ? Colors.white : _color, _stroke),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          // ── Toolbar ────────────────────────────────────────────────────
          Container(
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Colour palette
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Eraser toggle
                      GestureDetector(
                        onTap: () => setState(() => _isEraser = !_isEraser),
                        child: Container(
                          width: 38, height: 38,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _isEraser ? kAppBg : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isEraser ? kAppBg : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: Icon(Icons.auto_fix_high,
                              size: 18,
                              color: _isEraser ? Colors.white : Colors.grey),
                        ),
                      ),
                      // Colour swatches
                      ..._palette.map((c) {
                        final sel = !_isEraser && c == _color;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _color    = c;
                            _isEraser = false;
                          }),
                          child: Container(
                            width: 38, height: 38,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: sel ? kAppBg : Colors.grey.shade300,
                                width: sel ? 3 : 1,
                              ),
                              boxShadow: sel
                                  ? [BoxShadow(
                                      color: c.withOpacity(0.5),
                                      blurRadius: 6)]
                                  : [],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Brush size
                Row(
                  children: [
                    const Icon(Icons.brush, color: Colors.grey, size: 18),
                    Expanded(
                      child: Slider(
                        value: _stroke,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        activeColor: kAppBg,
                        onChanged: (v) => setState(() {
                          _stroke   = v;
                          _isEraser = false;
                        }),
                      ),
                    ),
                    Text('${_stroke.toInt()}px',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stroke {
  final List<Offset?> points;
  final Color  color;
  final double strokeWidth;
  _Stroke({required this.points, required this.color, required this.strokeWidth});
}

class _CanvasPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final List<Offset?> current;
  final Color  liveColor;
  final double liveWidth;

  _CanvasPainter(this.strokes, this.current, this.liveColor, this.liveWidth);

  void _drawPoints(Canvas c, List<Offset?> pts, Paint p) {
    for (int i = 0; i < pts.length - 1; i++) {
      final a = pts[i]; final b = pts[i + 1];
      if (a != null && b != null) c.drawLine(a, b, p);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final p = Paint()
        ..color      = s.color
        ..strokeWidth = s.strokeWidth
        ..strokeCap  = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      _drawPoints(canvas, s.points, p);
    }
    if (current.isNotEmpty) {
      final p = Paint()
        ..color      = liveColor
        ..strokeWidth = liveWidth
        ..strokeCap  = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      _drawPoints(canvas, current, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
