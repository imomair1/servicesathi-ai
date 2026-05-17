class WorkflowStartRequest {
  final String query;
  final String userId;
  final Map<String, double>? currentLocation;

  WorkflowStartRequest({
    required this.query,
    required this.userId,
    this.currentLocation,
  });

  Map<String, dynamic> toJson() => {
        'query': query,
        'user_id': userId,
        'current_location': currentLocation,
      };
}

class WorkflowStartResponse {
  final String status;
  final String workflowId;
  final String message;

  WorkflowStartResponse({
    required this.status,
    required this.workflowId,
    required this.message,
  });

  factory WorkflowStartResponse.fromJson(Map<String, dynamic> json) {
    return WorkflowStartResponse(
      status: json['status'] ?? '',
      workflowId: json['workflow_id'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
