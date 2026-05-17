import 'package:flutter/material.dart';
import 'dart:async';
import '../config/colors.dart';

class BookingSimulationScreen extends StatefulWidget {
  final VoidCallback onContinue;
  const BookingSimulationScreen({super.key, required this.onContinue});

  @override
  State<BookingSimulationScreen> createState() =>
      _BookingSimulationScreenState();
}

class _BookingSimulationScreenState extends State<BookingSimulationScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _glowController;
  late Animation<double> _checkScale;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showDetails = true);
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.darkBg, Color(0xFF0A1A12)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF0FFF4), AppColors.surfaceLight],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Animated checkmark
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success
                                .withOpacity(0.2 + 0.15 * _glowController.value),
                            blurRadius: 40 + 20 * _glowController.value,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ScaleTransition(
                        scale: _checkScale,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppColors.success, Color(0xFF059669)],
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'Booking Simulated!',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your service request has been processed',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 36),

                // Booking Details
                AnimatedOpacity(
                  opacity: _showDetails ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: AnimatedSlide(
                    offset: _showDetails ? Offset.zero : const Offset(0, 0.2),
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(context, 'Booking ID', 'BK-20250515-001', isDark),
                          _divider(isDark),
                          _DetailRow(context, 'Provider', 'Ali AC Services', isDark),
                          _divider(isDark),
                          _DetailRow(context, 'Service', 'AC Repair', isDark),
                          _divider(isDark),
                          _DetailRow(context, 'Est. Cost', 'PKR 1,500', isDark),
                          _divider(isDark),
                          _DetailRow(context, 'Time Slot', 'Today, 3:00 PM', isDark),
                          _divider(isDark),
                          _DetailRow(context, 'ETA', '25-30 min', isDark),
                          _divider(isDark),
                          Row(
                            children: [
                              Text(
                                'Status',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '✓ Simulated',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // AI reasoning
                AnimatedOpacity(
                  opacity: _showDetails ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.purpleDeep.withOpacity(0.12)
                          : AppColors.purpleDeep.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.purpleDeep.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.psychology,
                            color: AppColors.purpleMid, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Decision Reasoning',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.purpleLight
                                      : AppColors.purpleDeep,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Ali AC Services was selected as the top match with a 96/100 AI score. Highest rated in Gulberg area (4.8★), 8 years experience, specializes in your AC brand, and available within 30 minutes.',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.purpleLight.withOpacity(0.8)
                                      : AppColors.purpleDeep.withOpacity(0.8),
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // CTA Button
                AnimatedOpacity(
                  opacity: _showDetails ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                    children: [
                      Container(
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
                            onTap: widget.onContinue,
                            child: const Center(
                              child: Text(
                                'View Follow-Up Plan',
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _DetailRow(BuildContext context, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      color: isDark ? AppColors.darkBorder : AppColors.borderLight,
      height: 18,
    );
  }
}
