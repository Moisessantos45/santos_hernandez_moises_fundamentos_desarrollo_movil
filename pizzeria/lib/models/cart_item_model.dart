import 'package:pizzeria/data/mappers/pizza_mapper.dart';
import 'package:pizzeria/models/pizza_model.dart';

class CartItemModel {
  final String? id;
  final PizzaModel pizza;
  int quantity;
  final String size;

  CartItemModel({
    this.id,
    required this.pizza,
    this.quantity = 1,
    this.size = 'Personal',
  });

  double get totalPrice => pizza.price * quantity;

  CartItemModel copyWith({
    String? id,
    PizzaModel? pizza,
    int? quantity,
    String? size,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      pizza: pizza ?? this.pizza,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'pizza': PizzaMapper.toMap(pizza),
      'quantity': quantity,
      'size': size,
    };
  }

  factory CartItemModel.fromDbMap(Map<String, dynamic> map) {
    PizzaModel parsedPizza;
    if (map['pizzas'] != null && map['pizzas'] is Map) {
      parsedPizza = PizzaMapper.fromMap(
        Map<String, dynamic>.from(map['pizzas'] as Map),
      );
    } else {
      parsedPizza = PizzaModel(
        id: map['pizza_id']?.toString() ?? '',
        name: 'Pizza seleccionada',
        description: '',
        price: 0,
        imageUrl: '',
      );
    }

    return CartItemModel(
      id: map['id']?.toString(),
      pizza: parsedPizza,
      quantity: int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
      size: map['size']?.toString() ?? 'Mediana',
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id']?.toString(),
      pizza: PizzaMapper.fromMap(
        map['pizza'] != null ? Map<String, dynamic>.from(map['pizza'] as Map) : {},
      ),
      quantity: int.tryParse(map['quantity']?.toString() ?? '1') ?? 1,
      size: map['size']?.toString() ?? 'Mediana',
    );
  }
}
