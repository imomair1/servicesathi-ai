import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../models/models.dart';

class AgentWorkflowNode extends StatefulWidget {
  final AgentStep step;
  final bool isActive;
  final bool isLast;
  final int index;

  const AgentWorkflowNode({
    super.key,
    required this.step,
    required this.isActive,
    required this.isLast,
    required this.index,
  });

  @override
  State<AgentWorkflowNode> createState() => _AgentWorkflowNodeState();
}

class _AgentWorkflowNodeState extends State<AgentWorkflowNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.index * 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _statusColor() {
    switch (widget.step.status) {
      case 'completed':
        return AppColors.success;
      case 'running':
        return AppColors.cyan;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  IconData _statusIcon() {
    switch (widget.step.status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'running':
        return Icons.sync_rounded;
      case 'error':
        return Icons.error_rounded;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.step.status == 'completed'
                      ? LinearGradient(
                          colors: [statusColor, statusColor.withOpacity(0.7)])
                      : null,
                  color: widget.step.status != 'completed'
                      ? statusColor.withOpacity(0.15)
                      : null,
                  boxShadow: [
                    if (widget.step.status == 'completed' ||
                        widget.step.status == 'running')
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Center(
                  child: widget.step.status == 'running'
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: statusColor,
                          ),
                        )
                      : Text(
                          widget.step.agentIcon,
                          style: const TextStyle(fontSize: 20),
                        ),
                ),
              ),
              if (!widget.isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        statusColor.withOpacity(0.6),
                        statusColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.isActive
                      ? statusColor.withOpacity(0.4)
                      : (isDark ? AppColors.darkBorder : AppColors.borderLight),
                ),
                boxShadow: [
                  if (widget.isActive)
                    BoxShadow(
                      color: statusColor.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.step.agentName,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Icon(_statusIcon(), color: statusColor, size: 18),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.step.durationMs}ms',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.step.action,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 10),
                  // Confidence Bar
                  Row(
                    children: [
                      Text(
                        'Confidence',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textDarkSecondary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: widget.step.confidence,
                            minHeight: 5,
                            backgroundColor: isDark
                                ? AppColors.darkBorder
                                : AppColors.surfaceGray,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(statusColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(widget.step.confidence * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Output
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBg.withOpacity(0.5)
                          : AppColors.surfaceGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.step.outputSummary,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.cyanLight
                            : AppColors.electricBlue,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  // Detail chips
                  if (widget.step.details.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.step.details.entries.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.purpleDeep.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${e.key}: ${e.value}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.purpleLight
                                  : AppColors.purpleDeep,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
