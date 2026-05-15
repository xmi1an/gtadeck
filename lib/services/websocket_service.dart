import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/app_constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<bool>.broadcast();
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  String? _serverUrl;
  bool _isDisposed = false;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<bool> get statusStream => _statusController.stream;
  bool get isConnected => _channel != null;

  Future<void> connect(String serverIp, {int port = 8080}) async {
    if (_isDisposed) return;

    _serverUrl = 'ws://$serverIp:$port';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl!));

      await _channel!.ready.timeout(
        AppConstants.connectionTimeout,
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );

      _statusController.add(true);
      _startHeartbeat();
      _listenToMessages();
    } catch (e) {
      _statusController.add(false);
      _channel = null;
      rethrow;
    }
  }

  void _listenToMessages() {
    _channel?.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          _messageController.add(data);
        } catch (e) {
          // Invalid JSON, ignore
        }
      },
      onError: (error) {
        _statusController.add(false);
        _attemptReconnect();
      },
      onDone: () {
        _statusController.add(false);
        _attemptReconnect();
      },
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(AppConstants.heartbeatInterval, (timer) {
      if (_channel != null) {
        sendMessage({
          'type': 'ping',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }

  void _attemptReconnect() {
    if (_isDisposed || _reconnectTimer != null) return;

    _reconnectTimer = Timer(AppConstants.reconnectDelay, () {
      _reconnectTimer = null;
      if (_serverUrl != null && !_isDisposed) {
        final uri = Uri.parse(_serverUrl!);
        connect(uri.host, port: uri.port);
      }
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        // Connection lost
        _statusController.add(false);
      }
    }
  }

  Future<void> sendCommand(String action, Map<String, dynamic> payload) async {
    sendMessage({
      'type': 'command',
      'action': action,
      'payload': payload,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _statusController.add(false);
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    _messageController.close();
    _statusController.close();
  }
}
