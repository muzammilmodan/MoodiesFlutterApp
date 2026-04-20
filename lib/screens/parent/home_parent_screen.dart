// lib/screens/home_parent_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moodiesapp/screens/childs/parents_mood_list_screen.dart';
import 'package:moodiesapp/screens/childs/planner_list_screen.dart';
import 'package:moodiesapp/screens/parent/parent_planner_list_screen.dart';
import '../../services/firebase_service.dart';
import '../../widgets/common_widgets.dart';
import '../login_screen.dart';
import '../print_list_screen.dart';


class HomeParentScreen extends StatefulWidget {
  const HomeParentScreen({super.key});

  @override
  State<HomeParentScreen> createState() => _HomeParentScreenState();
}

class _HomeParentScreenState extends State<HomeParentScreen> {
  final _svc  = FirebaseService();
  String _name = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    try {
      final user = await _svc.getUserProfile();
      if (mounted) setState(() => _name = user.name);
    } catch (_) {
      final u = FirebaseAuth.instance.currentUser;
      if (mounted) setState(() => _name = u?.email ?? 'Parent');
    }
  }

  Future<void> _logout() async {
    await _svc.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false);
  }

  void _nav(Widget s) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Home'),
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
            child: Text(
              _name.isEmpty ? 'Welcome! 👋' : 'Welcome, $_name! 👋',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Here's your parenting dashboard",
                style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16),
          HomeMenuTile(
            label: 'Daily Check In',
            icon: Icons.check_circle_outline,
            onTap: () => showSnack(context, 'Working in progress.'),
          ),
          HomeMenuTile(
            label: "Child's Mood History",
            icon: Icons.bar_chart,
            onTap: () => _nav(const ParentsMoodListScreen()),
          ),
          HomeMenuTile(
            label: 'Planner',
            icon: Icons.calendar_today,
            onTap: () => _nav(const ParentPlannerListScreen()),
          ),
          HomeMenuTile(
            label: 'Print Weekly Review',
            icon: Icons.print,
            onTap: () => _nav(const PrintListScreen()),
          ),
          HomeMenuTile(
            label: 'Sign Out',
            icon: Icons.exit_to_app,
            onTap: () => showLogoutDialog(context, _logout),
          ),
        ],
      ),
    );
  }
}
