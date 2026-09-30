import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/mappers/pizza_mapper.dart';
import 'package:pizzeria/models/pizza_model.dart';

abstract class PizzaDatasource {
  Future<List<PizzaModel>> getPizzas();
  Future<List<PizzaModel>> getPizzasByRestaurant(String restaurantId);
  Future<PizzaModel> createPizza(PizzaModel pizza);
  Future<PizzaModel> updatePizza(PizzaModel pizza);
  Future<void> deletePizza(String pizzaId);
}

class SupabasePizzaDatasource implements PizzaDatasource {
  final SupabaseClient _client;

  SupabasePizzaDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<PizzaModel>> getPizzas() async {
    final data = await _client
        .from('pizzas')
        .select('*, restaurants(name, address, latitude, longitude)')
        .order('created_at', ascending: false);

    return (data as List).map((p) => PizzaMapper.fromMap(p)).toList();
  }

  @override
  Future<List<PizzaModel>> getPizzasByRestaurant(String restaurantId) async {
    try {
      final data = await _client
          .from('pizzas')
          .select('*, restaurants(name, address, latitude, longitude)')
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);

      return (data as List).map((p) => PizzaMapper.fromMap(p)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<PizzaModel> createPizza(PizzaModel pizza) async {
    final payload = PizzaMapper.toMap(pizza);
    final data = await _client
        .from('pizzas')
        .insert(payload)
        .select('*, restaurants(name, address, latitude, longitude)')
        .single();

    return PizzaMapper.fromMap(data);
  }

  @override
  Future<PizzaModel> updatePizza(PizzaModel pizza) async {
    final payload = PizzaMapper.toMap(pizza);
    final data = await _client
        .from('pizzas')
        .update(payload)
        .eq('id', pizza.id)
        .select('*, restaurants(name, address, latitude, longitude)')
        .single();

    return PizzaMapper.fromMap(data);
  }

  @override
  Future<void> deletePizza(String pizzaId) async {
    await _client.from('pizzas').delete().eq('id', pizzaId);
  }
}
