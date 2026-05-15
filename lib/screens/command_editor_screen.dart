import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/command.dart';
import '../providers/commands_provider.dart';
import '../widgets/key_selector.dart';

class MacroStep {
  String key;
  int delay;
  bool isHold;
  int holdDuration;

  MacroStep({
    required this.key,
    this.delay = 200,
    this.isHold = false,
    this.holdDuration = 1000,
  });

  Map<String, dynamic> toJson() {
    if (isHold) {
      return {'key': key, 'hold': holdDuration};
    } else {
      return {'key': key, 'delay': delay};
    }
  }

  factory MacroStep.fromJson(Map<String, dynamic> json) {
    final hasHold = json.containsKey('hold');
    return MacroStep(
      key: json['key'] as String,
      delay: json['delay'] as int? ?? 200,
      isHold: hasHold,
      holdDuration: json['hold'] as int? ?? 1000,
    );
  }
}

class CommandEditorScreen extends ConsumerStatefulWidget {
  final String? commandId;

  const CommandEditorScreen({super.key, this.commandId});

  @override
  ConsumerState<CommandEditorScreen> createState() => _CommandEditorScreenState();
}

class _CommandEditorScreenState extends ConsumerState<CommandEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _iconController;
  late TextEditingController _descriptionController;
  late TextEditingController _holdDurationController;
  late TextEditingController _longPressHoldDurationController;

  String _selectedCategory = AppConstants.categoryQuickActions;
  CommandType _selectedType = CommandType.keyboardPress;
  String? _selectedKey;
  int _holdDuration = 10;
  List<MacroStep> _macroSteps = [];
  bool _isEditing = false;

  // Long-press action
  bool _hasLongPressAction = false;
  CommandType _longPressType = CommandType.keyboardPress;
  String? _longPressKey;
  int _longPressHoldDuration = 10;
  List<MacroStep> _longPressMacroSteps = [];

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _iconController = TextEditingController();
    _descriptionController = TextEditingController();
    _holdDurationController = TextEditingController(text: '10');
    _longPressHoldDurationController = TextEditingController(text: '10');

    if (widget.commandId != null) {
      _isEditing = true;
      _loadCommand();
    }
  }

  void _loadCommand() {
    final command = ref.read(commandsProvider.notifier).getCommandById(widget.commandId!);
    if (command != null) {
      _labelController.text = command.label;
      _iconController.text = command.icon;
      _descriptionController.text = command.description ?? '';
      _selectedCategory = command.category;
      _selectedType = command.type;

      // Load payload based on type
      if (command.type == CommandType.keyboardPress) {
        _selectedKey = command.payload['key'] as String?;
      } else if (command.type == CommandType.keyboardHold) {
        _selectedKey = command.payload['key'] as String?;
        _holdDuration = command.payload['duration'] as int? ?? 10;
        _holdDurationController.text = _holdDuration.toString();
      } else if (command.type == CommandType.macro) {
        final steps = command.payload['steps'] as List<dynamic>?;
        if (steps != null) {
          _macroSteps = steps
              .map((s) => MacroStep.fromJson(s as Map<String, dynamic>))
              .toList();
        }
      }

      // Load long-press action
      if (command.longPressType != null && command.longPressPayload != null) {
        _hasLongPressAction = true;
        _longPressType = command.longPressType!;

        if (command.longPressType == CommandType.keyboardPress) {
          _longPressKey = command.longPressPayload!['key'] as String?;
        } else if (command.longPressType == CommandType.keyboardHold) {
          _longPressKey = command.longPressPayload!['key'] as String?;
          _longPressHoldDuration = command.longPressPayload!['duration'] as int? ?? 10;
          _longPressHoldDurationController.text = _longPressHoldDuration.toString();
        } else if (command.longPressType == CommandType.macro) {
          final steps = command.longPressPayload!['steps'] as List<dynamic>?;
          if (steps != null) {
            _longPressMacroSteps = steps
                .map((s) => MacroStep.fromJson(s as Map<String, dynamic>))
                .toList();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _iconController.dispose();
    _descriptionController.dispose();
    _holdDurationController.dispose();
    _longPressHoldDurationController.dispose();
    super.dispose();
  }

  void _saveCommand() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == CommandType.macro) {
      if (_macroSteps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Macro must have at least one step'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
        return;
      }
    } else {
      if (_selectedKey == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a key'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
        return;
      }
    }

    final payload = _buildPayload();

    // Build long-press payload if enabled
    Map<String, dynamic>? longPressPayload;
    CommandType? longPressType;

    if (_hasLongPressAction) {
      longPressType = _longPressType;
      longPressPayload = _buildLongPressPayload();
    }

    final command = Command(
      id: widget.commandId ?? '',
      label: _labelController.text.trim(),
      icon: _iconController.text.trim().isEmpty ? '⚡' : _iconController.text.trim(),
      type: _selectedType,
      payload: payload,
      category: _selectedCategory,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      longPressType: longPressType,
      longPressPayload: longPressPayload,
    );

    if (_isEditing) {
      ref.read(commandsProvider.notifier).updateCommand(widget.commandId!, command);
    } else {
      ref.read(commandsProvider.notifier).addCommand(command);
    }

    Navigator.of(context).pop();
  }

  Map<String, dynamic> _buildPayload() {
    switch (_selectedType) {
      case CommandType.keyboardPress:
        return {'key': _selectedKey!};
      case CommandType.keyboardHold:
        final duration = int.tryParse(_holdDurationController.text) ?? 10;
        return {'key': _selectedKey!, 'duration': duration};
      case CommandType.macro:
        return {
          'steps': _macroSteps.map((step) => step.toJson()).toList()
        };
      case CommandType.custom:
        return {'key': _selectedKey!};
    }
  }

  Map<String, dynamic>? _buildLongPressPayload() {
    if (!_hasLongPressAction) return null;

    switch (_longPressType) {
      case CommandType.keyboardPress:
        return _longPressKey != null ? {'key': _longPressKey!} : null;
      case CommandType.keyboardHold:
        final duration = int.tryParse(_longPressHoldDurationController.text) ?? 10;
        return _longPressKey != null ? {'key': _longPressKey!, 'duration': duration} : null;
      case CommandType.macro:
        return _longPressMacroSteps.isNotEmpty
            ? {'steps': _longPressMacroSteps.map((step) => step.toJson()).toList()}
            : null;
      case CommandType.custom:
        return _longPressKey != null ? {'key': _longPressKey!} : null;
    }
  }

  void _deleteCommand() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Delete Command',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.dangerRed,
              ),
        ),
        content: Text(
          'Are you sure you want to delete this command?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(commandsProvider.notifier).deleteCommand(widget.commandId!);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Command' : 'New Command'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.dangerRed),
              onPressed: _deleteCommand,
              tooltip: 'Delete',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g., Open Map',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Label is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _iconController,
              decoration: const InputDecoration(
                labelText: 'Icon (Emoji)',
                hintText: 'e.g., 🗺️',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              dropdownColor: AppColors.cardBackground,
              items: [
                AppConstants.categoryQuickActions,
                AppConstants.categoryVehicle,
                AppConstants.categoryCharacter,
                AppConstants.categoryUtility,
                AppConstants.categoryCustom,
              ].map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., Open game map',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Text(
              'Command Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.gtaGreen,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<CommandType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
              ),
              dropdownColor: AppColors.cardBackground,
              items: [
                CommandType.keyboardPress,
                CommandType.keyboardHold,
                CommandType.macro,
              ].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 24),
            if (_selectedType == CommandType.macro) ...[
              _buildMacroStepsEditor(),
            ] else ...[
              KeySelector(
                selectedKey: _selectedKey,
                onKeySelected: (key) {
                  setState(() => _selectedKey = key);
                },
                label: 'Key',
              ),
            ],
            if (_selectedType == CommandType.keyboardHold) ...[
              const SizedBox(height: 24),
              TextFormField(
                controller: _holdDurationController,
                decoration: const InputDecoration(
                  labelText: 'Hold Duration (ms)',
                  hintText: 'e.g., 10',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Duration is required';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration < 1) {
                    return 'Enter a valid duration (minimum 1ms)';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 32),
            Divider(color: AppColors.gtaGreen.withOpacity(0.3)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Long-Press Action',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.gtaGreen,
                      ),
                ),
                Switch(
                  value: _hasLongPressAction,
                  activeColor: AppColors.gtaGreen,
                  onChanged: (value) {
                    setState(() => _hasLongPressAction = value);
                  },
                ),
              ],
            ),
            if (_hasLongPressAction) ...[
              const SizedBox(height: 16),
              Text(
                'Configure what happens when you hold this button',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CommandType>(
                value: _longPressType,
                decoration: const InputDecoration(
                  labelText: 'Long-Press Type',
                ),
                dropdownColor: AppColors.cardBackground,
                items: [
                  CommandType.keyboardPress,
                  CommandType.keyboardHold,
                  CommandType.macro,
                ].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _longPressType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_longPressType == CommandType.macro) ...[
                _buildLongPressMacroEditor(),
              ] else ...[
                KeySelector(
                  selectedKey: _longPressKey,
                  onKeySelected: (key) {
                    setState(() => _longPressKey = key);
                  },
                  label: 'Long-Press Key',
                ),
              ],
              if (_longPressType == CommandType.keyboardHold) ...[
                const SizedBox(height: 16),
                Text(
                  'Hold Duration: ${_longPressHoldDuration}ms',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.gtaGreen,
                      ),
                ),
                Slider(
                  value: _longPressHoldDuration.toDouble(),
                  min: 100,
                  max: 5000,
                  divisions: 49,
                  activeColor: AppColors.gtaGreen,
                  inactiveColor: AppColors.gtaGreen.withOpacity(0.3),
                  onChanged: (value) {
                    setState(() => _longPressHoldDuration = value.toInt());
                  },
                ),
              ],
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveCommand,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _isEditing ? 'SAVE CHANGES' : 'CREATE COMMAND',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(CommandType type) {
    switch (type) {
      case CommandType.keyboardPress:
        return 'Keyboard Press';
      case CommandType.keyboardHold:
        return 'Keyboard Hold';
      case CommandType.macro:
        return 'Macro';
      case CommandType.custom:
        return 'Custom';
    }
  }

  Widget _buildMacroStepsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Macro Steps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.gtaGreen,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: _addMacroStep,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('ADD STEP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gtaGreen,
                foregroundColor: AppColors.darkBackground,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_macroSteps.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.gtaGreen.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                'No steps added yet.\nTap "ADD STEP" to create your macro.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: _macroSteps.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final step = _macroSteps.removeAt(oldIndex);
                _macroSteps.insert(newIndex, step);
              });
            },
            itemBuilder: (context, index) {
              return _buildMacroStepCard(index);
            },
          ),
      ],
    );
  }

  Widget _buildMacroStepCard(int index) {
    final step = _macroSteps[index];

    return Card(
      key: ValueKey('step_$index'),
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.gtaGreen.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Step ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.gtaGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.dangerRed, size: 20),
                  onPressed: () => _removeMacroStep(index),
                  tooltip: 'Delete step',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            KeySelector(
              selectedKey: step.key,
              onKeySelected: (key) {
                setState(() {
                  _macroSteps[index].key = key;
                });
              },
              label: 'Key',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Hold Key',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const Spacer(),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: step.isHold,
                    activeColor: AppColors.gtaGreen,
                    onChanged: (value) {
                      setState(() {
                        _macroSteps[index].isHold = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (step.isHold) ...[
              TextFormField(
                initialValue: step.holdDuration.toString(),
                decoration: const InputDecoration(
                  labelText: 'Hold Duration (ms)',
                  hintText: 'e.g., 10',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontSize: 14),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final duration = int.tryParse(value);
                  if (duration != null && duration >= 1) {
                    setState(() {
                      _macroSteps[index].holdDuration = duration;
                    });
                  }
                },
              ),
            ] else ...[
              TextFormField(
                initialValue: step.delay.toString(),
                decoration: const InputDecoration(
                  labelText: 'Delay After (ms)',
                  hintText: 'e.g., 10',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontSize: 14),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final delay = int.tryParse(value);
                  if (delay != null && delay >= 0) {
                    setState(() {
                      _macroSteps[index].delay = delay;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addMacroStep() {
    setState(() {
      _macroSteps.add(MacroStep(key: 'M'));
    });
  }

  void _removeMacroStep(int index) {
    setState(() {
      _macroSteps.removeAt(index);
    });
  }

  Widget _buildLongPressMacroEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Long-Press Macro Steps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.gtaGreen,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: _addLongPressMacroStep,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('ADD STEP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gtaGreen,
                foregroundColor: AppColors.darkBackground,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_longPressMacroSteps.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.gtaGreen.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                'No steps added yet.\nTap "ADD STEP" to create your macro.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: _longPressMacroSteps.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final step = _longPressMacroSteps.removeAt(oldIndex);
                _longPressMacroSteps.insert(newIndex, step);
              });
            },
            itemBuilder: (context, index) {
              return _buildLongPressMacroStepCard(index);
            },
          ),
      ],
    );
  }

  Widget _buildLongPressMacroStepCard(int index) {
    final step = _longPressMacroSteps[index];

    return Card(
      key: ValueKey('longpress_step_$index'),
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.gtaGreen.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Step ${index + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.gtaGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.dangerRed, size: 20),
                  onPressed: () => _removeLongPressMacroStep(index),
                  tooltip: 'Delete step',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            KeySelector(
              selectedKey: step.key,
              onKeySelected: (key) {
                setState(() {
                  _longPressMacroSteps[index].key = key;
                });
              },
              label: 'Key',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Hold Key',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const Spacer(),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: step.isHold,
                    activeColor: AppColors.gtaGreen,
                    onChanged: (value) {
                      setState(() {
                        _longPressMacroSteps[index].isHold = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (step.isHold) ...[
              TextFormField(
                initialValue: step.holdDuration.toString(),
                decoration: const InputDecoration(
                  labelText: 'Hold Duration (ms)',
                  hintText: 'e.g., 10',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontSize: 14),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final duration = int.tryParse(value);
                  if (duration != null && duration >= 1) {
                    setState(() {
                      _longPressMacroSteps[index].holdDuration = duration;
                    });
                  }
                },
              ),
            ] else ...[
              TextFormField(
                initialValue: step.delay.toString(),
                decoration: const InputDecoration(
                  labelText: 'Delay After (ms)',
                  hintText: 'e.g., 10',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontSize: 14),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final delay = int.tryParse(value);
                  if (delay != null && delay >= 0) {
                    setState(() {
                      _longPressMacroSteps[index].delay = delay;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addLongPressMacroStep() {
    setState(() {
      _longPressMacroSteps.add(MacroStep(key: 'M'));
    });
  }

  void _removeLongPressMacroStep(int index) {
    setState(() {
      _longPressMacroSteps.removeAt(index);
    });
  }
}
