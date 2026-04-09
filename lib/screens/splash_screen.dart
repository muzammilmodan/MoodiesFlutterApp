// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../utils/app_constants.dart';
import '../utils/session_manager.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'home_parent_screen.dart';
import 'home_kids_screen.dart';
import 'code_for_kids_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(
        Duration(milliseconds: AppConstants.splashTimeout));
    if (!mounted) return;

    // Firebase Auth persists login across app restarts automatically
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _go(const LoginScreen());
      return;
    }

    // User is logged in — check their role
    try {
      final profile = await FirebaseService().getUserProfile();
      await SessionManager.setSelectRole(profile.role);

      if (profile.role == AppConstants.roleParent) {
        final codeDone = await SessionManager.getIsSelectCode();
        _go(codeDone ? const HomeParentScreen() : const CodeForKidsScreen());
      } else {
        _go(const HomeKidsScreen());
      }
    } catch (_) {
      // If profile fetch fails, send to login
      _go(const LoginScreen());
    }
  }

  void _go(Widget screen) => Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/moodies_splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Moodies',
                style: TextStyle(
                  fontFamily: 'ChocoCooky',
                  fontSize: 48,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kids Mood Tracker',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const Spacer(),
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
