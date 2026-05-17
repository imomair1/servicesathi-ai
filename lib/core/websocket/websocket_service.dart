import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'websocket_events.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  
  final _eventController = StreamController<WSEvent>.broadcast();
  Stream<WSEvent> get events => _eventController.stream;

  final _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get isConnected => _connectionStateController.stream;

  bool _connected = false;

  void connect(String url) {
    if (_connected) return;

    try {
      if (kDebugMode) print('WS: Connecting to \$url');
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _connected = true;
      _connectionStateController.add(true);

      _subscription = _channel?.stream.listen(
        (message) {
          if (kDebugMode) print('WS Message: \$message');
          final event = WSEvent.fromJson(message.toString());
          _eventController.add(event);
        },
        onError: (error) {
          if (kDebugMode) print('WS Error: \$error');
          _handleDisconnect();
        },
        onDone: () {
          if (kDebugMode) print('WS Disconnected');
          _handleDisconnect();
        },
      );
    } catch (e) {
      if (kDebugMode) print('WS Connection Error: \$e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _connected = false;
    _connectionStateController.add(false);
    _cleanup();
  }

  void _cleanup() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void disconnect() {
    _handleDisconnect();
  }

  void dispose() {
    _cleanup();
    _eventController.close();
    _connectionStateController.close();
  }
}
