import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/connection_provider.dart';
import '../providers/commands_provider.dart';
import '../models/command.dart';
import '../widgets/connection_status.dart';
import '../widgets/action_grid.dart';
import 'connection_screen.dart';
import 'command_editor_screen.dart';
import 'settings_screen.dart';

class ControlDeckScreen extends ConsumerStatefulWidget {
  const ControlDeckScreen({super.key});

  @override
  ConsumerState<ControlDeckScreen> createState() => _ControlDeckScreenState();
}

class _ControlDeckScreenState extends ConsumerState<ControlDeckScreen> {
  String? _loadingCommandId;
  bool _isEditMode = false;
  bool _isFullScreen = false;
  bool _isUngrouped = false;

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateProvider);
    final commandsByCategory = ref.watch(commandsByCategoryProvider);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // Update system UI overlay style based on full screen mode
    SystemChrome.setEnabledSystemUIMode(
      _isFullScreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );

    if (!connectionState.isConnected && !connectionState.isConnecting) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ConnectionScreen()),
        );
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // If in full screen or edit mode, exit those modes first
        if (_isFullScreen || _isEditMode) {
          setState(() {
            _isFullScreen = false;
            _isEditMode = false;
          });
        } else {
          // Show disconnect dialog
          _disconnect();
        }
      },
      child: Scaffold(
        appBar: _isFullScreen ? null : AppBar(
          title: const Text('GTADeck'),
          actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.gtaGreen),
              onPressed: () {
                setState(() => _isEditMode = false);
              },
              tooltip: 'Done Reordering',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: AppColors.textSecondary),
            color: AppColors.cardBackground,
            onSelected: (value) {
              if (value == 'new') {
                _openEditor();
              } else if (value == 'reset') {
                _showResetDialog();
              } else if (value == 'edit_mode') {
                setState(() => _isEditMode = !_isEditMode);
              } else if (value == 'fullscreen') {
                setState(() => _isFullScreen = !_isFullScreen);
              } else if (value == 'ungroup') {
                setState(() => _isUngrouped = !_isUngrouped);
              } else if (value == 'grid_settings') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              } else if (value == 'edit_shortcut') {
                _showEditShortcutDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit_mode',
                child: Row(
                  children: [
                    Icon(
                      _isEditMode ? Icons.check_box : Icons.check_box_outline_blank,
                      color: AppColors.gtaGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text('Reorder Mode', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'fullscreen',
                child: Row(
                  children: [
                    Icon(
                      _isFullScreen ? Icons.check_box : Icons.check_box_outline_blank,
                      color: AppColors.gtaGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text('Full Screen', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'ungroup',
                child: Row(
                  children: [
                    Icon(
                      _isUngrouped ? Icons.check_box : Icons.check_box_outline_blank,
                      color: AppColors.gtaGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text('Ungroup Categories', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'grid_settings',
                child: Row(
                  children: [
                    const Icon(Icons.grid_view, color: AppColors.gtaGreen, size: 20),
                    const SizedBox(width: 12),
                    Text('Grid Settings', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'edit_shortcut',
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: AppColors.gtaGreen, size: 20),
                    const SizedBox(width: 12),
                    Text('Edit Shortcut', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, color: AppColors.gtaGreen, size: 20),
                    const SizedBox(width: 12),
                    Text('New Command', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    const Icon(Icons.restart_alt, color: AppColors.warningYellow, size: 20),
                    const SizedBox(width: 12),
                    Text('Reset to Defaults', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                enabled: false,
                child: Text(
                  _isEditMode
                    ? 'Drag shortcuts to reorder them'
                    : 'Tap to execute, hold for 2nd action',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.dangerRed),
            onPressed: _disconnect,
            tooltip: 'Disconnect',
          ),
        ],
        ),
        body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(isLandscape ? 12.0 : 8.0),
                children: [
                  if (_isUngrouped)
                    _buildUngroupedGrid()
                  else ...[
                    _buildCategorySection(
                      context,
                      AppConstants.categoryQuickActions,
                      commandsByCategory[AppConstants.categoryQuickActions] ?? [],
                    ),
                    const SizedBox(height: 12),
                    _buildCategorySection(
                      context,
                      AppConstants.categoryVehicle,
                      commandsByCategory[AppConstants.categoryVehicle] ?? [],
                    ),
                    const SizedBox(height: 12),
                    _buildCategorySection(
                      context,
                      AppConstants.categoryCharacter,
                      commandsByCategory[AppConstants.categoryCharacter] ?? [],
                    ),
                    const SizedBox(height: 12),
                    _buildCategorySection(
                      context,
                      AppConstants.categoryUtility,
                      commandsByCategory[AppConstants.categoryUtility] ?? [],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  @override
  void dispose() {
    // Restore system UI when leaving the screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Widget _buildUngroupedGrid() {
    final allCommands = ref.watch(commandsProvider);

    return ActionGrid(
      commands: allCommands,
      onCommandPressed: _executeCommand,
      onCommandLongPressed: _isEditMode ? null : _executeLongPressCommand,
      loadingCommandId: _loadingCommandId,
      onReorder: _isEditMode ? (oldIndex, newIndex) {
        // For ungrouped mode, reorder in the main list
        final commands = List<Command>.from(allCommands);
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final command = commands.removeAt(oldIndex);
        commands.insert(newIndex, command);

        // Update state directly
        ref.read(commandsProvider.notifier).state = commands;
      } : null,
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<Command> commands,
  ) {
    if (commands.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.gtaGreen,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gtaGreen.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              category.toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.gtaGreen,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ActionGrid(
          commands: commands,
          onCommandPressed: _executeCommand,
          onCommandLongPressed: _isEditMode ? null : _executeLongPressCommand,
          loadingCommandId: _loadingCommandId,
          onReorder: _isEditMode ? (oldIndex, newIndex) {
            ref.read(commandsProvider.notifier).reorderCommands(
              category,
              oldIndex,
              newIndex,
            );
          } : null,
        ),
      ],
    );
  }

  Future<void> _executeCommand(Command command) async {
    if (_loadingCommandId != null) return;

    setState(() => _loadingCommandId = command.id);

    try {
      final executor = ref.read(commandExecutorProvider);
      await executor.execute(command);

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to execute ${command.label}'),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingCommandId = null);
      }
    }
  }

  Future<void> _executeLongPressCommand(Command command) async {
    // If command has a long-press action, execute it
    if (command.longPressType != null && command.longPressPayload != null) {
      if (_loadingCommandId != null) return;

      setState(() => _loadingCommandId = command.id);

      try {
        final executor = ref.read(commandExecutorProvider);
        final longPressCommand = Command(
          id: command.id,
          label: command.label,
          icon: command.icon,
          type: command.longPressType!,
          payload: command.longPressPayload!,
          category: command.category,
        );
        await executor.execute(longPressCommand);

        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to execute ${command.label} (hold)'),
              backgroundColor: AppColors.dangerRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _loadingCommandId = null);
        }
      }
    }
    // If no long-press action, do nothing (long-press is only for drag in edit mode)
  }

  void _disconnect() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Disconnect',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.gtaGreen,
              ),
        ),
        content: Text(
          'Are you sure you want to disconnect from the PC?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(connectionStateProvider.notifier).disconnect();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('DISCONNECT'),
          ),
        ],
      ),
    );
  }

  void _openEditor() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CommandEditorScreen(),
      ),
    );
  }

  void _openEditorForCommand(Command command) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommandEditorScreen(commandId: command.id),
      ),
    );
  }

  void _showEditShortcutDialog() {
    final allCommands = ref.read(commandsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Select Shortcut to Edit',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.gtaGreen,
              ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allCommands.length,
            itemBuilder: (context, index) {
              final command = allCommands[index];
              return ListTile(
                leading: Text(
                  command.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  command.label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  command.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _openEditorForCommand(command);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Reset to Defaults',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.warningYellow,
              ),
        ),
        content: Text(
          'This will restore all default commands and delete your customizations. This cannot be undone.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(commandsProvider.notifier).resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Commands reset to defaults'),
                  backgroundColor: AppColors.healthGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningYellow,
              foregroundColor: AppColors.darkBackground,
            ),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}
