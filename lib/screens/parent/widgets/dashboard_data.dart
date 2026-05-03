// ---------------------------------------------------------------------------
// Lightweight view-model — only what the UI needs
// ---------------------------------------------------------------------------
import 'package:moodiesapp/screens/parent/widgets/recent_item.dart';

class DashboardData {
  final String  childName;
  final int     childAge;
  final String  todayMood;      // e.g. "Happy" — empty if not logged yet
  final String  moodEmoji;      // e.g. "😊"
  final int     streakDays;
  final int     weekMoodCount;
  final int     upcomingEvents;
  final List<RecentItem> recentItems;

  const DashboardData({
    required this.childName,
    required this.childAge,
    required this.todayMood,
    required this.moodEmoji,
    required this.streakDays,
    required this.weekMoodCount,
    required this.upcomingEvents,
    required this.recentItems,
  });
}