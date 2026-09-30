import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/providers/cart_provider.dart';
import 'package:pizzeria/presentation/screens/buyer_orders_screen.dart';
import 'package:pizzeria/presentation/screens/buyer_profile_screen.dart';
import 'package:pizzeria/presentation/screens/cart_screen.dart';
import 'package:pizzeria/presentation/screens/home_screen.dart';
import 'package:pizzeria/presentation/screens/map_screen.dart';
import 'package:pizzeria/presentation/screens/menu_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
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
    final cartItems = ref.watch(cartProvider);
    final totalCartCount = cartItems.fold(0, (sum, i) => sum + i.quantity);

    final List<Widget> screens = [
      HomeScreen(
        onNavigateToMenu: () => _currentIndexNotifier.value = 1,
      ),
      const MenuScreen(),
      const BuyerOrdersScreen(),
      const MapScreen(),
      const BuyerProfileScreen(),
    ];

    return ValueListenableBuilder<int>(
      valueListenable: _currentIndexNotifier,
      builder: (context, currentIndex, _) {
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          floatingActionButton: totalCartCount > 0
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(
                    'Carrito ($totalCartCount)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    CustomNavigator.pushFade(
                      context,
                      CartScreen(onAddMoreProducts: () => _currentIndexNotifier.value = 1),
                    );
                  },
                )
              : null,
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) => _currentIndexNotifier.value = index,
          ),
        );
      },
    );
  }
}
