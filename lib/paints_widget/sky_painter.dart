
import 'package:flutter/cupertino.dart';

class SkyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD6EEFF).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Cloud 1
    _drawCloud(canvas, paint, Offset(size.width * 0.15, size.height * 0.55),
        size.width * 0.15);
    // Cloud 2
    _drawCloud(canvas, paint, Offset(size.width * 0.8, size.height * 0.7),
        size.width * 0.12);
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset center, double r) {
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center.translate(-r * 0.6, r * 0.3), r * 0.7, paint);
    canvas.drawCircle(center.translate(r * 0.6, r * 0.3), r * 0.7, paint);
    canvas.drawCircle(center.translate(0, r * 0.5), r * 0.9, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}