import 'dart:io';

import 'package:flutter/material.dart';

class AppTheme {


  static InkWell container(String text, BuildContext context, Function onTapd) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        onTapd();
      },
      child: Container(
        child: Image(image: AssetImage(text),),
      ),
    );
  }

  static BoxDecoration boxDec(
      Border border, BorderRadius borderRadius, Gradient gradient,
      {bool? isFromTab}) {
    return BoxDecoration(
        borderRadius: borderRadius, border: border, gradient: gradient);
  }

  static Icons commonIcon(
    double size,
    Color color,
  ) {
    return commonIcon(
      size,
      color,
    );
  }

}
class FontName {
  static const Chiki = "Chiki";  /// word screen

  static const SuezOneRegular = "SuezOneRegular";
  static const grobold = "GROBOLD";
  static const SuravaramRegular = "Suravaram";
}
