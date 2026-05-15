import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../models/command.dart';
import '../screens/settings_screen.dart';
import 'gta_button.dart';

class ActionGrid extends ConsumerWidget {
  final List<Command> commands;
  final Function(Command) onCommandPressed;
  final Function(Command)? onCommandLongPressed;
  final String? loadingCommandId;
  final Function(int, int)? onReorder;

  const ActionGrid({
    super.key,
    required this.commands,
    required this.onCommandPressed,
    this.onCommandLongPressed,
    this.loadingCommandId,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final gridSettings = ref.watch(gridSettingsProvider);

    final columns = isLandscape
        ? gridSettings.landscapeColumns
        : gridSettings.portraitColumns;

    return ReorderableGridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: isLandscape ? 1.0 : 0.80,
      ),
      itemCount: commands.length,
      onReorder: onReorder ?? (oldIndex, newIndex) {},
      dragEnabled: onReorder != null,
      dragStartDelay: const Duration(milliseconds: 200),
      itemBuilder: (context, index) {
        final command = commands[index];
        return GtaButton(
          key: ValueKey(command.id),
          label: command.label,
          icon: command.icon,
          description: command.description,
          isLoading: loadingCommandId == command.id,
          onPressed: () => onCommandPressed(command),
          onLongPress: onCommandLongPressed != null
              ? () => onCommandLongPressed!(command)
              : null,
        );
      },
    );
  }
}

