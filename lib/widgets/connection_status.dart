import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../models/connection_state.dart';
import '../providers/connection_provider.dart';

class ConnectionStatusWidget extends ConsumerWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionStateProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(connectionState.status).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIndicator(connectionState.status),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getStatusText(connectionState.status),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _getStatusColor(connectionState.status),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (connectionState.serverIp != null) ...[
                const SizedBox(height: 2),
                Text(
                  connectionState.serverIp!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                ),
              ],
              if (connectionState.latency != null && connectionState.isConnected) ...[
                const SizedBox(height: 2),
                Text(
                  '${connectionState.latency}ms',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(ConnectionStatus status) {
    final color = _getStatusColor(status);
    final isAnimated = status == ConnectionStatus.connecting ||
        status == ConnectionStatus.reconnecting;

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: isAnimated
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.3, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(opacity: value);
              },
              onEnd: () {},
            )
          : null,
    );
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return AppColors.healthGreen;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return AppColors.warningYellow;
      case ConnectionStatus.error:
        return AppColors.dangerRed;
      case ConnectionStatus.disconnected:
        return AppColors.textMuted;
    }
  }

  String _getStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting...';
      case ConnectionStatus.error:
        return 'Connection Error';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }
}
