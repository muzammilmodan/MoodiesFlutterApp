// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:moodiesapp/screens/childs/create_character_screen.dart';
import 'package:moodiesapp/screens/snakes_ladders/snakes_ladders_screen.dart';
import 'package:moodiesapp/utils/navigation_service.dart';
import '../services/firebase_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_enum.dart';
import '../utils/session_manager.dart';
import '../widgets/CurvedMoodiesText.dart';
import '../widgets/common_widgets.dart';
import 'abc_game/utils/app_theme.dart';
import 'login_screen.dart';
import 'parent/home_parent_screen.dart';
import 'childs/home_kids_screen.dart';
import 'parent/code_for_kids_screen.dart';
import 'package:moodiesapp/screens/snakes_ladders/screens/game_screen.dart';

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
      NavigationService().pushReplacement(const LoginScreen());
      return;
    }

    // User is logged in — check their role
    try {
      final profile = await FirebaseService().getUserProfile();
      await SessionManager.setSelectRole(profile.role);

      if (profile.role == UserType.parent.name) {
        final codeDone = await SessionManager.getIsSelectCode();
        NavigationService().pushReplacement(codeDone ? const HomeParentScreen() : const CodeForKidsScreen());
      } else {
        NavigationService().pushReplacement(const HomeKidsScreen());
      }
    } catch (_) {
      // If profile fetch fails, send to login
      NavigationService().pushReplacement(const LoginScreen());
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB57EDC), // light purple (top)
              Color(0xFF7B5BFF), // deeper purple (bottom)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 50),


              /// APP TITLE
              Column(
                children:  [
                  //const CurvedMoodiesText(),

                  // Title
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "M",
                          style: TextStyle(fontFamily: FontName.ChocoCooky,
                              color: Colors.teal, fontSize: 60, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: "ood",
                          style: TextStyle(fontFamily: FontName.ChocoCooky,color: Colors.orange, fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: "ies",
                          style: TextStyle(fontFamily:FontName.ChocoCooky,color: Colors.purple, fontSize: 60, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF5B21B6),
                        Color(0xFF4F46E5),
                        Color(0xFF6D28D9),
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      "Your happiness buddy",
                      style: TextStyle(
                        fontFamily: FontName.ChocoCooky,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // IMPORTANT (base color)
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// PET IMAGE
              Lottie.asset(AppImages.icnJumpKids, height: 350,),

              const Spacer(),

              /// START BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () {
                    // Navigate to onboarding
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF8E7CFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Let's Start",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

/*
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
  }*/
}
