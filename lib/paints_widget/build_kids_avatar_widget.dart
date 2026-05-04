
// ──────────────────────────────────────────────
//  ILLUSTRATION
// ──────────────────────────────────────────────
import 'package:flutter/cupertino.dart';

Widget BuildKidsAvatarWidget() {
  return SizedBox(
    height: 140,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Boy (left)
        Image.asset("assets/images/boys_girls_avatar.png",
          fit: BoxFit.cover,height: 500,width: 500,)
      ],
    ),
  );
}