
import 'package:flutter/cupertino.dart';

class LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Green hill
    final paint = Paint()
      ..color = const Color(0xFF8CC85A)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.25, size.height * 0.1,
        size.width * 0.5, size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 0.6,
        size.width, size.height * 0.3,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Lighter green strip at bottom
    final paint2 = Paint()
      ..color = const Color(0xFF9FD46A)
      ..style = PaintingStyle.fill;
    final path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.55,
        size.width, size.height * 0.65,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
