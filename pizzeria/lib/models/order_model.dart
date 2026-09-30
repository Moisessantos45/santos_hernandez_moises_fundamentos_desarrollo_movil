class OrderItemModel {
  final String? id;
  final String? orderId;
  final String? pizzaId;
  final String pizzaName;
  final int quantity;
  final double unitPrice;
  final String size;

  const OrderItemModel({
    this.id,
    this.orderId,
    this.pizzaId,
    required this.pizzaName,
    required this.quantity,
    required this.unitPrice,
    this.size = 'Mediana',
  });

  double get totalPrice => unitPrice * quantity;
}

class OrderModel {
  final String id;
  final String buyerId;
  final String restaurantId;
  final String? restaurantName;
  final String? buyerName;
  final String? buyerEmail;
  final String status; // 'pendiente', 'en_preparacion', 'en_camino', 'entregado', 'cancelado'
  final double totalAmount;
  final String deliveryAddress;
  final String paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.buyerId,
    required this.restaurantId,
    this.restaurantName,
    this.buyerName,
    this.buyerEmail,
    this.status = 'pendiente',
    required this.totalAmount,
    required this.deliveryAddress,
    this.paymentMethod = 'Efectivo',
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  String get statusDisplay {
    switch (status) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_preparacion':
        return 'En Preparación';
      case 'en_camino':
        return 'En Camino';
      case 'entregado':
        return 'Entregado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  OrderModel copyWith({
    String? id,
    String? buyerId,
    String? restaurantId,
    String? restaurantName,
    String? buyerName,
    String? buyerEmail,
    String? status,
    double? totalAmount,
    String? deliveryAddress,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      buyerName: buyerName ?? this.buyerName,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
