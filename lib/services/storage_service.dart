import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../models/command.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Last connected IP
  Future<void> saveLastIpAddress(String ip) async {
    await _prefs?.setString(AppConstants.keyLastIpAddress, ip);
  }

  String? getLastIpAddress() {
    return _prefs?.getString(AppConstants.keyLastIpAddress);
  }

  // Auto-connect preference
  Future<void> setAutoConnect(bool enabled) async {
    await _prefs?.setBool(AppConstants.keyAutoConnect, enabled);
  }

  bool getAutoConnect() {
    return _prefs?.getBool(AppConstants.keyAutoConnect) ?? false;
  }

  // Haptic feedback preference
  Future<void> setHapticEnabled(bool enabled) async {
    await _prefs?.setBool(AppConstants.keyHapticEnabled, enabled);
  }

  bool getHapticEnabled() {
    return _prefs?.getBool(AppConstants.keyHapticEnabled) ?? true;
  }

  // Command persistence
  Future<void> saveCommands(List<Command> commands) async {
    final jsonList = commands.map((cmd) => cmd.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs?.setString(AppConstants.keyCustomCommands, jsonString);
  }

  Future<List<Command>> loadCommands() async {
    final jsonString = _prefs?.getString(AppConstants.keyCustomCommands);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Command.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearCustomCommands() async {
    await _prefs?.remove(AppConstants.keyCustomCommands);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
