import 'dart:ui';

class RecentItem {
  final String label;
  final String detail;
  final String timeLabel;
  final Color  dotColor;

  const RecentItem({
    required this.label,
    required this.detail,
    required this.timeLabel,
    required this.dotColor,
  });
}