import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/websocket/websocket_service.dart';
import '../../../core/websocket/websocket_manager.dart';
import '../../../core/websocket/websocket_events.dart';
import '../../../core/config/env_config.dart';
import '../../../models/models.dart';
import '../../../data/mock_data.dart';
import '../data/workflow_repository.dart';
import '../data/models/workflow_dto.dart';

// 1. Dependency Providers
final apiClientProvider = Provider((ref) => ApiClient());
final workflowRepositoryProvider = Provider((ref) => WorkflowRepository(ref.watch(apiClientProvider)));

final webSocketServiceProvider = Provider((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

final webSocketManagerProvider = Provider((ref) => WebSocketManager(ref.watch(webSocketServiceProvider)));

// 2. State Providers

class ActiveWorkflowState {
  final String? workflowId;
  final bool isLoading;
  final String? error;
  
  ActiveWorkflowState({this.workflowId, this.isLoading = false, this.error});
}

class ActiveWorkflowNotifier extends StateNotifier<ActiveWorkflowState> {
  final WorkflowRepository _repository;
  final WebSocketManager _wsManager;
  final Ref _ref;

  ActiveWorkflowNotifier(this._repository, this._wsManager, this._ref) 
      : super(ActiveWorkflowState());

  Future<void> startWorkflow(String query) async {
    state = ActiveWorkflowState(isLoading: true);
    
    // Clear previous timeline
    _ref.read(workflowTimelineProvider.notifier).clear();
    
    try {
      final response = await _repository.startWorkflow(WorkflowStartRequest(
        query: query,
        userId: 'user_dev_001', // Mock user for now
      ));
      
      state = ActiveWorkflowState(workflowId: response.workflowId);
      
      // Subscribe to live events
      _wsManager.subscribeToWorkflow(EnvConfig.wsBaseUrl, response.workflowId);
      
    } catch (e) {
      state = ActiveWorkflowState(error: e.toString());
    }
  }

  void cancelWorkflow() {
    _wsManager.disconnect();
    state = ActiveWorkflowState();
  }
}

final activeWorkflowProvider = StateNotifierProvider<ActiveWorkflowNotifier, ActiveWorkflowState>((ref) {
  return ActiveWorkflowNotifier(
    ref.watch(workflowRepositoryProvider),
    ref.watch(webSocketManagerProvider),
    ref,
  );
});

// 3. Timeline Provider (Listens to WS events)

class WorkflowTimelineNotifier extends StateNotifier<List<AgentStep>> {
  WorkflowTimelineNotifier() : super([]);

  void addStep(AgentStep step) {
    state = [...state, step];
  }

  void clear() {
    state = [];
  }
}

final workflowTimelineProvider = StateNotifierProvider<WorkflowTimelineNotifier, List<AgentStep>>((ref) {
  final notifier = WorkflowTimelineNotifier();
  
  // Listen to WebSocket events and update timeline
  final wsService = ref.watch(webSocketServiceProvider);
  final subscription = wsService.events.listen((event) {
    if (event.type == WSEventType.agentTrace) {
      final data = event.data;
      final step = AgentStep(
        agentName: data['agent_name'] ?? 'Unknown Agent',
        agentIcon: _getIconForAgent(data['agent_name']),
        action: data['action'] ?? '',
        status: data['status'] ?? 'pending',
        durationMs: data['duration_ms'] ?? 0,
        confidence: (data['confidence'] ?? 0.0).toDouble(),
        outputSummary: data['output_summary'] ?? '',
        details: Map<String, dynamic>.from(data['details'] ?? {}),
      );
      notifier.addStep(step);
    }
  });

  ref.onDispose(() => subscription.cancel());
  return notifier;
});

// 4. Provider Recommendations Provider
final providerRecommendationsProvider = Provider<List<ServiceProvider>>((ref) {
  final timeline = ref.watch(workflowTimelineProvider);
  
  // Find Ranking Agent's completed step
  try {
    final rankingStep = timeline.lastWhere(
      (step) => step.agentName.contains('Ranking') && step.status == 'completed'
    );
    
    // In a real app, the ranking step details would contain the raw JSON list of providers.
    if (rankingStep.details.containsKey('ranked_providers')) {
       // mapping logic here...
    }
  } catch (e) {
    // Not found
  }
  
  // Fallback to mock data for UI demo purposes if real data parsing isn't hooked up yet
  return MockData.recommendedProviders;
});

String _getIconForAgent(String? name) {
  if (name == null) return '🤖';
  if (name.contains('Intent')) return '🧠';
  if (name.contains('Discovery')) return '🔍';
  if (name.contains('Ranking')) return '📊';
  if (name.contains('Booking')) return '📋';
  if (name.contains('Follow')) return '🔔';
  return '🤖';
}
