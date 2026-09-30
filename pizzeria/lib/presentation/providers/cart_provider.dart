import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/datasources/cart_datasource.dart';
import 'package:pizzeria/models/cart_item_model.dart';
import 'package:pizzeria/models/pizza_model.dart';
import 'package:pizzeria/presentation/providers/auth_provider.dart';

final cartDatasourceProvider = Provider<CartDatasource>((ref) {
  return SupabaseCartDatasource();
});

class CartNotifier extends Notifier<List<CartItemModel>> {
  CartDatasource get _datasource => ref.read(cartDatasourceProvider);

  String? get _currentUserId {
    return Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id ??
        ref.read(authProvider).value?.id;
  }

  @override
  List<CartItemModel> build() {
    ref.listen(authProvider, (previous, next) {
      final newId = next.value?.id;
      if (newId != null && previous?.value?.id != newId) {
        _loadCartFromDatabase(newId);
      }
    });

    final currentId = _currentUserId;
    if (currentId != null) {
      final channel = Supabase.instance.client
          .channel('public:cart_items:$currentId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'cart_items',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: currentId,
            ),
            callback: (_) => _loadCartFromDatabase(currentId),
          )
          .subscribe();

      ref.onDispose(() {
        channel.unsubscribe();
      });

      Future.microtask(() => _loadCartFromDatabase(currentId));
    }

    return [];
  }

  Future<void> _loadCartFromDatabase(String userId) async {
    final items = await _datasource.getCartItems(userId);
    state = items;
  }

  Future<void> reloadCart() async {
    final uid = _currentUserId;
    if (uid != null) {
      await _loadCartFromDatabase(uid);
    }
  }

  Future<void> addItem(PizzaModel pizza, {int quantity = 1, String size = 'Mediana'}) async {
    final index = state.indexWhere(
      (item) => item.pizza.id == pizza.id && item.size == size,
    );

    final userId = _currentUserId;

    if (index >= 0) {
      final updated = List<CartItemModel>.from(state);
      final newQty = updated[index].quantity + quantity;
      updated[index].quantity = newQty;
      state = updated;

      final itemDbId = updated[index].id;
      if (itemDbId != null && userId != null) {
        await _datasource.updateCartItemQuantity(
          itemId: itemDbId,
          quantity: newQty,
        );
      } else if (userId != null) {
        final saved = await _datasource.addToCart(
          userId: userId,
          pizza: pizza,
          quantity: newQty,
          size: size,
        );
        if (saved != null) {
          final refreshed = List<CartItemModel>.from(state);
          refreshed[index] = saved;
          state = refreshed;
        }
      }
    } else {
      final newItem = CartItemModel(
        pizza: pizza,
        quantity: quantity,
        size: size,
      );
      state = [...state, newItem];

      if (userId != null) {
        final saved = await _datasource.addToCart(
          userId: userId,
          pizza: pizza,
          quantity: quantity,
          size: size,
        );
        if (saved != null) {
          final list = List<CartItemModel>.from(state);
          final lastIdx = list.indexWhere((i) => i.pizza.id == pizza.id && i.size == size);
          if (lastIdx >= 0) {
            list[lastIdx] = saved;
            state = list;
          }
        }
      }
    }
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    if (index < 0 || index >= state.length) return;
    final item = state[index];
    final updated = List<CartItemModel>.from(state);

    if (newQuantity <= 0) {
      updated.removeAt(index);
      state = updated;
      if (item.id != null) {
        await _datasource.removeCartItem(item.id!);
      }
    } else {
      updated[index].quantity = newQuantity;
      state = updated;
      if (item.id != null) {
        await _datasource.updateCartItemQuantity(
          itemId: item.id!,
          quantity: newQuantity,
        );
      }
    }
  }

  Future<void> removeItem(int index) async {
    if (index < 0 || index >= state.length) return;
    final item = state[index];
    final updated = List<CartItemModel>.from(state);
    updated.removeAt(index);
    state = updated;

    if (item.id != null) {
      await _datasource.removeCartItem(item.id!);
    }
  }

  Future<void> clearCart() async {
    final userId = _currentUserId;
    state = [];
    if (userId != null) {
      await _datasource.clearUserCart(userId);
    }
  }

  double get subtotal =>
      state.fold(0.0, (total, item) => total + item.totalPrice);

  double get shippingCost => state.isEmpty ? 0.0 : 45.0;

  double get total => subtotal + shippingCost;

  int get totalItemCount =>
      state.fold(0, (total, item) => total + item.quantity);
}

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItemModel>>(CartNotifier.new);
