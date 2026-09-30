import 'package:flutter/material.dart';
import 'package:pizzeria/theme/app_colors.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final bool isLarge;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLarge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (quantity > 1) {
                  onChanged(quantity - 1);
                }
              },
              child: const Icon(
                Icons.remove,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              quantity.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => onChanged(quantity + 1),
              child: const Icon(
                Icons.add,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (quantity > 1) {
                onChanged(quantity - 1);
              }
            },
            child: const Icon(
              Icons.remove,
              size: 14,
              color: AppColors.textPrimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(quantity + 1),
            child: const Icon(
              Icons.add,
              size: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
