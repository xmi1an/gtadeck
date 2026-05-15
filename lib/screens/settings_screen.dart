import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';

final gridSettingsProvider = StateNotifierProvider<GridSettingsNotifier, GridSettings>((ref) {
  return GridSettingsNotifier();
});

class GridSettings {
  final int portraitColumns;
  final int landscapeColumns;

  GridSettings({
    this.portraitColumns = 3,
    this.landscapeColumns = 6,
  });

  GridSettings copyWith({
    int? portraitColumns,
    int? landscapeColumns,
  }) {
    return GridSettings(
      portraitColumns: portraitColumns ?? this.portraitColumns,
      landscapeColumns: landscapeColumns ?? this.landscapeColumns,
    );
  }
}

class GridSettingsNotifier extends StateNotifier<GridSettings> {
  GridSettingsNotifier() : super(GridSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final portraitColumns = prefs.getInt('portrait_columns') ?? 3;
      final landscapeColumns = prefs.getInt('landscape_columns') ?? 6;
      state = GridSettings(
        portraitColumns: portraitColumns,
        landscapeColumns: landscapeColumns,
      );
    } catch (e) {
      // Use defaults
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('portrait_columns', state.portraitColumns);
      await prefs.setInt('landscape_columns', state.landscapeColumns);
    } catch (e) {
      // Handle error silently
    }
  }

  void setPortraitColumns(int columns) {
    state = state.copyWith(portraitColumns: columns);
    _saveSettings();
  }

  void setLandscapeColumns(int columns) {
    state = state.copyWith(landscapeColumns: columns);
    _saveSettings();
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridSettings = ref.watch(gridSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Portrait Mode',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.gtaGreen,
                ),
          ),
          const SizedBox(height: 16),
          _buildColumnSelector(
            context,
            'Columns',
            gridSettings.portraitColumns,
            (value) => ref.read(gridSettingsProvider.notifier).setPortraitColumns(value),
            minColumns: 2,
            maxColumns: 5,
          ),
          const SizedBox(height: 32),
          Text(
            'Landscape Mode',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.gtaGreen,
                ),
          ),
          const SizedBox(height: 16),
          _buildColumnSelector(
            context,
            'Columns',
            gridSettings.landscapeColumns,
            (value) => ref.read(gridSettingsProvider.notifier).setLandscapeColumns(value),
            minColumns: 4,
            maxColumns: 8,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.gtaGreen.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.gtaGreen, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tips',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.gtaGreen,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Portrait: 2-5 columns recommended\n'
                  '• Landscape: 4-8 columns recommended\n'
                  '• More columns = smaller buttons\n'
                  '• Changes apply immediately',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnSelector(
    BuildContext context,
    String label,
    int currentValue,
    Function(int) onChanged, {
    required int minColumns,
    required int maxColumns,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gtaGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.gtaGreen,
                  width: 2,
                ),
              ),
              child: Text(
                '$currentValue',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.gtaGreen,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            maxColumns - minColumns + 1,
            (index) {
              final value = minColumns + index;
              final isSelected = value == currentValue;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < maxColumns - minColumns ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => onChanged(value),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gtaGreen
                            : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gtaGreen
                              : AppColors.gtaGreen.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$value',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isSelected
                                    ? AppColors.darkBackground
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
