import 'package:flutter/cupertino.dart';

class HeaderTitleText extends StatelessWidget {
  HeaderTitleText({super.key, this.title});

  String? title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title ?? '',
      style: const TextStyle(
          fontFamily: 'ChocoCooky'),
      textAlign: TextAlign.start,
    );
  }
}
