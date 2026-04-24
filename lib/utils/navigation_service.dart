import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;

  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get _navigator => navigatorKey.currentState;

  // Push
  Future<dynamic>? push(Widget page) {
    return _navigator?.push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // Replace
  Future<dynamic>? pushReplacement(Widget page) {
    return _navigator?.pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // Clear stack
  Future<dynamic>? pushAndRemoveAll(Widget page) {
    return _navigator?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
          (route) => false,
    );
  }

  // Pop
  void pop([dynamic result]) {
    _navigator?.pop(result);
  }
}