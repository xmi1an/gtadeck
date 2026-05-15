class AppConstants {
  // Network
  static const int defaultPort = 8080;
  static const String defaultProtocol = 'ws';
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const Duration reconnectDelay = Duration(seconds: 3);
  static const Duration heartbeatInterval = Duration(seconds: 10);

  // Storage Keys
  static const String keyLastIpAddress = 'last_ip_address';
  static const String keyAutoConnect = 'auto_connect';
  static const String keyHapticEnabled = 'haptic_enabled';
  static const String keyCustomCommands = 'custom_commands';

  // App Info
  static const String appName = 'GTADeck';
  static const String appVersion = '1.0.0';

  // Command Categories
  static const String categoryQuickActions = 'Quick Actions';
  static const String categoryVehicle = 'Vehicle';
  static const String categoryCharacter = 'Character';
  static const String categoryUtility = 'Utility';
  static const String categoryCustom = 'Custom';
}
