import 'package:flutter/material.dart';
import '../config/colors.dart';

class FollowUpScreen extends StatefulWidget {
  final VoidCallback onDone;
  const FollowUpScreen({super.key, required this.onDone});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  final _steps = [
    _FollowUpStep(
      icon: Icons.calendar_today_rounded,
      title: 'Booking Confirmed',
      subtitle: 'Your booking BK-20250515-001 is confirmed',
      time: 'Just now',
      status: 'completed',
      color: AppColors.success,
    ),
    _FollowUpStep(
      icon: Icons.notifications_active_rounded,
      title: 'Reminder: 1 Hour Before',
      subtitle: 'You will be notified 1 hour before the service',
      time: 'Scheduled: 2:00 PM',
      status: 'scheduled',
      color: AppColors.electricBlue,
    ),
    _FollowUpStep(
      icon: Icons.timer_rounded,
      title: 'Reminder: 15 Min Before',
      subtitle: 'Final reminder before technician arrives',
      time: 'Scheduled: 2:45 PM',
      status: 'scheduled',
      color: AppColors.purpleMid,
    ),
    _FollowUpStep(
      icon: Icons.directions_car_rounded,
      title: 'Technician En Route',
      subtitle: 'You will be notified when the technician starts heading to you',
      time: 'Auto-tracked',
      status: 'pending',
      color: AppColors.warning,
    ),
    _FollowUpStep(
      icon: Icons.check_circle_rounded,
      title: 'Service Completed',
      subtitle: 'Mark as completed when the service is done',
      time: 'Expected: 4:00 PM',
      status: 'pending',
      color: AppColors.success,
    ),
    _FollowUpStep(
      icon: Icons.star_rounded,
      title: 'Rate & Review',
      subtitle: 'Share your experience to help others',
      time: 'After completion',
      status: 'pending',
      color: AppColors.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Follow-Up Plan'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.success, size: 14),
                const SizedBox(width: 4),
                const Text(
                  'AI Automated',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.electricBlue.withOpacity(isDark ? 0.15 : 0.08),
                  AppColors.purpleDeep.withOpacity(isDark ? 0.1 : 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.electricBlue.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.smart_toy_rounded,
                      color: AppColors.electricBlue, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Follow-Up Agent Active',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '3 automated actions scheduled for this booking',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Timeline
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline connector
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: step.status == 'completed'
                                ? step.color
                                : step.color.withOpacity(0.15),
                            boxShadow: step.status == 'completed'
                                ? [
                                    BoxShadow(
                                      color: step.color.withOpacity(0.3),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            step.icon,
                            size: 18,
                            color: step.status == 'completed'
                                ? Colors.white
                                : step.color,
                          ),
                        ),
                        if (index < _steps.length - 1)
                          Container(
                            width: 2,
                            height: 50,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: step.status == 'completed'
                                ? step.color.withOpacity(0.4)
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.borderLight),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Content
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.darkCard : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    step.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: step.status == 'completed'
                                        ? AppColors.success.withOpacity(0.1)
                                        : step.status == 'scheduled'
                                            ? AppColors.electricBlue
                                                .withOpacity(0.1)
                                            : (isDark
                                                ? AppColors.darkBorder
                                                : AppColors.surfaceGray),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    step.status == 'completed'
                                        ? '✓ Done'
                                        : step.status == 'scheduled'
                                            ? '⏰ Scheduled'
                                            : '○ Pending',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: step.status == 'completed'
                                          ? AppColors.success
                                          : step.status == 'scheduled'
                                              ? AppColors.electricBlue
                                              : AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(step.subtitle,
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            Text(
                              step.time,
                              style: TextStyle(
                                fontSize: 11,
                                color: step.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom button
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.of(context).padding.bottom + 20),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: widget.onDone,
                  child: const Center(
                    child: Text(
                      'Back to Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final String status;
  final Color color;

  const _FollowUpStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
    required this.color,
  });
}
