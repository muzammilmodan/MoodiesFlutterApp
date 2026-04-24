// lib/screens/feeling_today_screen.dart

import 'package:flutter/material.dart';
import 'package:moodiesapp/utils/common_snackbar.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../utils/session_manager.dart';
import '../../widgets/common_widgets.dart';
import 'home_kids_screen.dart';

class FeelingTodayScreen extends StatefulWidget {
  const FeelingTodayScreen({super.key});

  @override
  State<FeelingTodayScreen> createState() => _FeelingTodayScreenState();
}

class _FeelingTodayScreenState extends State<FeelingTodayScreen> {
  final _svc      = FirebaseService();
  int    _selected = -1;
  int    _gender   = AppConstants.isMale;
  String _hair     = AppConstants.hairBlonde;
  bool   _saving   = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final g = await SessionManager.getIsGender();
    final h = await SessionManager.getHairColor();
    setState(() {
      _gender = g;
      _hair   = h.isEmpty ? AppConstants.hairBlonde : h;
    });
  }

  // ── build asset path for mood image ─────────────────────────────────────
  String _imgPath(String mood) {
    final g    = _gender == AppConstants.isMale ? 'boy' : 'girl';
    final m    = mood.toLowerCase();
    final hair = _hair == AppConstants.hairTan
        ? '${g == 'boy' ? 'tan_wz_black' : 'tan_wz_black_hair'}'
        : _hair;
    return 'assets/images/${m}_${g}_$hair.jpg';
  }

  Future<void> _confirmMood() async {
    if (_selected < 0) {
      CommonSnackbar.showErrorSnackbar(context: context, message:'Please select how you feel today');
      return;
    }
    final mood = AppConstants.moods[_selected];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Today\'s Feeling'),
        content: Text('Are you sure you feel $mood today?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes!')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      await _svc.addMood(mood);
      await SessionManager.setAvatarTitle(mood);
      if (!mounted) return;
      CommonSnackbar.showSuccessSnackbar(context: context, message: 'Mood saved! 🎉');
      NavigationService().pushAndRemoveAll(const HomeKidsScreen());
    } catch (e) {
      if (mounted)  CommonSnackbar.showErrorSnackbar(context: context, message:'Failed to save mood. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How Are You Today? 💭')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemCount: AppConstants.moods.length,
              itemBuilder: (_, i) {
                final mood = AppConstants.moods[i];
                final isSel = _selected == i;
                return GestureDetector(
                  onTap: () async {
                    setState(() => _selected = i);
                    await SessionManager.setAvatarTitle(mood);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSel
                          ? kAppBg.withOpacity(0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: isSel ? kAppBg : Colors.grey.shade200,
                          width: isSel ? 2.5 : 1),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6)
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(
                              _imgPath(mood),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.sentiment_satisfied_alt,
                                size: 46,
                                color: isSel ? kAppBg : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            mood,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSel ? kAppBg : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _saving
                ? const Center(child: CircularProgressIndicator(color: kAppBg))
                : AppButton(
                    label: 'Confirm My Mood',
                    onTap: _confirmMood),
          ),
        ],
      ),
    );
  }
}
