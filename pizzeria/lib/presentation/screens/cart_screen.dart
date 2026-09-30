import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/providers/cart_provider.dart';
import 'package:pizzeria/presentation/screens/checkout_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class CartScreen extends ConsumerWidget {
  final VoidCallback? onAddMoreProducts;

  const CartScreen({
    super.key,
    this.onAddMoreProducts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.watch(cartProvider.notifier);
    final totalItemCount = cartNotifier.totalItemCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        title: 'PizzApp',
        showBackButton: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final isTablet =
              constraints.maxWidth >= 600 &&
              constraints.maxHeight >= 600 &&
              constraints.maxWidth < 1024;

          final horizontalPadding = isTablet || isLandscape ? 80.0 : 20.0;

          if (cartItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.remove_shopping_cart_outlined,
                      size: 80,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tu carrito está vacío',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Agrega deliciosas pizzas del menú para comenzar tu pedido.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (onAddMoreProducts != null)
                      CustomButton(
                        text: 'Explorar Menú',
                        width: 200,
                        onPressed: onAddMoreProducts,
                      ),
                  ],
                ),
              ),
            );
          }

          return SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Carrito',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$totalItemCount items',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...cartItems.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CartItemCard(
                          item: item,
                          onQuantityChanged: (newQty) {
                            cartNotifier.updateQuantity(index, newQty);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  if (onAddMoreProducts != null)
                    GestureDetector(
                      onTap: onAddMoreProducts,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                            style: BorderStyle.solid,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_circle_outline,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Agregar más productos',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  OrderSummaryCard(
                    subtotal: cartNotifier.subtotal,
                    deliveryFee: cartNotifier.shippingCost,
                    onCheckout: () {
                      CustomNavigator.pushFade(
                        context,
                        const CheckoutScreen(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
