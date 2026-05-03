// lib/screens/home_parent_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:moodiesapp/screens/abc_game/utils/appcolor.dart';
import 'package:moodiesapp/screens/childs/parents_mood_list_screen.dart';
import 'package:moodiesapp/screens/parent/parent_planner_list_screen.dart';
import 'package:moodiesapp/screens/parent/widgets/HomeMenuTile.dart';
import 'package:moodiesapp/screens/parent/widgets/child_profile_card.dart';
import 'package:moodiesapp/screens/parent/widgets/dashboard_data.dart';
import 'package:moodiesapp/screens/parent/widgets/recent_activity_card.dart';
import 'package:moodiesapp/screens/parent/widgets/recent_item.dart';
import 'package:moodiesapp/screens/parent/widgets/skeleton_box.dart';
import 'package:moodiesapp/screens/parent/widgets/stat_card.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/common_widgets.dart';
import '../abc_game/utils/app_theme.dart';
import '../login_screen.dart';
import '../print_list_screen.dart';


// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class HomeParentScreen extends StatefulWidget {
  const HomeParentScreen({super.key});

  @override
  State<HomeParentScreen> createState() => _HomeParentScreenState();
}

class _HomeParentScreenState extends State<HomeParentScreen> {
  final _svc = FirebaseService();

  // separate loading flags so name and dashboard load independently
  String _name        = '';
  bool _loadingName   = true;

  DashboardData? _dashboard;
  bool _loadingDash   = true;
  String? _dashError;   // non-null → show inline error instead of empty

  @override
  void initState() {
    super.initState();
    _loadName();
    _loadDashboard();
  }

  // ── Load parent display name ──────────────────────────────────────────────
  Future<void> _loadName() async {
    try {
      final user = await _svc.getUserProfile();
      if (mounted) setState(() { _name = user.name; _loadingName = false; });
    } catch (_) {
      final u = FirebaseAuth.instance.currentUser;
      if (mounted) {
        setState(() {
          _name = u?.email?.split('@').first ?? 'Parent';
          _loadingName = false;
        });
      }
    }
  }

