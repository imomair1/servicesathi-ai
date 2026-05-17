import 'package:flutter/material.dart';
import '../config/colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final notifications = [
      _NotifData(Icons.check_circle, 'Booking Confirmed', 'Ali AC Services will arrive at 3:00 PM today', '2 min ago', AppColors.success, false),
      _NotifData(Icons.auto_awesome, 'AI Insight', 'Based on your usage, your AC may need servicing next week', '1 hr ago', AppColors.purpleMid, false),
      _NotifData(Icons.notifications_active, 'Reminder', 'Your technician arrives in 15 minutes', '3 hrs ago', AppColors.electricBlue, true),
      _NotifData(Icons.star_rounded, 'Rate Your Experience', 'How was your experience with Bashir Plumbing?', 'Yesterday', AppColors.warning, true),
      _NotifData(Icons.hub_rounded, 'Workflow Complete', 'Your last AI agent pipeline completed in 2.1s', 'Yesterday', AppColors.cyan, true),
      _NotifData(Icons.local_offer_rounded, 'Special Offer', '20% off on plumbing services this week', '2 days ago', AppColors.error, true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppColors.electricBlue, fontSize: 13),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: n.read
                  ? (isDark ? AppColors.darkCard : AppColors.surfaceCard)
                  : (isDark
                      ? AppColors.electricBlue.withOpacity(0.08)
                      : AppColors.electricBlue.withOpacity(0.04)),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: n.read
                    ? (isDark ? AppColors.darkBorder : AppColors.borderLight)
                    : AppColors.electricBlue.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: n.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(n.icon, color: n.color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (!n.read)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.electricBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.body,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n.time,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textDarkSecondary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotifData {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final Color color;
  final bool read;

  const _NotifData(this.icon, this.title, this.body, this.time, this.color, this.read);
}
