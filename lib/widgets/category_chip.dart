import 'package:flutter/material.dart';
import 'package:moroccan_recipies_app/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final Function(String) onSelected;
  final bool isSelected;
  final IconData? icon;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.onSelected,
    required this.isSelected,
    this.icon,
  }) : super(key: key);

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      case 'dessert':
        return Icons.cake;
      case 'all':
        return Icons.restaurant_menu;
      default:
        return Icons.restaurant;
    }
  }

  Color _getCategoryColor(String category) {
    return AppColors.categoryColors[category] ?? AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final IconData chipIcon = icon ?? _getCategoryIcon(label);
    final Color categoryColor = _getCategoryColor(label);
    
    return InkWell(
      onTap: () => onSelected(label),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? categoryColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? categoryColor : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              chipIcon,
              color: isSelected ? Colors.white : categoryColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}