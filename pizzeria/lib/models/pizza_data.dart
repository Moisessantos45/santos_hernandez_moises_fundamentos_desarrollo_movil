import 'package:pizzeria/models/pizza_model.dart';

class PizzaData {
  static const List<PizzaModel> popularPizzas = [
    PizzaModel(
      id: '1',
      name: 'Pepperoni',
      description: 'Salsa de tomate San marzano,mozarella fior di latter,extra...',
      price: 18.99,
      imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=600&auto=format&fit=crop&q=80',
      rating: 4.8,
      reviewsCount: 124,
      category: 'Clasicas',
    ),
    PizzaModel(
      id: '2',
      name: 'Margarita Especial',
      description: 'Salsa de tomate fresco, mozzarella di bufala y albahaca fresca.',
      price: 16.50,
      imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=600&auto=format&fit=crop&q=80',
      rating: 4.9,
      reviewsCount: 98,
      category: 'Clasicas',
    ),
  ];

  static const List<PizzaModel> menuPizzas = [
    PizzaModel(
      id: '1',
      name: 'Pepperoni',
      description: 'Salsa de tomate, mozzarella, doble pepperoni picante.',
      price: 12.00,
      imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400&auto=format&fit=crop&q=80',
      rating: 4.8,
      reviewsCount: 124,
      category: 'Clasicas',
    ),
    PizzaModel(
      id: '3',
      name: 'Margarita',
      description: 'Salsa de tomate, mozzarella, doble pepperoni picante.',
      price: 12.00,
      imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&auto=format&fit=crop&q=80',
      rating: 4.7,
      reviewsCount: 86,
      category: 'Clasicas',
    ),
    PizzaModel(
      id: '4',
      name: 'Cuatro Quesos',
      description: 'Salsa de tomate, mozzarella, queso gorgonzola, parmesano y ricotta.',
      price: 14.00,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&auto=format&fit=crop&q=80',
      rating: 4.9,
      reviewsCount: 110,
      category: 'Especiales',
    ),
    PizzaModel(
      id: '5',
      name: 'Vegana Huerto',
      description: 'Salsa de tomate, queso vegano, champiñones, pimientos y aceitunas.',
      price: 13.50,
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&auto=format&fit=crop&q=80',
      rating: 4.6,
      reviewsCount: 64,
      category: 'Veganas',
    ),
  ];
}
