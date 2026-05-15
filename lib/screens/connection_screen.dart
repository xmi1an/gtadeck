import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../providers/connection_provider.dart';
import '../models/connection_state.dart';
import 'control_deck_screen.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final _ipController = TextEditingController();
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _loadLastIpAndConnect();
  }

  void _loadLastIpAndConnect() async {
    final lastIp = await ref.read(lastIpAddressProvider.future);
    if (lastIp != null && mounted) {
      _ipController.text = lastIp;
      // Auto-connect if IP exists
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _connect();
      }
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _showError('Please enter a valid IP address');
      return;
    }

    setState(() => _isConnecting = true);

    try {
      await ref.read(connectionStateProvider.notifier).connect(ip);

      await Future.delayed(const Duration(milliseconds: 500));

      final connectionState = ref.read(connectionStateProvider);
      if (connectionState.isConnected && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ControlDeckScreen()),
        );
      } else if (connectionState.hasError) {
        _showError(connectionState.errorMessage ?? 'Connection failed');
      }
    } catch (e) {
      _showError('Failed to connect: $e');
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.dangerRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.computer,
                size: 80,
                color: AppColors.gtaGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'Connect to PC',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.gtaGreen,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your PC\'s IP address to establish connection',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _ipController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'PC IP Address',
                  hintText: '192.168.1.100',
                  prefixIcon: Icon(Icons.wifi, color: AppColors.gtaGreen),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                enabled: !_isConnecting,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isConnecting ? null : _connect,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: AppColors.cardBackground,
                  foregroundColor: AppColors.gtaGreen,
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.gtaGreen,
                          ),
                        ),
                      )
                    : Text(
                        'CONNECT',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
              ),
              if (connectionState.hasError) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.dangerRed.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.dangerRed,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          connectionState.errorMessage ?? 'Connection failed',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.dangerRed,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.gtaBlue.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.gtaBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Setup Instructions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.gtaBlue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Run the GTADeck server on your PC\n'
                      '2. Make sure your phone and PC are on the same network\n'
                      '3. Enter your PC\'s local IP address above\n'
                      '4. Tap CONNECT to establish connection',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
