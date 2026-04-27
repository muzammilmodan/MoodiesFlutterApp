

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:moodiesapp/screens/bubbles/bubble_screen.dart';
import 'package:moodiesapp/screens/childs/chill_music_screen.dart';
import 'package:moodiesapp/screens/childs/planner_list_screen.dart';
import 'package:moodiesapp/screens/childs/widgets/GameTile.dart';
import 'package:moodiesapp/screens/widgets/KidsMenuCard.dart';
import 'package:moodiesapp/utils/app_utils.dart';
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


  // ── main build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        bool shouldExit = await AppUtils.showExitDialog(context);

        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F3FF),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── header ──────────────────────────────────────────────
            _buildHeader(),

            // ── how are you today ────────────────────────────────────
            _sectionLabel('💭 How are you today?'),
            KidsMenuCard(
              label: 'Daily Check In',
              subtitle: 'How do you feel?',
              emoji: '😊',
              cardColor: const Color(0xFFFFE5EC),
              iconBgColor: const Color(0xFFFFB3C6),
              onTap: () => NavigationService().push(const FeelingTodayScreen()),
            ),

            // ── create & colour ──────────────────────────────────────
            _sectionLabel('🎨 Create & Colour'),
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
              isNew: true,
              onTap: () => OpenColorScreen.openNativeScreen(),
            ),

            // ── my space ─────────────────────────────────────────────
            _sectionLabel('⭐ My Space'),
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
              label: 'My Awards 🏆',
              subtitle: "See what you've earned",
              emoji: '🏅',
              cardColor: const Color(0xFFFFF3E0),
              iconBgColor: const Color(0xFFFFCC80), // ← NEW badge
              onTap: () => NavigationService().push(const AwardsScreen()),
            ),
            KidsMenuCard(
              label: 'Print Weekly Review',
              subtitle: 'Show your progress',
              emoji: '🖨️',
              cardColor: const Color(0xFFF3E5F5),
              iconBgColor: const Color(0xFFCE93D8),
              onTap: () => NavigationService().push(const PrintListScreen()),
            ),

            // ── games grid ───────────────────────────────────────────
            _sectionLabel('🎮 Games'),
            _gamesGrid(),

            // ── sign out ─────────────────────────────────────────────
            const SizedBox(height: 10),
            KidsMenuCard(
              label: 'Sign Out',
              subtitle: 'See you next time!',
              emoji: '👋',
              cardColor: const Color(0xFFEEEEEE),
              iconBgColor: const Color(0xFFBDBDBD),
              onTap: () => showLogoutDialog(context, _logout),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


// ── section label helper ──────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'ChocoCooky',
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Color(0xFF9B8EC4),
        letterSpacing: 0.5,
      ),
    ),
  );

// ── curved gradient header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFC084FC), Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // ── safe area top padding ──────────────────────────────
          const SafeArea(bottom: false, child: SizedBox()),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Row(
              children: [
                // avatar ring
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.6), width: 2.5),
                  ),
                  child: const Center(
                      child: Text('🧒', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 14),

                // greeting
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name.isEmpty ? 'Hi there! 👋' : 'Hi, $_name! 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'ChocoCooky',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'What would you like to do today?',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontFamily: 'ChocoCooky'),
                      ),
                    ],
                  ),
                ),

                // logout button
                GestureDetector(
                  onTap: () => showLogoutDialog(context, _logout),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 1.5),
                    ),
                    child: const Icon(Icons.logout_rounded,
                        color: Colors.white, size: 17),
                  ),
                ),
              ],
            ),
          ),

          // ── invite code box ────────────────────────────────────
          if (_myCode.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.35), width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('MY CODE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                letterSpacing: 1.2,
                                fontFamily: 'ChocoCooky',
                              )),
                          const SizedBox(height: 2),
                          Text(_myCode,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 3,
                                fontFamily: 'ChocoCooky',
                              )),
                        ],
                      ),
                    ),
                    // copy
                    _codeIconBtn(
                      icon: Icons.copy_rounded,
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: _myCode));
                        if (mounted) {
                          CommonSnackbar.showSuccessSnackbar(
                              context: context, message: 'Code copied! 📋');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    // share
                    _codeIconBtn(
                      icon: Icons.share_rounded,
                      onTap: () => Share.share(
                        'Hello! This is your child code, use it on the parent side to track activity.\n\nCode: $_myCode',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── curved bottom ─────────────────────────────────────
          const SizedBox(height: 20),
          Container(
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F3FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeIconBtn({required IconData icon, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      );

// ── games 2-column grid ───────────────────────────────────────────────────────
  Widget _gamesGrid() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        GameTile(
          emoji: '🧩',
          label: 'Puzzle Game',
          subtitle: 'Challenge your mind',
          cardColor: const Color(0xFFE0EEFF),
          iconBgColor: const Color(0xFFB3D4FF),
          onTap: () => NavigationService().push(const PuzzleScreen()),
        ),
        GameTile(
          emoji: '🔤',
          label: 'ABC Game',
          subtitle: 'Learn the alphabet',
          cardColor: const Color(0xFFFFE3E0),
          iconBgColor: const Color(0xFFFFBCB3),
          onTap: () => NavigationService().push(AbcGameScreen()),
        ),
        GameTile(
          emoji: '🫧',
          label: 'Bubble Game',
          subtitle: 'Pop & play',
          cardColor: const Color(0xFFE7FFE0),
          iconBgColor: const Color(0xFFB3FFC2),
          onTap: () => NavigationService().push(BubbleScreen()),
        ),
        // GameTile(
        //   emoji: '🎵',
        //   label: 'Chill Music',
        //   subtitle: 'Relax and listen',
        //   cardColor: const Color(0xFFFFF0F9),
        //   iconBgColor: const Color(0xFFFFB3E6),
        //   onTap: () => NavigationService().push(const ChillMusicScreen()),
        // ),
      ],
    ),
  );

}
