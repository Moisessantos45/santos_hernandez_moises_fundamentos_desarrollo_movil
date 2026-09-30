import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/presentation/providers/cart_provider.dart';
import 'package:pizzeria/presentation/providers/pizza_provider.dart';
import 'package:pizzeria/presentation/screens/pizza_detail_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final ValueNotifier<String> _categoryNotifier = ValueNotifier<String>('Todas');
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _categoryNotifier.dispose();
    _searchQueryNotifier.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pizzasAsync = ref.watch(pizzasProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        title: 'PizzApp',
        showBackButton: false,
        trailing: CartButtonBadge(),
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Nuestras Pizzas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Artesanales, frescas y listas para ti',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        _searchQueryNotifier.value = val;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Buscar pizzas...',
                        hintStyle: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: _categoryNotifier,
                    builder: (context, selectedCategory, _) {
                      return CategoryFilterChips(
                        selectedCategory: selectedCategory,
                        onCategorySelected: (category) {
                          _categoryNotifier.value = category;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: pizzasAsync.when(
                      data: (allPizzas) {
                        return ValueListenableBuilder<String>(
                          valueListenable: _categoryNotifier,
                          builder: (context, selectedCategory, _) {
                            return ValueListenableBuilder<String>(
                              valueListenable: _searchQueryNotifier,
                              builder: (context, query, _) {
                                final filteredPizzas = allPizzas.where((pizza) {
                                  final matchesCategory = selectedCategory == 'Todas' ||
                                      pizza.category.toLowerCase() == selectedCategory.toLowerCase();
                                  final matchesSearch = pizza.name
                                      .toLowerCase()
                                      .contains(query.toLowerCase());
                                  return matchesCategory && matchesSearch;
                                }).toList();

                                if (filteredPizzas.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.search_off, size: 60, color: AppColors.textLight),
                                          SizedBox(height: 12),
                                          Text(
                                            'No se encontraron pizzas con ese criterio',
                                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  itemCount: filteredPizzas.length,
                                  separatorBuilder: (ctx, i) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final pizza = filteredPizzas[index];
                                    return PizzaListItem(
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
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: DashedOvenLoader()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                    ),
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
