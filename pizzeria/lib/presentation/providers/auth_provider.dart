import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/datasources/auth_datasource.dart';
import 'package:pizzeria/models/user_profile.dart';

final authDatasourceProvider = Provider<AuthDatasource>((ref) {
  return SupabaseAuthDatasource();
});

class AuthNotifier extends AsyncNotifier<UserProfile?> {
  AuthDatasource get _datasource => ref.read(authDatasourceProvider);

  @override
  Future<UserProfile?> build() async {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final user = data.session?.user ?? Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profile = await _datasource.getCurrentUserProfile();
        state = AsyncData(profile);
      } else {
        state = const AsyncData(null);
      }
    });

    return await _datasource.getCurrentUserProfile();
  }

  Future<UserProfile> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _datasource.signIn(email: email, password: password);
      state = AsyncValue.data(profile);
      return profile;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<UserProfile> signUpBuyer({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _datasource.signUpBuyer(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = AsyncValue.data(profile);
      return profile;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<UserProfile> signUpSeller({
    required String email,
    required String password,
    required String fullName,
    required String restaurantName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _datasource.signUpSeller(
        email: email,
        password: password,
        fullName: fullName,
        restaurantName: restaurantName,
      );
      state = AsyncValue.data(profile);
      return profile;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _datasource.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserProfile?>(AuthNotifier.new);
