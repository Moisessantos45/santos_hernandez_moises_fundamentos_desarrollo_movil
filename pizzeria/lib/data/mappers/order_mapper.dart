import 'package:pizzeria/models/order_model.dart';

class OrderMapper {
  static bool _isValidUuid(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }

  static OrderItemModel itemFromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id']?.toString(),
      orderId: map['order_id']?.toString(),
      pizzaId: map['pizza_id']?.toString(),
      pizzaName: map['pizza_name']?.toString() ?? '',
      quantity: int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
      unitPrice: double.tryParse(map['unit_price']?.toString() ?? '0') ?? 0.0,
      size: map['size']?.toString() ?? 'Mediana',
    );
  }

  static Map<String, dynamic> itemToMap(OrderItemModel item, String orderId) {
    final validPizzaId = _isValidUuid(item.pizzaId) ? item.pizzaId : null;
    final validItemId = _isValidUuid(item.id) ? item.id : null;

    final map = <String, dynamic>{
      'order_id': orderId,
      'pizza_name': item.pizzaName,
      'quantity': item.quantity,
      'unit_price': item.unitPrice,
      'size': item.size,
    };
    if (validItemId != null) map['id'] = validItemId;
    if (validPizzaId != null) map['pizza_id'] = validPizzaId;
    return map;
  }

  static OrderModel fromMap(Map<String, dynamic> map) {
    List<OrderItemModel> items = [];
    if (map['order_items'] != null && map['order_items'] is List) {
      items = (map['order_items'] as List)
          .map((i) => itemFromMap(i as Map<String, dynamic>))
          .toList();
    }

    String? restName;
    if (map['restaurants'] != null && map['restaurants'] is Map) {
      restName = (map['restaurants'] as Map<String, dynamic>)['name']?.toString();
    }

    String? buyerName;
    String? buyerEmail;
    if (map['profiles'] != null && map['profiles'] is Map) {
      buyerName = (map['profiles'] as Map<String, dynamic>)['full_name']?.toString();
      buyerEmail = (map['profiles'] as Map<String, dynamic>)['email']?.toString();
    }

    return OrderModel(
      id: map['id']?.toString() ?? '',
      buyerId: map['buyer_id']?.toString() ?? '',
      restaurantId: map['restaurant_id']?.toString() ?? '',
      restaurantName: restName ?? map['restaurant_name']?.toString(),
      buyerName: buyerName ?? map['buyer_name']?.toString(),
      buyerEmail: buyerEmail ?? map['buyer_email']?.toString(),
      status: map['status']?.toString() ?? 'pendiente',
      totalAmount: double.tryParse(map['total_amount']?.toString() ?? '0') ?? 0.0,
      deliveryAddress: map['delivery_address']?.toString() ?? '',
      paymentMethod: map['payment_method']?.toString() ?? 'Efectivo',
      notes: map['notes']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      items: items,
    );
  }

  static Map<String, dynamic> toMap(OrderModel order) {
    final validOrderId = _isValidUuid(order.id) ? order.id : null;

    final map = <String, dynamic>{
      'buyer_id': order.buyerId,
      'restaurant_id': order.restaurantId,
      'status': order.status,
      'total_amount': order.totalAmount,
      'delivery_address': order.deliveryAddress,
      'payment_method': order.paymentMethod,
    };
    if (validOrderId != null) map['id'] = validOrderId;
    if (order.notes != null) map['notes'] = order.notes;
    return map;
  }
}
