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
        const Duration(milliseconds: AppConstants.splashTimeout));
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
      body: Stack(
        children: [
          /// 🔥 Full screen background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/moodies_splash.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// 🔥 Optional dark overlay for better text visibility
          // Container(
          //   color: Colors.black.withOpacity(0.3),
          // ),

          /// 🔥 Bottom content
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.black12,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 24),
                    Text(
                      'Kids Mood Tracker',
                      style: TextStyle(
                        color: Color(0xFFAB47BC),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(color: Color(0xFFAB47BC)),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
