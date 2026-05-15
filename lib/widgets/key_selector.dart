import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class KeySelector extends StatelessWidget {
  final String? selectedKey;
  final Function(String) onKeySelected;
  final String? label;

  const KeySelector({
    super.key,
    required this.selectedKey,
    required this.onKeySelected,
    this.label,
  });

  static const List<String> _commonKeys = [
    // Letters (commonly used in GTA V)
    'M', 'E', 'F', 'G', 'H', 'V', 'X', 'Z',

    // Arrows
    'Up', 'Down', 'Left', 'Right',

    // Function keys
    'F1', 'F2', 'F3', 'F4', 'F5', 'F6',
    'F7', 'F8', 'F9', 'F10', 'F11', 'F12',

    // Special keys
    'Enter', 'Space', 'Esc', 'Tab',
    'Shift', 'Ctrl', 'Alt',

    // Numbers
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',

    // Other letters
    'A', 'B', 'C', 'D', 'I', 'J', 'K', 'L',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U',
    'W', 'Y',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.gtaGreen,
                ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.gtaGreen.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedKey,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select a key',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ),
              dropdownColor: AppColors.cardBackground,
              icon: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.gtaGreen,
                ),
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
              items: _commonKeys.map((key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.gtaGreen.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            key,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppColors.gtaGreen,
                                  fontSize: 12,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getKeyDescription(key),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onKeySelected(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getKeyDescription(String key) {
    switch (key) {
      case 'M':
        return 'Map / Interaction Menu';
      case 'E':
        return 'Interact';
      case 'F':
        return 'Enter/Exit Vehicle';
      case 'V':
        return 'Change View';
      case 'Up':
        return 'Phone';
      case 'Down':
        return 'Navigate Down';
      case 'Left':
        return 'Navigate Left';
      case 'Right':
        return 'Navigate Right';
      case 'F5':
        return 'Quick Save';
      case 'F12':
        return 'Screenshot';
      case 'Enter':
        return 'Confirm';
      case 'Esc':
        return 'Back/Cancel';
      case 'Space':
        return 'Jump';
      default:
        return '';
    }
  }
}
