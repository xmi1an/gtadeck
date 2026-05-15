enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class ConnectionState {
  final ConnectionStatus status;
  final String? serverIp;
  final String? errorMessage;
  final DateTime? connectedAt;
  final int? latency;

  const ConnectionState({
    required this.status,
    this.serverIp,
    this.errorMessage,
    this.connectedAt,
    this.latency,
  });

  factory ConnectionState.initial() {
    return const ConnectionState(
      status: ConnectionStatus.disconnected,
    );
  }

  ConnectionState copyWith({
    ConnectionStatus? status,
    String? serverIp,
    String? errorMessage,
    DateTime? connectedAt,
    int? latency,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      serverIp: serverIp ?? this.serverIp,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedAt: connectedAt ?? this.connectedAt,
      latency: latency ?? this.latency,
    );
  }

  bool get isConnected => status == ConnectionStatus.connected;
  bool get isConnecting => status == ConnectionStatus.connecting || status == ConnectionStatus.reconnecting;
  bool get hasError => status == ConnectionStatus.error;
}
