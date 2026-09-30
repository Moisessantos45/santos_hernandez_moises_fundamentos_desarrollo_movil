import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/models/pizza_model.dart';
import 'package:pizzeria/presentation/providers/cart_provider.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class PizzaDetailScreen extends ConsumerStatefulWidget {
  final PizzaModel pizza;

  const PizzaDetailScreen({
    super.key,
    required this.pizza,
  });

  @override
  ConsumerState<PizzaDetailScreen> createState() => _PizzaDetailScreenState();
}

class _PizzaDetailScreenState extends ConsumerState<PizzaDetailScreen> {
  late final ValueNotifier<String> _sizeNotifier;
  final ValueNotifier<int> _quantityNotifier = ValueNotifier<int>(1);
  final ValueNotifier<bool> _isFavoriteNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _sizeNotifier = ValueNotifier<String>(
      widget.pizza.sizes.isNotEmpty ? widget.pizza.sizes.first : 'Mediana',
    );
  }

  @override
  void dispose() {
    _sizeNotifier.dispose();
    _quantityNotifier.dispose();
    _isFavoriteNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = widget.pizza.sizes.isNotEmpty
        ? widget.pizza.sizes
        : ['Personal', 'Mediana', 'Familiar'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: '',
        showBackButton: true,
        trailing: ValueListenableBuilder<bool>(
          valueListenable: _isFavoriteNotifier,
          builder: (context, isFavorite, _) {
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppColors.primary : AppColors.textPrimary,
                size: 24,
              ),
              onPressed: () {
                _isFavoriteNotifier.value = !isFavorite;
              },
            );
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final isTablet =
              constraints.maxWidth >= 600 &&
              constraints.maxHeight >= 600 &&
              constraints.maxWidth < 1024;

          final horizontalPadding = isTablet || isLandscape ? 80.0 : 20.0;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: 260,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.network(
                              widget.pizza.imageUrl,
                              fit: BoxFit.cover,
                              cacheWidth: 800,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: AppColors.inputBackground,
                                child: const Icon(
                                  Icons.local_pizza,
                                  size: 100,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.pizza.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '\$${widget.pizza.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rate_rounded,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.pizza.rating} (${widget.pizza.reviewsCount} reseñas)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.pizza.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.storefront,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.pizza.restaurantName ?? 'Pizzería Bella Napoli',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.pizza.restaurantAddress ?? 'Av. Juárez 45, Centro Histórico',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Selecciona el Tamaño',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ValueListenableBuilder<String>(
                        valueListenable: _sizeNotifier,
                        builder: (context, selectedSize, _) {
                          return Row(
                            children: sizes.map((size) {
                              final isSelected = size == selectedSize;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    _sizeNotifier.value = size;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryLight
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: _quantityNotifier,
                        builder: (context, quantity, _) {
                          return QuantitySelector(
                            quantity: quantity,
                            isLarge: true,
                            onChanged: (newQty) {
                              _quantityNotifier.value = newQty;
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomButton(
                          text: 'Agregar al Carrito',
                          onPressed: () {
                            ref.read(cartProvider.notifier).addItem(
                                  widget.pizza,
                                  quantity: _quantityNotifier.value,
                                  size: _sizeNotifier.value,
                                );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.pizza.name} (${_sizeNotifier.value}) agregada al carrito',
                                ),
                                backgroundColor: AppColors.primary,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
