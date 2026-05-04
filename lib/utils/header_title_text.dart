import 'package:flutter/cupertino.dart';

import '../screens/abc_game/utils/app_theme.dart';

class HeaderTitleText extends StatelessWidget {
  HeaderTitleText({super.key, this.title});

  String? title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title ?? '',
      style: const TextStyle(
          fontFamily: FontName.ChocoCooky),
      textAlign: TextAlign.start,
    );
  }
}
