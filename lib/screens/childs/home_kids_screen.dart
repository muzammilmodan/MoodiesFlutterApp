// lib/screens/home_kids_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:moodiesapp/screens/childs/chill_music_screen.dart';
import 'package:moodiesapp/screens/childs/planner_list_screen.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/firebase_service.dart';
import '../../utils/session_manager.dart';
import '../../widgets/common_widgets.dart';
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
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  void _nav(Widget s) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => s));

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
          HomeMenuTile(
              label: 'Daily Check In — How do you feel?',
              icon: Icons.mood,
              onTap: () => _nav(const FeelingTodayScreen())),
          HomeMenuTile(
              label: 'Color Pages',
              icon: Icons.palette,
              onTap: () => _nav(const ColorPagesScreen())),
          HomeMenuTile(
              label: 'Art Color Pages',
              icon: Icons.art_track,
              onTap: () {
                OpenColorScreen.openNativeScreen();
              }),
          HomeMenuTile(
              label: 'Chill Music',
              icon: Icons.music_note,
              onTap: () => _nav(const ChillMusicScreen())),
          HomeMenuTile(
              label: 'Planner',
              icon: Icons.calendar_today,
              onTap: () => _nav(const PlannerListScreen())),
          HomeMenuTile(
              label: 'Create New Character',
              icon: Icons.face,
              onTap: () => _nav(const CreateCharacterScreen())),
          HomeMenuTile(
              label: 'Puzzle Game',
              icon: Icons.extension,
              onTap: () => _nav(const PuzzleScreen())),
          HomeMenuTile(
              label: 'Print Weekly Review',
              icon: Icons.print,
              onTap: () => _nav(const PrintListScreen())),
          HomeMenuTile(
              label: 'My Awards 🏆',
              icon: Icons.emoji_events,
              onTap: () => _nav(const AwardsScreen())),
          HomeMenuTile(
              label: 'Sign Out',
              icon: Icons.exit_to_app,
              onTap: () => showLogoutDialog(context, _logout)),
        ],
      ),
    );
  }
}
