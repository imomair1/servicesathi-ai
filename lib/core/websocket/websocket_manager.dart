import 'dart:async';
import 'package:flutter/foundation.dart';
import 'websocket_service.dart';

class WebSocketManager {
  final WebSocketService service;
  String? _currentUrl;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  WebSocketManager(this.service) {
    service.isConnected.listen((connected) {
      if (!connected && _currentUrl != null) {
        _scheduleReconnect();
      } else if (connected) {
        _reconnectAttempts = 0;
        _reconnectTimer?.cancel();
      }
    });
  }

  void subscribeToWorkflow(String wsBaseUrl, String workflowId) {
    _currentUrl = '\$wsBaseUrl/workflow/\$workflowId';
    service.connect(_currentUrl!);
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      if (kDebugMode) print('WS: Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    // Exponential backoff
    final delay = Duration(seconds: 2 * (_reconnectAttempts + 1));
    
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      if (kDebugMode) print('WS: Reconnecting attempt \$_reconnectAttempts...');
      if (_currentUrl != null) {
        service.connect(_currentUrl!);
      }
    });
  }

  void disconnect() {
    _currentUrl = null;
    _reconnectTimer?.cancel();
    service.disconnect();
  }
}
