
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientText extends StatelessWidget {
  final String text;
  final double size;

  const GradientText(this.text, {required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFFFB84C),
          Color(0xFFFFB84C),
          Color(0xFFFFB84C),
        ],
      ).createShader(bounds),
      child: Text(
        text,
        style: GoogleFonts.fredoka(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        // style: TextStyle(
        //   fontSize: size,
        //   fontWeight: FontWeight.bold,
        //   color: Colors.white,
        // ),
      ),
    );
  }
}