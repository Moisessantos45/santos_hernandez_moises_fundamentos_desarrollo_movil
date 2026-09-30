import 'dart:convert';
import 'package:pizzeria/models/pizza_model.dart';

class PizzaMapper {
  static PizzaModel fromMap(Map<String, dynamic> map) {
    List<String> parsedSizes = ['Personal', 'Mediana', 'Familiar'];
    if (map['sizes'] != null) {
      if (map['sizes'] is List) {
        parsedSizes = (map['sizes'] as List).map((e) => e.toString()).toList();
      } else if (map['sizes'] is String) {
        try {
          final decoded = jsonDecode(map['sizes']);
          if (decoded is List) {
            parsedSizes = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
    }

    String? restName;
    String? restAddress;
    double? restLat;
    double? restLng;

    if (map['restaurants'] != null && map['restaurants'] is Map) {
      final r = map['restaurants'] as Map<String, dynamic>;
      restName = r['name']?.toString();
      restAddress = r['address']?.toString();
      restLat = double.tryParse(r['latitude']?.toString() ?? '');
      restLng = double.tryParse(r['longitude']?.toString() ?? '');
    }

    return PizzaModel(
      id: map['id']?.toString() ?? '',
      restaurantId: map['restaurant_id']?.toString(),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: map['image_url']?.toString() ?? '',
      sizes: parsedSizes.isEmpty ? ['Personal', 'Mediana', 'Familiar'] : parsedSizes,
      rating: double.tryParse(map['rating']?.toString() ?? '4.8') ?? 4.8,
      reviewsCount: int.tryParse(map['reviews_count']?.toString() ?? '0') ?? 0,
      category: map['category']?.toString() ?? 'Clasicas',
      isAvailable: map['is_available'] == true || map['is_available'] == null,
      restaurantName: restName ?? map['restaurant_name']?.toString(),
      restaurantAddress: restAddress ?? map['restaurant_address']?.toString(),
      restaurantLatitude: restLat ?? double.tryParse(map['restaurant_latitude']?.toString() ?? ''),
      restaurantLongitude: restLng ?? double.tryParse(map['restaurant_longitude']?.toString() ?? ''),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static Map<String, dynamic> toMap(PizzaModel pizza) {
    return {
      if (pizza.id.isNotEmpty) 'id': pizza.id,
      if (pizza.restaurantId != null) 'restaurant_id': pizza.restaurantId,
      'name': pizza.name,
      'description': pizza.description,
      'price': pizza.price,
      'image_url': pizza.imageUrl,
      'sizes': pizza.sizes,
      'rating': pizza.rating,
      'reviews_count': pizza.reviewsCount,
      'category': pizza.category,
      'is_available': pizza.isAvailable,
    };
  }
}
