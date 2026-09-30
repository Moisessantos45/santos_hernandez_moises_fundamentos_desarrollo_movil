import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/models/cart_item_model.dart';
import 'package:pizzeria/models/pizza_model.dart';

abstract class CartDatasource {
  Future<List<CartItemModel>> getCartItems(String userId);
  Future<CartItemModel?> addToCart({
    required String userId,
    required PizzaModel pizza,
    required int quantity,
    required String size,
  });
  Future<void> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  });
  Future<void> removeCartItem(String itemId);
  Future<void> clearUserCart(String userId);
}

class SupabaseCartDatasource implements CartDatasource {
  final SupabaseClient _client;

  SupabaseCartDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final data = await _client
          .from('cart_items')
          .select('*, pizzas(*, restaurants(name, address, latitude, longitude))')
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      return (data as List)
          .map((item) => CartItemModel.fromDbMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<CartItemModel?> addToCart({
    required String userId,
    required PizzaModel pizza,
    required int quantity,
    required String size,
  }) async {
    try {
      final response = await _client
          .from('cart_items')
          .upsert(
            {
              'user_id': userId,
              'pizza_id': pizza.id,
              'quantity': quantity,
              'size': size,
            },
            onConflict: 'user_id,pizza_id,size',
          )
          .select('*, pizzas(*, restaurants(name, address, latitude, longitude))')
          .single();

      return CartItemModel.fromDbMap(Map<String, dynamic>.from(response));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        await removeCartItem(itemId);
      } else {
        await _client
            .from('cart_items')
            .update({'quantity': quantity})
            .eq('id', itemId);
      }
    } catch (_) {}
  }

  @override
  Future<void> removeCartItem(String itemId) async {
    try {
      await _client.from('cart_items').delete().eq('id', itemId);
    } catch (_) {}
  }

  @override
  Future<void> clearUserCart(String userId) async {
    try {
      await _client.from('cart_items').delete().eq('user_id', userId);
    } catch (_) {}
  }
}
