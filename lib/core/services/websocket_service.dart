import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:scholarship_app/core/api/api_config.dart';

typedef WsMessageHandler = void Function(String type, Map<String, dynamic> data);

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._();
  factory WebSocketService() => _instance;
  WebSocketService._();

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  bool _intentionalClose = false;
  bool _connected = false;

  final Map<Object, WsMessageHandler> _listeners = {};

  bool get isConnected => _connected;

  void addListener(Object key, WsMessageHandler handler) {
    _listeners[key] = handler;
  }

  void removeListener(Object key) {
    _listeners.remove(key);
  }

  Future<void> connect() async {
    if (_connected || _intentionalClose) return;

    final token = await ApiConfig.token;
    if (token == null || token.isEmpty) return;

    final baseUrl = dotenv.env['BACKEND_API_URL'] ?? '';
    if (baseUrl.isEmpty) return;

    final wsUrl = baseUrl.replaceFirst('http', 'ws');

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl/ws/notifications?token=$token'),
      );

      _channel!.stream.listen(
        (message) {
          _connected = true;
          _onMessage(message);
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          _handleDisconnect();
        },
      );

      _connected = true;
      _startHeartbeat();
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = json['type'] as String? ?? '';
      final data = (json['data'] as Map<String, dynamic>?) ?? {};
      for (final handler in _listeners.values) {
        handler(type, data);
      }
    } catch (e) {
      debugPrint('WebSocket parse error: $e');
    }
  }

  void _handleDisconnect() {
    _connected = false;
    _stopHeartbeat();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_intentionalClose) connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      try {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      } catch (_) {}
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void disconnect() {
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    _channel?.sink.close();
    _channel = null;
    _connected = false;
  }

  void reconnect() {
    _intentionalClose = false;
    disconnect();
    _intentionalClose = false;
    connect();
  }
}
