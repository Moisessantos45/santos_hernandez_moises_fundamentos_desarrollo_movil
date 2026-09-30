import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizzeria/models/order_model.dart';
import 'package:pizzeria/presentation/providers/order_provider.dart';
import 'package:pizzeria/presentation/widgets/widgets.dart';
import 'package:pizzeria/theme/app_colors.dart';

class SellerOrdersScreen extends ConsumerStatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  ConsumerState<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends ConsumerState<SellerOrdersScreen> {
  final ValueNotifier<String> _selectedFilterNotifier = ValueNotifier<String>('todos');

  final List<Map<String, String>> _statusFilters = [
    {'key': 'todos', 'label': 'Todos'},
    {'key': 'pendiente', 'label': 'Pendientes'},
    {'key': 'en_preparacion', 'label': 'En Cocina'},
    {'key': 'en_camino', 'label': 'En Camino'},
    {'key': 'entregado', 'label': 'Entregados'},
    {'key': 'cancelado', 'label': 'Cancelados'},
  ];

  @override
  void dispose() {
    _selectedFilterNotifier.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendiente':
        return Colors.orange;
      case 'en_preparacion':
        return Colors.blue;
      case 'en_camino':
        return Colors.purple;
      case 'entregado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showStatusUpdateDialog(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cambiar Estado del Pedido',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _statusTile(ctx, order, 'pendiente', 'Pendiente', Icons.timer_outlined, Colors.orange),
                _statusTile(ctx, order, 'en_preparacion', 'En Preparación / Horno', Icons.soup_kitchen_outlined, Colors.blue),
                _statusTile(ctx, order, 'en_camino', 'En Camino / Con Repartidor', Icons.delivery_dining_outlined, Colors.purple),
                _statusTile(ctx, order, 'entregado', 'Entregado con Éxito', Icons.check_circle_outline, Colors.green),
                _statusTile(ctx, order, 'cancelado', 'Cancelar Pedido', Icons.cancel_outlined, Colors.red),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusTile(
    BuildContext ctx,
    OrderModel order,
    String statusKey,
    String label,
    IconData icon,
    Color color,
  ) {
    final isCurrent = order.status == statusKey;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
          color: isCurrent ? color : AppColors.textPrimary,
        ),
      ),
      trailing: isCurrent ? Icon(Icons.check, color: color) : null,
      onTap: () async {
        Navigator.pop(ctx);
        if (!isCurrent) {
          await ref.read(sellerOrdersProvider.notifier).updateStatus(order.id, statusKey);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(sellerOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        title: 'Gestión de Pedidos',
        showBackButton: false,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ValueListenableBuilder<String>(
              valueListenable: _selectedFilterNotifier,
              builder: (context, currentFilter, _) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _statusFilters.length,
                  separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _statusFilters[index];
                    final isSelected = currentFilter == filter['key'];
                    return ChoiceChip(
                      label: Text(filter['label']!),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        _selectedFilterNotifier.value = filter['key']!;
                      },
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                return ValueListenableBuilder<String>(
                  valueListenable: _selectedFilterNotifier,
                  builder: (context, filter, _) {
                    final filteredOrders = filter == 'todos'
                        ? orders
                        : orders.where((o) => o.status == filter).toList();

                    if (filteredOrders.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.receipt_long_outlined, size: 70, color: AppColors.textLight),
                              SizedBox(height: 16),
                              Text(
                                'No hay pedidos en esta sección',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(sellerOrdersProvider.notifier).refresh();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final statusColor = _getStatusColor(order.status);

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pedido #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _showStatusUpdateDialog(context, order),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: statusColor, width: 1),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              order.statusDisplay,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(Icons.arrow_drop_down, color: statusColor, size: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                if (order.buyerName != null) ...[
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Cliente: ${order.buyerName}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        order.deliveryAddress,
                                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.payment_outlined, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Pago: ${order.paymentMethod}',
                                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Detalle de Productos:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                ...order.items.map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${item.quantity}x ${item.pizzaName} (${item.size})',
                                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                          ),
                                          Text(
                                            '\$${item.totalPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    )),
                                const Divider(height: 18),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total a cobrar:',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '\$${order.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
    );
  }
}
