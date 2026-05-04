
import 'package:flutter/cupertino.dart';

class RainbowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFFB347),
      const Color(0xFFFFE66D),
      const Color(0xFF6BCB77),
      const Color(0xFF4D96FF),
      const Color(0xFFA855F7),
    ];

    final center = Offset(size.width / 2, size.height);
    final maxR = size.width / 2;

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;

      final r = maxR - i * 5.0;
      if (r <= 0) continue;

      final rect = Rect.fromCircle(center: center, radius: r);
      canvas.drawArc(rect, 3.14159, 3.14159, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}