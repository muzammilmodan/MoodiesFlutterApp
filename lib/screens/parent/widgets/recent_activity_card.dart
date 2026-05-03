

// ---------------------------------------------------------------------------
// Recent activity card
// ---------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:moodiesapp/screens/parent/widgets/recent_item.dart';

class RecentActivityCard extends StatelessWidget {
  final List<RecentItem> items;
  const RecentActivityCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.shade100, width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item   = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: item.dotColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13),
                        children: [
                          TextSpan(
                            text: item.label,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color),
                          ),
                          const TextSpan(text: ' — '),
                          TextSpan(
                            text: item.detail,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(item.timeLabel,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                ],
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Divider(height: 20, color: Colors.grey.shade100),
                ),
            ],
          );
        }),
      ),
    );
  }
}
