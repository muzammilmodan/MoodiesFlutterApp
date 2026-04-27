

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:moodiesapp/screens/bubbles/bubble_screen.dart';
import 'package:moodiesapp/screens/childs/chill_music_screen.dart';
import 'package:moodiesapp/screens/childs/planner_list_screen.dart';
import 'package:moodiesapp/screens/widgets/KidsMenuCard.dart';
import 'package:moodiesapp/utils/common_snackbar.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/firebase_service.dart';
import '../../utils/navigation_service.dart';
import '../../utils/session_manager.dart';
import '../../widgets/common_widgets.dart';
import '../abc_game/abc_game_screen.dart';
import '../image_colors/open_color_screen.dart';
import '../login_screen.dart';
import 'feeling_today_screen.dart';

import '../print_list_screen.dart';
import 'create_character_screen.dart';
import 'puzzle_screen.dart';
import 'color_pages_screen.dart';
import 'awards_screen.dart';

class HomeKidsScreen extends StatefulWidget {
  const HomeKidsScreen({super.key});

  @override
  State<HomeKidsScreen> createState() => _HomeKidsScreenState();
}

class _HomeKidsScreenState extends State<HomeKidsScreen> {
  final _svc = FirebaseService();
  String _name = '';
  String _myCode = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _svc.getUserProfile();
      // also sync avatar to local prefs
      final av = await _svc.getAvatar();
      if (av != null) {
        await SessionManager.setUserGender(av.gender);
        await SessionManager.setUserHairColor(av.hairColor);
        await SessionManager.setIsGender(av.gender == 'male' ? 0 : 1);
        await SessionManager.setHairColor(av.hairColor);
      }
      if (mounted) {
        setState(() {
          _name = user.name;
          _myCode = user.myCode;
        });
      }
    } catch (_) {
      final authUser = FirebaseAuth.instance.currentUser;
      if (mounted) {
        setState(() {
          _name = authUser?.email ?? 'Kid';
          _myCode = "";
        });
      }
    }
  }

  Future<void> _logout() async {
    await _svc.logout();
    if (!mounted) return;
    NavigationService().pushAndRemoveAll(const LoginScreen());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kids Home'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => showLogoutDialog(context, _logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 👋 Name
                Expanded(
                  child: Text(
                    _name.isEmpty ? 'Hi there! 👋' : 'Hi, $_name! 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'ChocoCooky',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// Code + Icons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    /// Code Text
                    Text(
                      _myCode,
                      style: const TextStyle(
                        fontFamily: 'ChocoCooky',
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// Icons
                    Row(
                      children: [
                        /// Copy
                        InkWell(
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: _myCode),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Code copied"),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.copy,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// Share
                        InkWell(
                          onTap: () {
                            Share.share(
                              '''Hello, this is your parents.

This is your child code please save this code and use this code in your parent side so show your child all activity in your dashboard.

Code: $_myCode''',
                            );
                          },
                          child: const Icon(
                            Icons.share,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('What would you like to do today?',
                style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),

          // ── colorful kids menu cards (CHANGED) ───────────────────────
          KidsMenuCard(
            label: 'Daily Check In',
            subtitle: 'How do you feel?',
            emoji: '😊',
            cardColor: const Color(0xFFFFE5EC),
            iconBgColor: const Color(0xFFFFB3C6),
            onTap: () => NavigationService().push(const FeelingTodayScreen()),
          ),
          KidsMenuCard(
            label: 'Color Pages',
            subtitle: 'Express yourself',
            emoji: '🖍️',
            cardColor: const Color(0xFFFFF8E1),
            iconBgColor: const Color(0xFFFFE082),
            onTap: () => NavigationService().push(const ColorPagesScreen()),
          ),
          KidsMenuCard(
            label: 'Art Color Pages',
            subtitle: 'Create beautiful art',
            emoji: '🎨',
            cardColor: const Color(0xFFE8F5E9),
            iconBgColor: const Color(0xFFA5D6A7),
            onTap: () => OpenColorScreen.openNativeScreen(),
          ),
          KidsMenuCard(
            label: 'Planner',
            subtitle: 'Organise your day',
            emoji: '📅',
            cardColor: const Color(0xFFEDE7F6),
            iconBgColor: const Color(0xFFCE93D8),
            onTap: () => NavigationService().push(const PlannerListScreen()),
          ),
          KidsMenuCard(
            label: 'Create New Character',
            subtitle: 'Design your avatar',
            emoji: '🧒',
            cardColor: const Color(0xFFE0F7FA),
            iconBgColor: const Color(0xFF80DEEA),
            onTap: () => NavigationService().push(const CreateCharacterScreen()),
          ),
          KidsMenuCard(
            label: 'Puzzle Game',
            subtitle: 'Challenge your mind',
            emoji: '🧩',
            cardColor: const Color(0xFFE0EEFF),
            iconBgColor: const Color(0xFFB3D4FF),
            onTap: () => NavigationService().push(const PuzzleScreen()),
          ),
          KidsMenuCard(
            label: 'ABC Game',
            subtitle: 'Challenge your mind with character',
            emoji: '🧩',
            cardColor: const Color(0xFFFFE3E0),
            iconBgColor: const Color(0xFFFFBCB3),
            onTap: () => NavigationService().push(AbcGameScreen()),
          ),
          KidsMenuCard(
            label: 'Bubble Game',
            subtitle: 'Challenge your mind',
            emoji: '🧩',
            cardColor: const Color(0xFFE7FFE0),
            iconBgColor: const Color(0xFFB3FFC2),
            onTap: () => NavigationService().push(BubbleScreen()),
          ),
          KidsMenuCard(
            label: 'Print Weekly Review',
            subtitle: 'Show your progress',
            emoji: '🖨️',
            cardColor: const Color(0xFFF3E5F5),
            iconBgColor: const Color(0xFFCE93D8),
            onTap: () => NavigationService().push(const PrintListScreen()),
          ),
          KidsMenuCard(
            label: 'My Awards 🏆',
            subtitle: 'See what you\'ve earned',
            emoji: '🏅',
            cardColor: const Color(0xFFFFF3E0),
            iconBgColor: const Color(0xFFFFCC80),
            onTap: () => NavigationService().push(const AwardsScreen()),
          ),
          KidsMenuCard(
            label: 'Sign Out',
            subtitle: 'See you next time!',
            emoji: '👋',
            cardColor: const Color(0xFFEEEEEE),
            iconBgColor: const Color(0xFFBDBDBD),
            onTap: () => showLogoutDialog(context, _logout),
          ),
        ],
      ),
    );
  }
}