  // ── Load all dashboard data in parallel ───────────────────────────────────
  Future<void> _loadDashboard() async {
    try {
      // 1 ── Get linked child UID
      final childUid = await _svc.getLinkedChildUid();
      if (childUid == null) {
        // Parent hasn't linked a child yet — show empty state gracefully
        if (mounted) setState(() { _loadingDash = false; });
        return;
      }

      // 2 ── Fire all network calls in parallel
      final now = DateTime.now();
      final results = await Future.wait([
        _svc.getChildProfile(childUid),                                  // [0]
        _svc.getChildMoodsByDate(childUid, now),                         // [1] today's moods
        _svc.getChildMoods(childUid),                                    // [2] all moods
        _svc.getUpcomingEventsCount(                                      // [3]
          startDate: _isoDate(now),
          endDate:   _isoDate(now.add(const Duration(days: 6))),
        ),
      ]);

      final childProfile   = results[0] as UserModel?;
      final todayMoods     = results[1] as List<MoodModel>;
      final allMoods       = results[2] as List<MoodModel>;
      final upcomingCount  = results[3] as int;

      if (!mounted) return;

      // 3 ── Compute derived values
      final weekMoodCount  = _countMoodsThisWeek(allMoods, now);
      final streakDays     = _calculateStreak(allMoods);
      final todayMood      = todayMoods.isNotEmpty ? todayMoods.first.mood : '';
      final recentItems    = _buildRecentItems(allMoods);

      setState(() {
        _dashboard = DashboardData(
          childName:      childProfile?.name ?? 'Your child',
          childAge:       int.tryParse(childProfile?.age ?? '') ?? 0,
          todayMood:      todayMood,
          moodEmoji:      _moodToEmoji(todayMood),
          streakDays:     streakDays,
          weekMoodCount:  weekMoodCount,
          upcomingEvents: upcomingCount,
          recentItems:    recentItems,
        );
        _loadingDash = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _dashError  = 'Could not load dashboard data.';
          _loadingDash = false;
        });
      }
    }
  }

  // ── Pull-to-refresh ───────────────────────────────────────────────────────
  Future<void> _refresh() async {
    setState(() { _loadingDash = true; _dashError = null; });
    await _loadDashboard();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// "yyyy-MM-dd" — matches Firestore event_date string format.
  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

  /// Count moods logged in the current calendar week (Mon–Sun).
  int _countMoodsThisWeek(List<MoodModel> moods, DateTime now) {
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1)); // Monday 00:00
    return moods.where((m) {
      final dt = _moodDate(m);
      return dt != null && !dt.isBefore(weekStart);
    }).length;
  }

  /// Count consecutive days (going back from today) with at least one mood.
  int _calculateStreak(List<MoodModel> moods) {
    if (moods.isEmpty) return 0;

    // Collect unique logged dates as "yyyy-MM-dd" strings
    final loggedDays = moods
        .map((m) => _moodDate(m))
        .whereType<DateTime>()
        .map((d) => _isoDate(d))
        .toSet();

    int streak = 0;
    var day = DateTime.now();

    // If today has no mood yet, start counting from yesterday
    if (!loggedDays.contains(_isoDate(day))) {
      day = day.subtract(const Duration(days: 1));
    }

    while (loggedDays.contains(_isoDate(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Build up to 3 recent-activity rows from mood history.
  List<RecentItem> _buildRecentItems(List<MoodModel> moods) {
    return moods.take(3).map((m) {
      return RecentItem(
        label:     'Mood logged',
        detail:    m.mood,
        timeLabel: _formatRelativeTime(_moodDate(m)),
        dotColor:  const Color(0xFF1D9E75),
      );
    }).toList();
  }

  /// Extract a DateTime from MoodModel.
  /// MoodModel stores created_at as a Firestore Timestamp.
  /// Adjust the field name below if your model exposes it differently.
  DateTime? _moodDate(MoodModel m) {
    try {
      // Option A — if MoodModel exposes a DateTime getter:
      //   return m.createdAt;
      //
      // Option B — if MoodModel exposes the raw Timestamp:
      //   return (m.createdAt as Timestamp).toDate();
      //
      // The safest fallback is to re-read the raw map field.
      // Replace 'createdAt' with the exact Dart field on your MoodModel.
      final raw = (m as dynamic).createdAt;
      if (raw is DateTime)  return raw;
      if (raw is Timestamp) return raw.toDate();
    } catch (_) {}
    return null;
  }

  /// "today at 9:04 am", "yesterday", "Apr 21"
  String _formatRelativeTime(DateTime? dt) {
    if (dt == null) return '';
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayOf = DateTime(dt.year, dt.month, dt.day);
    final diff  = today.difference(dayOf).inDays;
    if (diff == 0) return 'today at ${DateFormat('h:mm a').format(dt)}';
    if (diff == 1) return 'yesterday';
    return DateFormat('MMM d').format(dt);
  }

  /// Map mood string → emoji.
  /// Extend this map to match every mood value your app uses.
  String _moodToEmoji(String mood) {
    const map = {
      'happy':   '😊',
      'sad':     '😢',
      'angry':   '😠',
      'anxious': '😟',
      'calm':    '😌',
      'excited': '🤩',
      'tired':   '😴',
      'scared':  '😨',
    };
    return map[mood.toLowerCase()] ?? '😐';
  }

  Future<void> _logout() async {
    await _svc.logout();
    if (!mounted) return;
    NavigationService().pushAndRemoveAll(const LoginScreen());
  }

  // ── Palette (teal) — matches app accent, no background change ────────────
  static const _tealLight  = Color(0xFFE1F5EE);
  static const _tealMid    = Color(0xFF9FE1CB);
  static const _tealDark   = Color(0xFF085041);
  static const _tealAction = Color(0xFF0F6E56);

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            // ── Welcome heading ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _loadingName
                  ? const SizedBox(
                  height: 28, width: 160, child: SkeletonBox())
                  : Text(
                _name.isEmpty ? 'Welcome! 👋' : 'Welcome, $_name! 👋',
                style: const TextStyle(
                    fontFamily: FontName.ChocoCooky,
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("Here's your parenting dashboard",
                  style: TextStyle( fontFamily: FontName.Chiki,color: Colors.grey)),
            ),
            const SizedBox(height: 20),

            // ── Dashboard content ────────────────────────────────────────
            if (_loadingDash) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(height: 88, child: SkeletonBox(radius: 16)),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Expanded(child: SizedBox(height: 72, child: SkeletonBox())),
                  SizedBox(width: 12),
                  Expanded(child: SizedBox(height: 72, child: SkeletonBox())),
                ]),
              ),
            ] else if (_dashError != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_dashError ?? "",
                          style: const TextStyle(color: Colors.redAccent)),
                    ),
                    TextButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ] else if (_dashboard == null) ...[
              // No child linked yet
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _tealLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'No child linked yet. Ask your child to share their code.',
                    style: TextStyle(color: _tealDark),
                  ),
                ),
              ),
            ] else ...[
              // ── Child profile card ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ChildProfileCard(
                  data: _dashboard!,
                ),
              ),
              const SizedBox(height: 12),

              // ── Stats row ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: '${_dashboard?.weekMoodCount ?? 0}',
                        label: 'mood entries\nthis week',
                        cardColor: const Color(0xFFFFF8E1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        value: '${_dashboard?.upcomingEvents ?? 0}',
                        label: 'upcoming\nactivities',
                        cardColor: const Color(0xFFF3E5F5),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Section label ────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Core tiles ───────────────────────────────────────────────
            HomeMenuTile(
              label: "Child's Mood History",
              subtitle: _dashboard?.todayMood.isNotEmpty == true
                  ? 'Last entry: today'
                  : 'No entry today yet',
              icon: Icons.bar_chart,
              onTap: () =>
                  NavigationService().push(const ParentsMoodListScreen()),
              cardColor: const Color(0xFFF6E9E7),
            ),
            HomeMenuTile(
              label: 'Planner',
              subtitle: _dashboard != null
                  ? '${_dashboard?.upcomingEvents ?? 0} activities this week'
                  : null,
              icon: Icons.calendar_today,
              onTap: () =>
                  NavigationService().push(const ParentPlannerListScreen()),
              cardColor: const Color(0xFFF8E0FA),
            ),
            HomeMenuTile(
              label: 'Print Weekly Review',
              subtitle: 'Tap to generate this week\'s report',
              icon: Icons.print,
              onTap: () => NavigationService().push(const PrintListScreen()),
              cardColor: const Color(0xFFFFF3E0),
            ),

            // ── Recent activity ──────────────────────────────────────────
            if (_dashboard != null &&
                _dashboard!.recentItems.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'RECENT ACTIVITY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RecentActivityCard(items: _dashboard?.recentItems ?? []),
              ),
            ],

            const SizedBox(height: 24),

            // ── Sign out — demoted, lower visual weight ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () => showLogoutDialog(context, _logout),
                icon: const Icon(Icons.exit_to_app, size: 18),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: AppColor.mainAppColor,   width: 1.5,),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                  alignment: Alignment.centerLeft,
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}



