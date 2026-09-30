import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/datasources/order_datasource.dart';
import 'package:pizzeria/models/order_model.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';
import 'package:pizzeria/presentation/providers/restaurant_provider.dart';

final orderDatasourceProvider = Provider<OrderDatasource>((ref) {
  return SupabaseOrderDatasource();
});

class BuyerOrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  OrderDatasource get _datasource => ref.read(orderDatasourceProvider);

  @override
  Future<List<OrderModel>> build() async {
    final authState = ref.watch(authProvider).value;
    if (authState == null) return [];

    final channel = Supabase.instance.client
        .channel('public:orders:buyer:${authState.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'buyer_id',
            value: authState.id,
          ),
          callback: (_) => refresh(),
        )
        .subscribe();

    ref.onDispose(() {
      channel.unsubscribe();
    });

    return await _datasource.getOrdersByBuyer(authState.id);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authProvider).value;
      if (authState == null) return [];
      return await _datasource.getOrdersByBuyer(authState.id);
    });
  }

  Future<OrderModel> placeOrder(OrderModel order) async {
    final created = await _datasource.createOrder(order);
    await refresh();
    return created;
  }
}

final buyerOrdersProvider =
    AsyncNotifierProvider<BuyerOrdersNotifier, List<OrderModel>>(
  BuyerOrdersNotifier.new,
);

class SellerOrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  OrderDatasource get _datasource => ref.read(orderDatasourceProvider);

  @override
  Future<List<OrderModel>> build() async {
    final sellerRestaurant = await ref.watch(sellerRestaurantProvider.future);
    if (sellerRestaurant == null || sellerRestaurant.id.isEmpty) {
      return [];
    }

    final channel = Supabase.instance.client
        .channel('public:orders:restaurant:${sellerRestaurant.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'restaurant_id',
            value: sellerRestaurant.id,
          ),
          callback: (_) => refresh(),
        )
        .subscribe();

    ref.onDispose(() {
      channel.unsubscribe();
    });

    return await _datasource.getOrdersByRestaurant(sellerRestaurant.id);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final sellerRestaurant = await ref.read(sellerRestaurantProvider.future);
      if (sellerRestaurant == null || sellerRestaurant.id.isEmpty) return [];
      return await _datasource.getOrdersByRestaurant(sellerRestaurant.id);
    });
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    await _datasource.updateOrderStatus(orderId, newStatus);
    await refresh();
  }
}

final sellerOrdersProvider =
    AsyncNotifierProvider<SellerOrdersNotifier, List<OrderModel>>(
  SellerOrdersNotifier.new,
);

