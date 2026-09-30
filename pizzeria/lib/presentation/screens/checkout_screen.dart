import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/core/navigation/custom_navigator.dart';
import 'package:pizzeria/core/validators/form_validators.dart';
import 'package:pizzeria/models/order_model.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/providers/cart_provider.dart';
import 'package:pizzeria/presentation/providers/location_provider.dart';
import 'package:pizzeria/presentation/providers/order_provider.dart';
import 'package:pizzeria/presentation/providers/restaurant_provider.dart';
import 'package:pizzeria/presentation/screens/buyer_orders_screen.dart';
import 'package:pizzeria/presentation/screens/login_screen.dart';
import 'package:pizzeria/presentation/screens/map_location_picker_screen.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final ValueNotifier<String?> _addressErrorNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String> _paymentMethodNotifier = ValueNotifier<String>('Efectivo');
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);

  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'id': 'Efectivo',
      'title': 'Efectivo contra entrega',
      'subtitle': 'Pagas al recibir tu pedido en puerta',
      'icon': Icons.payments_outlined,
    },
    {
      'id': 'Tarjeta',
      'title': 'Tarjeta de Crédito / Débito',
      'subtitle': 'Visa, Mastercard, AMEX',
      'icon': Icons.credit_card_outlined,
    },
    {
      'id': 'Transferencia',
      'title': 'Transferencia SPEI',
      'subtitle': 'Envía comprobante al repartidor',
      'icon': Icons.account_balance_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userLocationProvider.future).then((loc) {
        if (mounted && _addressController.text.isEmpty) {
          _addressController.text =
              'GPS (${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)})';
        }
      }).catchError((_) {});
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    _addressErrorNotifier.dispose();
    _paymentMethodNotifier.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickDeliveryLocationFromMap() async {
    LatLng initialPos = const LatLng(19.432608, -99.133209);
    try {
      final userLoc = await ref.read(userLocationProvider.future);
      initialPos = userLoc;
    } catch (_) {}

    if (!mounted) return;
    final result = await CustomNavigator.pushFade<MapLocationResult>(
      context,
      MapLocationPickerScreen(
        initialPosition: initialPos,
        title: 'Dirección de Entrega',
      ),
    );

    if (result != null) {
      _addressController.text =
          'Ubicación seleccionada (${result.position.latitude.toStringAsFixed(4)}, ${result.position.longitude.toStringAsFixed(4)})';
      _addressErrorNotifier.value = null;
    }
  }

  bool _validate() {
    _addressErrorNotifier.value = FormValidators.requiredField(
      _addressController.text,
      'Ingresa la dirección completa de entrega',
    );
    return _addressErrorNotifier.value == null;
  }

  Future<void> _handlePlaceOrder() async {
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu carrito está vacío')),
      );
      return;
    }

    if (!_validate()) return;

    _isLoadingNotifier.value = true;
    try {
      var authProfile = ref.read(authProvider).value;
      if (authProfile == null) {
        try {
          authProfile = await ref.read(authProvider.future);
        } catch (_) {}
      }

      final authUser = Supabase.instance.client.auth.currentUser;
      final buyerId = authUser?.id ?? authProfile?.id;

      final bool isBuyerUuid = buyerId != null &&
          RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
              .hasMatch(buyerId);

      if (!isBuyerUuid) {
        if (!mounted) return;
        _showLoginRequiredDialog();
        return;
      }

      String? restaurantId = cartItems.first.pizza.restaurantId;
      final bool isFirstRestUuid = restaurantId != null &&
          RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
              .hasMatch(restaurantId);

      if (!isFirstRestUuid) {
        final restaurants = await ref.read(restaurantsProvider.future);
        if (restaurants.isNotEmpty) {
          restaurantId = restaurants.first.id;
        }
      }

      final bool isFinalRestUuid = restaurantId != null &&
          RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
              .hasMatch(restaurantId);

      if (!isFinalRestUuid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay restaurantes registrados activos para despachar este pedido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final cartNotifier = ref.read(cartProvider.notifier);
      final totalAmount = cartNotifier.total;

      final orderItems = cartItems.map((c) {
        return OrderItemModel(
          pizzaId: c.pizza.id,
          pizzaName: c.pizza.name,
          quantity: c.quantity,
          unitPrice: c.pizza.price,
          size: c.size,
        );
      }).toList();

      final newOrder = OrderModel(
        id: '',
        buyerId: buyerId,
        restaurantId: restaurantId,
        buyerName: authProfile?.fullName,
        buyerEmail: authProfile?.email ?? authUser?.email,
        status: 'pendiente',
        totalAmount: totalAmount,
        deliveryAddress: _addressController.text.trim(),
        paymentMethod: _paymentMethodNotifier.value,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        createdAt: DateTime.now(),
        items: orderItems,
      );

      await ref.read(buyerOrdersProvider.notifier).placeOrder(newOrder);
      cartNotifier.clearCart();

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar orden: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Column(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 12),
            Text(
              '¡Pedido Confirmado!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: const Text(
          'Tu pedido fue enviado a la pizzería y ya está siendo procesado.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          CustomButton(
            text: 'Ver Mis Pedidos',
            width: 200,
            onPressed: () {
              Navigator.pop(ctx);
              CustomNavigator.pushReplacementFade(
                context,
                const BuyerOrdersScreen(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Iniciar Sesión',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Para enviar tu pedido a la pizzería y registrarlo en tu historial, necesitas iniciar sesión. Tus pizzas seguirán guardadas en tu carrito.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              CustomNavigator.pushFade(context, const LoginScreen());
            },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.watch(cartProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        title: 'Finalizar Compra y Pago',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dirección de Entrega',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<String?>(
              valueListenable: _addressErrorNotifier,
              builder: (context, err, _) {
                return CustomTextField(
                  controller: _addressController,
                  label: 'Dirección completa',
                  hintText: 'Calle, número exterior/interior, colonia y CP',
                  prefixIcon: Icons.location_on_outlined,
                  errorText: err,
                  maxLines: 2,
                  onChanged: (_) => _addressErrorNotifier.value = null,
                );
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _pickDeliveryLocationFromMap,
                icon: const Icon(Icons.map_outlined, size: 18, color: AppColors.primary),
                label: const Text(
                  'Seleccionar en el mapa',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _notesController,
              label: 'Instrucciones para el repartidor (Opcional)',
              hintText: 'Ej. Timbre 3B o dejar en caseta',
              prefixIcon: Icons.notes_outlined,
            ),
            const SizedBox(height: 24),
            const Text(
              'Método de Pago',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<String>(
              valueListenable: _paymentMethodNotifier,
              builder: (context, selectedMethod, _) {
                return Column(
                  children: _paymentOptions.map((opt) {
                    final isSelected = selectedMethod == opt['id'];
                    return InkWell(
                      onTap: () {
                        _paymentMethodNotifier.value = opt['id'] as String;
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.inputBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(opt['icon'] as IconData, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['title'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    opt['subtitle'] as String,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? AppColors.primary : AppColors.textLight,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del Pedido',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...cartItems.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.quantity}x ${item.pizza.name} (${item.size})',
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            ),
                            Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('\$${cartNotifier.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Envío a domicilio', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('\$${cartNotifier.shippingCost.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total a Pagar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${cartNotifier.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<bool>(
              valueListenable: _isLoadingNotifier,
              builder: (context, isLoading, _) {
                return CustomButton(
                  text: 'Confirmar y Pagar \$${cartNotifier.total.toStringAsFixed(2)}',
                  isLoading: isLoading,
                  onPressed: _handlePlaceOrder,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
