import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../widgets/agent_node.dart';
import '../features/workflow/providers/workflow_providers.dart';

class AgentWorkflowScreen extends ConsumerStatefulWidget {
  const AgentWorkflowScreen({super.key});

  @override
  ConsumerState<AgentWorkflowScreen> createState() => _AgentWorkflowScreenState();
}

class _AgentWorkflowScreenState extends ConsumerState<AgentWorkflowScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Read from realtime websocket state
    final steps = ref.watch(workflowTimelineProvider);
    final totalMs = steps.fold<int>(0, (sum, s) => sum + s.durationMs);
    final completedCount = steps.where((s) => s.status == 'completed').length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Futuristic Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBg : AppColors.surfaceLight,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.deepBlue, Color(0xFF1A0A38)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Grid lines effect
                    ...List.generate(6, (i) {
                      return Positioned(
                        left: 0,
                        right: 0,
                        top: 40.0 * i,
                        child: Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.03),
                        ),
                      );
                    }),
                    // Content
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          24, MediaQuery.of(context).padding.top + 50, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _headerController,
                                builder: (context, child) {
                                  return Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.cyan,
                                          AppColors.purpleDeep
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.cyan.withOpacity(
                                              0.3 * _headerController.value),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.hub_rounded,
                                        color: Colors.white, size: 26),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Agent Workflow',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Live multi-agent execution log',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Stats row
                          Row(
                            children: [
                              _HeaderStat(
                                  '\${steps.length}', 'Agents', AppColors.cyan),
                              const SizedBox(width: 20),
                              _HeaderStat(
                                  '\${totalMs}ms', 'Total Time', AppColors.success),
                              const SizedBox(width: 20),
                              _HeaderStat(
                                '\$completedCount/\${steps.length}',
                                'Completed',
                                AppColors.purpleMid,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Agent Pipeline Visualization
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.timeline, color: AppColors.electricBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Execution Pipeline',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),

          if (steps.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Text(
                    "Waiting for orchestration events...",
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),

          // Agent Nodes
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final step = steps[index];
                  return AgentWorkflowNode(
                    step: step,
                    isActive: step.status == 'running' || step.status == 'error',
                    isLast: index == steps.length - 1,
                    index: index,
                  );
                },
                childCount: steps.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _HeaderStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
