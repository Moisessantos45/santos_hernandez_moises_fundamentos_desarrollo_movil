import 'package:flutter/material.dart';
import 'package:pizzeria/presentation/screens/seller/seller_location_screen.dart';
import 'package:pizzeria/presentation/screens/seller/seller_orders_screen.dart';
import 'package:pizzeria/presentation/screens/seller/seller_pizzas_screen.dart';
import 'package:pizzeria/presentation/screens/seller/seller_profile_screen.dart';
import 'package:pizzeria/theme/app_colors.dart';

class SellerDashboardScreen extends StatefulWidget {
  final int initialIndex;

  const SellerDashboardScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  late final ValueNotifier<int> _currentIndexNotifier;

  @override
  void initState() {
    super.initState();
    _currentIndexNotifier = ValueNotifier<int>(widget.initialIndex);
  }

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = const [
      SellerOrdersScreen(),
      SellerPizzasScreen(),
      SellerLocationScreen(),
      SellerProfileScreen(),
    ];

    return ValueListenableBuilder<int>(
      valueListenable: _currentIndexNotifier,
      builder: (context, currentIndex, _) {
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(0, currentIndex, Icons.receipt_long_outlined, Icons.receipt_long, 'Pedidos'),
                    _navItem(1, currentIndex, Icons.local_pizza_outlined, Icons.local_pizza, 'Pizzas'),
                    _navItem(2, currentIndex, Icons.storefront_outlined, Icons.storefront, 'Mi Local'),
                    _navItem(3, currentIndex, Icons.person_outline, Icons.person, 'Perfil'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navItem(int index, int currentIndex, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => _currentIndexNotifier.value = index,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
