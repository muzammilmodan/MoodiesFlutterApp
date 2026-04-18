
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class OpenColorScreen{
  static const MethodChannel channel = MethodChannel('native_channel');

  static Future<void> openNativeScreen() async {
    try {
      await channel.invokeMethod('openColorScreen');
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}