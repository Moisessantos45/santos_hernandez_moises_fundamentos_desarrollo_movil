import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/mappers/restaurant_mapper.dart';
import 'package:pizzeria/models/restaurant_model.dart';

abstract class RestaurantDatasource {
  Future<List<RestaurantModel>> getRestaurants();
  Future<RestaurantModel?> getRestaurantBySellerId(String sellerId);
  Future<RestaurantModel?> getRestaurantById(String id);
  Future<RestaurantModel> upsertRestaurant(RestaurantModel restaurant);
}

class SupabaseRestaurantDatasource implements RestaurantDatasource {
  final SupabaseClient _client;

  SupabaseRestaurantDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<RestaurantModel>> getRestaurants() async {
    final data = await _client
        .from('restaurants')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((r) => RestaurantMapper.fromMap(r)).toList();
  }

  @override
  Future<RestaurantModel?> getRestaurantBySellerId(String sellerId) async {
    try {
      final data = await _client
          .from('restaurants')
          .select()
          .eq('seller_id', sellerId)
          .maybeSingle();

      if (data != null) {
        return RestaurantMapper.fromMap(data);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<RestaurantModel?> getRestaurantById(String id) async {
    try {
      final data = await _client
          .from('restaurants')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data != null) {
        return RestaurantMapper.fromMap(data);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<RestaurantModel> upsertRestaurant(RestaurantModel restaurant) async {
    final user = _client.auth.currentUser;
    if (user != null) {
      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'email': user.email ?? '',
          'full_name': user.userMetadata?['full_name'] ?? 'Vendedor',
          'role': 'vendedor',
        });
      } catch (_) {}
    }

    final payload = RestaurantMapper.toMap(restaurant);
    final response = await _client
        .from('restaurants')
        .upsert(payload)
        .select()
        .single();

    return RestaurantMapper.fromMap(response);
  }
}
