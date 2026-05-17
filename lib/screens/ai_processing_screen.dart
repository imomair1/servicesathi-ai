import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../features/workflow/providers/workflow_providers.dart';
import 'dart:async';

class AIProcessingScreen extends ConsumerStatefulWidget {
  final String userRequest;
  final VoidCallback onComplete;

  const AIProcessingScreen({
    super.key,
    required this.userRequest,
    required this.onComplete,
  });

  @override
  ConsumerState<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends ConsumerState<AIProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Trigger workflow via Riverpod on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeWorkflowProvider.notifier).startWorkflow(widget.userRequest);
    });
    
    // Safety fallback just in case backend fails or disconnects
    _fallbackTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Listen to real-time workflow state
    final workflowState = ref.watch(activeWorkflowProvider);
    final timeline = ref.watch(workflowTimelineProvider);
    
    // Extract intent from the first step if available
    Map<String, String>? intentDetails;
    if (timeline.isNotEmpty && timeline.first.agentName == 'Intent Agent') {
      intentDetails = timeline.first.details;
    }
    
    final isError = workflowState.error != null;
    
    // Complete automatically when ranking or booking agent finishes
    ref.listen(workflowTimelineProvider, (previous, next) {
      if (next.isNotEmpty && (next.last.agentName.contains('Ranking') || next.last.agentName.contains('Follow-Up'))) {
        if (next.last.status == 'completed') {
          _fallbackTimer?.cancel();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) widget.onComplete();
          });
        }
      }
    });

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
                      onPressed: () {
                        ref.read(activeWorkflowProvider.notifier).cancelWorkflow();
                        Navigator.of(context).pop();
                      },
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
                            decoration: BoxDecoration(
                              color: isError ? AppColors.error : AppColors.cyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isError ? 'Error Occurred' : 'Live Orchestration',
                            style: TextStyle(
                              color: isError ? AppColors.error : AppColors.cyan,
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
                          gradient: LinearGradient(
                            colors: isError 
                              ? [AppColors.error, AppColors.purpleDeep]
                              : [AppColors.cyan, AppColors.purpleDeep],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isError ? AppColors.error : AppColors.cyan)
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

                // Processing Step Live Output
                Center(
                  child: Text(
                    isError 
                        ? 'Connection Error: \${workflowState.error}'
                        : (timeline.isNotEmpty ? timeline.last.outputSummary : 'Initializing Agents...'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isError ? AppColors.error : AppColors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Extracted Intent (if available)
                AnimatedOpacity(
                  opacity: intentDetails != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedSlide(
                    offset: intentDetails != null ? Offset.zero : const Offset(0, 0.2),
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
                              if (timeline.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '\${(timeline.first.confidence * 100).toInt()}% confident',
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
                          if (intentDetails != null) ...[
                            _IntentRow('Service', intentDetails['service_type'] ?? '', Icons.build_rounded, isDark),
                            _IntentRow('Location', intentDetails['location'] ?? '', Icons.location_on_rounded, isDark),
                            _IntentRow('Urgency', intentDetails['urgency'] ?? '', Icons.speed_rounded, isDark),
                            _IntentRow('Language', intentDetails['language'] ?? '', Icons.translate_rounded, isDark),
                          ],
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
    if (value.isEmpty) return const SizedBox.shrink();
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
