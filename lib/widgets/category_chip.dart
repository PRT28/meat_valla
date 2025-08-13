import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'chicken':
        return Icons.egg_outlined;
      case 'mutton':
      case 'goat':
        return Icons.pets_outlined;
      case 'fish':
      case 'seafood':
        return Icons.water_outlined;
      case 'beef':
        return Icons.restaurant_outlined;
      case 'pork':
        return Icons.kitchen_outlined;
      default:
        return Icons.restaurant;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chicken':
        return const Color(0xFFF39C12);
      case 'mutton':
      case 'goat':
        return const Color(0xFF8E44AD);
      case 'fish':
      case 'seafood':
        return const Color(0xFF3498DB);
      case 'beef':
        return const Color(0xFFE74C3C);
      case 'pork':
        return const Color(0xFFE67E22);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(category);
    final categoryIcon = _getCategoryIcon(category);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                categoryIcon,
                color: categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}