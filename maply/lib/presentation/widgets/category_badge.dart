import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryBadge({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'comida':
        return Icons.restaurant_rounded;
      case 'estudio':
        return Icons.school_rounded;
      case 'diversión':
      case 'diversion':
        return Icons.celebration_rounded;
      case 'hogar':
      case 'casa':
        return Icons.home_rounded;
      case 'deporte':
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'café':
      case 'cafe':
        return Icons.local_cafe_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'comida':
        return const Color(0xFFF97316);
      case 'estudio':
        return const Color(0xFF6366F1);
      case 'diversión':
      case 'diversion':
        return const Color(0xFFEC4899);
      case 'hogar':
      case 'casa':
        return const Color(0xFF10B981);
      case 'deporte':
      case 'gym':
        return const Color(0xFFF59E0B);
      case 'café':
      case 'cafe':
        return const Color(0xFF8D6E63);
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getCategoryColor(category);
    final icon = getCategoryIcon(category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              category,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
