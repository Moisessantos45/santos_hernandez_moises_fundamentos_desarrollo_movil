import 'package:flutter/material.dart';
import "package:tripify/core/theme/app_colors.dart";

class FilterBottomSheet extends StatefulWidget {
  final String selectedCategory;
  final String selectedTransport;
  final String selectedLocation;
  final RangeValues priceRange;
  final Function(
    String category,
    String transport,
    String location,
    RangeValues priceRange,
  )
  onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedCategory,
    required this.selectedTransport,
    required this.selectedLocation,
    required this.priceRange,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _category;
  late String _transport;
  late String _location;
  late RangeValues _priceRange;

  final List<String> _categories = [
    'All',
    'Beach',
    'Hotel',
    'Resort',
    'Mountain',
    'Good Food',
    'Air Balloon',
    'Sea',
  ];

  final List<String> _transports = [
    'All',
    'Bus',
    'Plane',
    'Train',
    'Boat',
    'Motorbike',
    'Bicycle',
    'Canoe',
    'By Foot',
  ];

  final List<String> _locations = [
    'All',
    'Americas',
    'Asia',
    'Australia',
    'South Pole',
    'Africa',
  ];

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _transport = widget.selectedTransport;
    _location = widget.selectedLocation;
    _priceRange = widget.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _category == cat;
                return _FilterChip(
                  label: cat,
                  isSelected: isSelected,
                  onTap: () => setState(() => _category = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            const Text(
              'Transport',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _transports.map((trans) {
                final isSelected = _transport == trans;
                return _FilterChip(
                  label: trans,
                  isSelected: isSelected,
                  onTap: () => setState(() => _transport = trans),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            const Text(
              'Locations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _locations.map((loc) {
                final isSelected = _location == loc;
                return _FilterChip(
                  label: loc,
                  isSelected: isSelected,
                  onTap: () => setState(() => _location = loc),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '\$${_priceRange.start.toInt()}k - \$${_priceRange.end.toInt()}k',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 50,
              max: 1000,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.borderLight,
              onChanged: (values) => setState(() => _priceRange = values),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_category, _transport, _location, _priceRange);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
