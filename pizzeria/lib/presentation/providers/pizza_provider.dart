import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/datasources/pizza_datasource.dart';
import 'package:pizzeria/models/pizza_model.dart';
import 'package:pizzeria/presentation/providers/restaurant_provider.dart';

final pizzaDatasourceProvider = Provider<PizzaDatasource>((ref) {
  return SupabasePizzaDatasource();
});

final pizzasProvider = FutureProvider<List<PizzaModel>>((ref) async {
  final datasource = ref.watch(pizzaDatasourceProvider);

  final channel = Supabase.instance.client
      .channel('public:pizzas:all')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'pizzas',
        callback: (_) {
          ref.invalidateSelf();
        },
      )
      .subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
  });

  return await datasource.getPizzas();
});

class SellerPizzasNotifier extends AsyncNotifier<List<PizzaModel>> {
  PizzaDatasource get _datasource => ref.read(pizzaDatasourceProvider);

  @override
  Future<List<PizzaModel>> build() async {
    final sellerRestaurant = await ref.watch(sellerRestaurantProvider.future);
    if (sellerRestaurant == null || sellerRestaurant.id.isEmpty) {
      return [];
    }

    final channel = Supabase.instance.client
        .channel('public:pizzas:seller:${sellerRestaurant.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pizzas',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'restaurant_id',
            value: sellerRestaurant.id,
          ),
          callback: (_) {
            ref.invalidateSelf();
          },
        )
        .subscribe();

    ref.onDispose(() {
      channel.unsubscribe();
    });

    return await _datasource.getPizzasByRestaurant(sellerRestaurant.id);
  }

  Future<void> addPizza(PizzaModel pizza) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _datasource.createPizza(pizza);
      ref.invalidate(pizzasProvider);
      final sellerRestaurant = await ref.read(sellerRestaurantProvider.future);
      if (sellerRestaurant == null) return [];
      return await _datasource.getPizzasByRestaurant(sellerRestaurant.id);
    });
  }

  Future<void> editPizza(PizzaModel pizza) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _datasource.updatePizza(pizza);
      ref.invalidate(pizzasProvider);
      final sellerRestaurant = await ref.read(sellerRestaurantProvider.future);
      if (sellerRestaurant == null) return [];
      return await _datasource.getPizzasByRestaurant(sellerRestaurant.id);
    });
  }

  Future<void> removePizza(String pizzaId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _datasource.deletePizza(pizzaId);
      ref.invalidate(pizzasProvider);
      final sellerRestaurant = await ref.read(sellerRestaurantProvider.future);
      if (sellerRestaurant == null) return [];
      return await _datasource.getPizzasByRestaurant(sellerRestaurant.id);
    });
  }
}

final sellerPizzasProvider =
    AsyncNotifierProvider<SellerPizzasNotifier, List<PizzaModel>>(
  SellerPizzasNotifier.new,
);
