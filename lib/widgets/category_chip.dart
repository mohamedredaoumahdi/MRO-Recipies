import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final Function(String) onSelected;
  final bool isSelected;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.onSelected,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      showCheckmark: false,
      onSelected: (bool selected) {
        if (selected) {
          onSelected(label);
        }
      },
    );
  }
} 