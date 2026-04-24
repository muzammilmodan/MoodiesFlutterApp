// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:moodiesapp/utils/navigation_service.dart';
import 'screens/splash_screen.dart';
import 'widgets/common_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MoodiesApp());
}

class MoodiesApp extends StatelessWidget {
  const MoodiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService().navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
