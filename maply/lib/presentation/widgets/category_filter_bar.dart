import 'package:flutter/material.dart';
import 'package:maply/presentation/widgets/category_badge.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAllSelected = selectedCategory == null;
            return InkWell(
              onTap: () => onCategorySelected(null),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isAllSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Todos',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isAllSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategory == category;

          return CategoryBadge(
            category: category,
            isSelected: isSelected,
            onTap: () {
              if (isSelected) {
                onCategorySelected(null);
              } else {
                onCategorySelected(category);
              }
            },
          );
        },
      ),
    );
  }
}
