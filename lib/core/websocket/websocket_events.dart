import 'dart:convert';

enum WSEventType { agentTrace, workflowState, unknown }

class WSEvent {
  final WSEventType type;
  final Map<String, dynamic> data;

  WSEvent({required this.type, required this.data});

  factory WSEvent.fromJson(String source) {
    try {
      final map = json.decode(source) as Map<String, dynamic>;
      final typeStr = map['type'] as String?;
      
      WSEventType type;
      switch (typeStr) {
        case 'agent_trace':
          type = WSEventType.agentTrace;
          break;
        case 'workflow_state':
          type = WSEventType.workflowState;
          break;
        default:
          type = WSEventType.unknown;
      }

      return WSEvent(
        type: type,
        data: map['data'] as Map<String, dynamic>? ?? {},
      );
    } catch (e) {
      return WSEvent(type: WSEventType.unknown, data: {});
    }
  }
}
