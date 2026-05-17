import 'package:flutter/material.dart';
import 'dart:async';
import '../config/colors.dart';
import '../models/models.dart';

class AIProcessingScreen extends StatefulWidget {
  final String userRequest;
  final VoidCallback onComplete;

  const AIProcessingScreen({
    super.key,
    required this.userRequest,
    required this.onComplete,
  });

  @override
  State<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends State<AIProcessingScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _intentExtracted = false;
  late AnimationController _pulseController;

  final _steps = [
    'Analyzing your request...',
    'Detecting language & intent...',
    'Extracting service details...',
    'Searching providers...',
    'Processing complete!',
  ];

  final _intent = const IntentResult(
    serviceType: 'AC Repair',
    location: 'Gulberg, Lahore',
    urgency: 'Medium',
    budgetRange: '~2,000 PKR',
    preferredTime: 'Today',
    language: 'Roman Urdu',
    confidence: 0.94,
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _simulateProcessing();
  }

  void _simulateProcessing() {
    Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentStep < _steps.length - 1) {
        setState(() {
          _currentStep++;
          if (_currentStep >= 2) _intentExtracted = true;
        });
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) widget.onComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
                  colors: [AppColors.darkBg, Color(0xFF0D1530)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF0F4FF), AppColors.surfaceLight],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.cyan.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.cyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'AI Processing',
                            style: TextStyle(
                              color: AppColors.cyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // User request bubble
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 16,
                              color: isDark
                                  ? AppColors.textDarkSecondary
                                  : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text('Your Request',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '"${widget.userRequest}"',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // AI Brain Animation
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.cyan, AppColors.purpleDeep],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan
                                  .withOpacity(0.3 * _pulseController.value),
                              blurRadius: 30 + 20 * _pulseController.value,
                              spreadRadius: 5 * _pulseController.value,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.psychology_rounded,
                            color: Colors.white, size: 48),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Processing Steps
                Center(
                  child: Text(
                    _steps[_currentStep],
                    style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Step indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i <= _currentStep ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i <= _currentStep
                            ? AppColors.cyan
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.borderLight),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 36),

                // Extracted Intent
                AnimatedOpacity(
                  opacity: _intentExtracted ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedSlide(
                    offset:
                        _intentExtracted ? Offset.zero : const Offset(0, 0.2),
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.cyan.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyan.withOpacity(0.05),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: AppColors.cyan, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'AI Extracted Intent',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${(_intent.confidence * 100).toInt()}% confident',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _IntentRow('Service', _intent.serviceType, Icons.build_rounded, isDark),
                          _IntentRow('Location', _intent.location, Icons.location_on_rounded, isDark),
                          _IntentRow('Urgency', _intent.urgency, Icons.speed_rounded, isDark),
                          _IntentRow('Budget', _intent.budgetRange ?? 'Not specified', Icons.payments_rounded, isDark),
                          _IntentRow('Time', _intent.preferredTime ?? 'Flexible', Icons.schedule_rounded, isDark),
                          _IntentRow('Language', _intent.language, Icons.translate_rounded, isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntentRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _IntentRow(this.label, this.value, this.icon, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withOpacity(isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.electricBlue, size: 16),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textDarkSecondary : AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
