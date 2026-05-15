import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/command.dart';
import '../core/constants/app_constants.dart';
import '../services/storage_service.dart';
import 'connection_provider.dart';

// Default commands
final _defaultCommands = [
  // Quick Actions
  const Command(
    id: 'map',
    label: 'Map',
    icon: '🗺️',
    type: CommandType.keyboardPress,
    payload: {'key': 'M'},
    category: AppConstants.categoryQuickActions,
    description: 'Open game map',
  ),
  const Command(
    id: 'phone',
    label: 'Phone',
    icon: '📱',
    type: CommandType.keyboardPress,
    payload: {'key': 'Up'},
    category: AppConstants.categoryQuickActions,
    description: 'Open phone',
  ),
  const Command(
    id: 'interaction_menu',
    label: 'Interaction',
    icon: '🎮',
    type: CommandType.keyboardHold,
    payload: {'key': 'M', 'duration': 1000},
    category: AppConstants.categoryQuickActions,
    description: 'Interaction menu',
  ),
  const Command(
    id: 'quick_gps',
    label: 'Quick GPS',
    icon: '📍',
    type: CommandType.keyboardPress,
    payload: {'key': 'Up', 'double': true},
    category: AppConstants.categoryQuickActions,
    description: 'Set GPS waypoint',
  ),

  // Vehicle
  const Command(
    id: 'call_mechanic',
    label: 'Mechanic',
    icon: '🔧',
    type: CommandType.macro,
    payload: {
      'steps': [
        {'key': 'Up', 'delay': 400},
        {'key': 'Up', 'delay': 400},
        {'key': 'Right', 'delay': 400},
        {'key': 'Enter', 'delay': 400},
        {'key': 'Right', 'delay': 400},
        {'key': 'Right', 'delay': 400},
        {'key': 'Down', 'delay': 400},
        {'key': 'Down', 'delay': 400},
        {'key': 'Enter', 'delay': 400},
      ]
    },
    category: AppConstants.categoryVehicle,
    description: 'Call mechanic',
  ),
  const Command(
    id: 'request_vehicle',
    label: 'Request Vehicle',
    icon: '🚗',
    type: CommandType.macro,
    payload: {
      'steps': [
        {'key': 'M', 'hold': 1000},
        {'key': 'Down', 'delay': 200},
        {'key': 'Enter', 'delay': 200},
      ]
    },
    category: AppConstants.categoryVehicle,
    description: 'Request personal vehicle',
  ),
  const Command(
    id: 'call_sparrow',
    label: 'Sparrow',
    icon: '🚁',
    type: CommandType.macro,
    payload: {
      'steps': [
        {'key': 'M', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Up', 'delay': 20},
        {'key': 'Up', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
      ]
    },
    category: AppConstants.categoryVehicle,
    description: 'Call Sparrow helicopter',
    longPressType: CommandType.macro,
    longPressPayload: {
      'steps': [
        {'key': 'M', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Up', 'delay': 20},
        {'key': 'Up', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Up', 'delay': 20},
        {'key': 'Up', 'delay': 20},
      ]
    },
  ),
  const Command(
    id: 'call_kosatka',
    label: 'Kosatka',
    icon: '🛥️',
    type: CommandType.macro,
    payload: {
      'steps': [
        {'key': 'M', 'delay': 10},
        {'key': 'Down', 'delay': 10},
        {'key': 'Down', 'delay': 10},
        {'key': 'Down', 'delay': 10},
        {'key': 'Enter', 'delay': 10},
        {'key': 'Up', 'delay': 10},
        {'key': 'Up', 'delay': 10},
        {'key': 'Enter', 'delay': 10},
        {'key': 'Enter', 'delay': 10},
      ]
    },
    category: AppConstants.categoryVehicle,
    description: 'Call Kosatka submarine',
  ),

  // Character
  const Command(
    id: 'eat_snack',
    label: 'Eat Snack',
    icon: '🍔',
    type: CommandType.macro,
    payload: {
      'steps': [
        {'key': 'M', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Down', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
        {'key': 'Enter', 'delay': 20},
      ]
    },
    category: AppConstants.categoryCharacter,
    description: 'Eat snack (restore health)',
  ),
  const Command(
    id: 'armor',
    label: 'Armor',
    icon: '🛡️',
    type: CommandType.macro,
    payload: {
      'steps': [
        {'key': 'M', 'hold': 1000},
        {'key': 'Right', 'delay': 200},
        {'key': 'Down', 'delay': 200},
        {'key': 'Enter', 'delay': 200},
      ]
    },
    category: AppConstants.categoryCharacter,
    description: 'Use armor',
  ),
  const Command(
    id: 'passive_mode',
    label: 'Passive Mode',
    icon: '☮️',
    type: CommandType.macro,
    payload: {
      'steps': [
        {'key': 'M', 'hold': 1000},
        {'key': 'Down', 'delay': 200},
        {'key': 'Down', 'delay': 200},
        {'key': 'Down', 'delay': 200},
        {'key': 'Enter', 'delay': 200},
      ]
    },
    category: AppConstants.categoryCharacter,
    description: 'Toggle passive mode',
  ),

  // Utility
  const Command(
    id: 'quick_save',
    label: 'Quick Save',
    icon: '💾',
    type: CommandType.keyboardPress,
    payload: {'key': 'F5'},
    category: AppConstants.categoryUtility,
    description: 'Quick save game',
  ),
  const Command(
    id: 'screenshot',
    label: 'Screenshot',
    icon: '📸',
    type: CommandType.keyboardPress,
    payload: {'key': 'F12'},
    category: AppConstants.categoryUtility,
    description: 'Take screenshot',
  ),
  const Command(
    id: 'record_clip',
    label: 'Record',
    icon: '🎬',
    type: CommandType.keyboardPress,
    payload: {'key': 'F1'},
    category: AppConstants.categoryUtility,
    description: 'Start/stop recording',
  ),
];

final commandsProvider = StateNotifierProvider<CommandsNotifier, List<Command>>((ref) {
  return CommandsNotifier(ref);
});

class CommandsNotifier extends StateNotifier<List<Command>> {
  final Ref _ref;
  final _uuid = const Uuid();

  CommandsNotifier(this._ref) : super([]) {
    _loadCommands();
  }

  Future<void> _loadCommands() async {
    try {
      final storage = await _ref.read(storageServiceProvider.future);
      final savedCommands = await storage.loadCommands();

      if (savedCommands.isEmpty) {
        state = List.from(_defaultCommands);
      } else {
        // Merge saved commands with defaults (saved overrides default by ID)
        final commandMap = <String, Command>{};

        // Add defaults first
        for (final cmd in _defaultCommands) {
          commandMap[cmd.id] = cmd;
        }

        // Override with saved commands
        for (final cmd in savedCommands) {
          commandMap[cmd.id] = cmd;
        }

        state = commandMap.values.toList();
      }
    } catch (e) {
      // Fallback to defaults on error
      state = List.from(_defaultCommands);
    }
  }

  Future<void> _saveCommands() async {
    try {
      final storage = await _ref.read(storageServiceProvider.future);
      await storage.saveCommands(state);
    } catch (e) {
      // Handle save error silently
    }
  }

  void addCommand(Command command) {
    // Generate unique ID if not provided
    final newCommand = command.id.isEmpty
        ? command.copyWith(id: _uuid.v4())
        : command;

    state = [...state, newCommand];
    _saveCommands();
  }

  void updateCommand(String id, Command updatedCommand) {
    state = [
      for (final cmd in state)
        if (cmd.id == id) updatedCommand else cmd
    ];
    _saveCommands();
  }

  void deleteCommand(String id) {
    state = state.where((cmd) => cmd.id != id).toList();
    _saveCommands();
  }

  void reorderCommands(String category, int oldIndex, int newIndex) {
    // Get commands in this category
    final categoryCommands = state.where((cmd) => cmd.category == category).toList();
    final otherCommands = state.where((cmd) => cmd.category != category).toList();

    // Reorder within category
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final command = categoryCommands.removeAt(oldIndex);
    categoryCommands.insert(newIndex, command);

    // Rebuild state maintaining order
    state = [...otherCommands, ...categoryCommands];
    _saveCommands();
  }

  Future<void> resetToDefaults() async {
    state = List.from(_defaultCommands);
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.clearCustomCommands();
  }

  Command? getCommandById(String id) {
    try {
      return state.firstWhere((cmd) => cmd.id == id);
    } catch (e) {
      return null;
    }
  }
}

final commandsByCategoryProvider = Provider<Map<String, List<Command>>>((ref) {
  final commands = ref.watch(commandsProvider);
  final Map<String, List<Command>> categorized = {};

  for (final command in commands) {
    if (!categorized.containsKey(command.category)) {
      categorized[command.category] = [];
    }
    categorized[command.category]!.add(command);
  }

  return categorized;
});

final commandExecutorProvider = Provider<CommandExecutor>((ref) {
  return CommandExecutor(ref);
});

class CommandExecutor {
  final Ref _ref;

  CommandExecutor(this._ref);

  Future<void> execute(Command command) async {
    final connectionNotifier = _ref.read(connectionStateProvider.notifier);

    switch (command.type) {
      case CommandType.keyboardPress:
        await connectionNotifier.sendCommand('keyboard_press', command.payload);
        break;
      case CommandType.keyboardHold:
        await connectionNotifier.sendCommand('keyboard_hold', command.payload);
        break;
      case CommandType.macro:
        await connectionNotifier.sendCommand('macro', command.payload);
        break;
      case CommandType.custom:
        await connectionNotifier.sendCommand('custom', command.payload);
        break;
    }
  }
}
