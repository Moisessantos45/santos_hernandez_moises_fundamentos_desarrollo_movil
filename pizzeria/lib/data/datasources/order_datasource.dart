import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/mappers/order_mapper.dart';
import 'package:pizzeria/models/order_model.dart';

abstract class OrderDatasource {
  Future<OrderModel> createOrder(OrderModel order);
  Future<List<OrderModel>> getOrdersByBuyer(String buyerId);
  Future<List<OrderModel>> getOrdersByRestaurant(String restaurantId);
  Future<void> updateOrderStatus(String orderId, String newStatus);
}

class SupabaseOrderDatasource implements OrderDatasource {
  final SupabaseClient _client;

  SupabaseOrderDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    final orderPayload = OrderMapper.toMap(order);
    final orderData = await _client
        .from('orders')
        .insert(orderPayload)
        .select()
        .single();

    final createdOrder = OrderMapper.fromMap(orderData);

    if (order.items.isNotEmpty) {
      final itemsPayload = order.items.map((item) {
        return OrderMapper.itemToMap(item, createdOrder.id);
      }).toList();

      await _client.from('order_items').insert(itemsPayload);
    }

    return createdOrder.copyWith(items: order.items);
  }

  @override
  Future<List<OrderModel>> getOrdersByBuyer(String buyerId) async {
    try {
      final data = await _client
          .from('orders')
          .select('*, order_items(*), restaurants(name)')
          .eq('buyer_id', buyerId)
          .order('created_at', ascending: false);

      return (data as List).map((o) => OrderMapper.fromMap(o)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByRestaurant(String restaurantId) async {
    try {
      final data = await _client
          .from('orders')
          .select('*, order_items(*), profiles(full_name, email)')
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);

      return (data as List).map((o) => OrderMapper.fromMap(o)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _client
        .from('orders')
        .update({'status': newStatus})
        .eq('id', orderId);
  }
}
