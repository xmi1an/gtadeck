import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connection_state.dart';
import '../services/websocket_service.dart';
import '../services/storage_service.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return await StorageService.getInstance();
});

final connectionStateProvider = StateNotifierProvider<ConnectionStateNotifier, ConnectionState>((ref) {
  return ConnectionStateNotifier(ref);
});

class ConnectionStateNotifier extends StateNotifier<ConnectionState> {
  final Ref _ref;

  ConnectionStateNotifier(this._ref) : super(ConnectionState.initial()) {
    _initializeConnection();
  }

  void _initializeConnection() {
    final wsService = _ref.read(webSocketServiceProvider);

    wsService.statusStream.listen((isConnected) {
      if (isConnected) {
        state = state.copyWith(
          status: ConnectionStatus.connected,
          connectedAt: DateTime.now(),
          errorMessage: null,
        );
      } else {
        if (state.status == ConnectionStatus.connected) {
          state = state.copyWith(
            status: ConnectionStatus.reconnecting,
          );
        } else {
          state = state.copyWith(
            status: ConnectionStatus.disconnected,
            connectedAt: null,
          );
        }
      }
    });

    wsService.messageStream.listen((message) {
      if (message['type'] == 'pong') {
        final latency = DateTime.now().millisecondsSinceEpoch -
                       (message['timestamp'] as int);
        state = state.copyWith(latency: latency);
      }
    });
  }

  Future<void> connect(String serverIp) async {
    state = state.copyWith(
      status: ConnectionStatus.connecting,
      serverIp: serverIp,
      errorMessage: null,
    );

    try {
      final wsService = _ref.read(webSocketServiceProvider);
      await wsService.connect(serverIp);

      final storageAsync = _ref.read(storageServiceProvider);
      storageAsync.whenData((storage) => storage.saveLastIpAddress(serverIp));
    } catch (e) {
      state = state.copyWith(
        status: ConnectionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void disconnect() {
    final wsService = _ref.read(webSocketServiceProvider);
    wsService.disconnect();
    state = ConnectionState.initial();
  }

  Future<void> sendCommand(String action, Map<String, dynamic> payload) async {
    if (state.isConnected) {
      final wsService = _ref.read(webSocketServiceProvider);
      await wsService.sendCommand(action, payload);
    }
  }
}

final lastIpAddressProvider = FutureProvider<String?>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return storage.getLastIpAddress();
});

final hapticEnabledProvider = FutureProvider<bool>((ref) async {
  final storage = await ref.watch(storageServiceProvider.future);
  return storage.getHapticEnabled();
});
