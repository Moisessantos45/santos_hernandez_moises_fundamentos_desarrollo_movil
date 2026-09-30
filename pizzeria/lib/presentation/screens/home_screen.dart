import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/providers/cart_provider.dart';
import 'package:pizzeria/presentation/providers/location_provider.dart';
import 'package:pizzeria/presentation/providers/pizza_provider.dart';
import 'package:pizzeria/presentation/screens/pizza_detail_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback? onNavigateToMenu;

  const HomeScreen({
    super.key,
    this.onNavigateToMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pizzasAsync = ref.watch(pizzasProvider);
    final locationAsync = ref.watch(userLocationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: 'PizzApp',
        showBackButton: false,
        trailing: CartButtonBadge(onAddMoreProducts: onNavigateToMenu),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final isTablet =
              constraints.maxWidth >= 600 &&
              constraints.maxHeight >= 600 &&
              constraints.maxWidth < 1024;

          final horizontalPadding = isTablet || isLandscape ? 80.0 : 20.0;

          return SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Entregar en',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          locationAsync.when(
                            data: (pos) => Text(
                              'Ubicación actual (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            loading: () => const Text(
                              'Obteniendo ubicación GPS...',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            error: (_, _) => const Text(
                              'Ciudad de México (GPS no disponible)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  PromoBanner(
                    onOrderNow: onNavigateToMenu,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pizzas Populares',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: onNavigateToMenu,
                        child: const Text(
                          'Ver todas',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.bannerRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  pizzasAsync.when(
                    data: (pizzas) {
                      if (pizzas.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.restaurant_menu,
                                  size: 48, color: AppColors.textLight),
                              SizedBox(height: 10),
                              Text(
                                'Aún no hay pizzas disponibles en el catálogo',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Los vendedores agregarán productos pronto.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final popularList = pizzas.take(3).toList();
                      return Column(
                        children: popularList.map(
                          (pizza) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PizzaPopularCard(
                              pizza: pizza,
                              onTap: () {
                                CustomNavigator.pushFade(
                                  context,
                                  PizzaDetailScreen(pizza: pizza),
                                );
                              },
                              onAddToCart: () {
                                ref.read(cartProvider.notifier).addItem(pizza);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${pizza.name} agregada al carrito'),
                                    backgroundColor: AppColors.primary,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ).toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: DashedOvenLoader(),
                      ),
                    ),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
