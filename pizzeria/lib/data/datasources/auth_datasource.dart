import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pizzeria/data/mappers/user_mapper.dart';
import 'package:pizzeria/models/user_profile.dart';

abstract class AuthDatasource {
  Future<UserProfile> signUpBuyer({
    required String email,
    required String password,
    required String fullName,
  });

  Future<UserProfile> signUpSeller({
    required String email,
    required String password,
    required String fullName,
    required String restaurantName,
  });

  Future<UserProfile> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserProfile?> getCurrentUserProfile();

  Session? get currentSession;
}

class SupabaseAuthDatasource implements AuthDatasource {
  final SupabaseClient _client;

  SupabaseAuthDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Future<UserProfile> signUpBuyer({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': 'comprador',
      },
    );

    final user = response.user;
    if (user == null) {
      throw Exception('No se pudo registrar el usuario');
    }

    final profileData = {
      'id': user.id,
      'email': email,
      'full_name': fullName,
      'role': 'comprador',
    };

    try {
      await _client.from('profiles').upsert(profileData);
    } catch (_) {}

    return UserProfile(
      id: user.id,
      email: email,
      fullName: fullName,
      role: 'comprador',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserProfile> signUpSeller({
    required String email,
    required String password,
    required String fullName,
    required String restaurantName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': 'vendedor',
      },
    );

    final user = response.user;
    if (user == null) {
      throw Exception('No se pudo registrar el vendedor');
    }

    final profileData = {
      'id': user.id,
      'email': email,
      'full_name': fullName,
      'role': 'vendedor',
    };

    try {
      await _client.from('profiles').upsert(profileData);
      if (_client.auth.currentSession != null) {
        await _client.from('restaurants').insert({
          'seller_id': user.id,
          'name': restaurantName,
          'description': 'Pizzería artesanal e italiana',
          'address': 'Ciudad de México, Centro',
          'latitude': 19.432608,
          'longitude': -99.133209,
          'phone': '555-0199',
          'image_url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
        });
      }
    } catch (_) {}

    return UserProfile(
      id: user.id,
      email: email,
      fullName: fullName,
      role: 'vendedor',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Credenciales incorrectas');
    }

    final metaRole = user.userMetadata?['role']?.toString() ?? 'comprador';
    final metaName = user.userMetadata?['full_name']?.toString() ?? email.split('@').first;

    final profileData = {
      'id': user.id,
      'email': user.email ?? email,
      'full_name': metaName,
      'role': metaRole,
    };

    try {
      await _client.from('profiles').upsert(profileData);
    } catch (_) {}

    final profile = await getCurrentUserProfile();
    if (profile != null) return profile;

    return UserProfile(
      id: user.id,
      email: user.email ?? email,
      fullName: metaName,
      role: metaRole,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser ?? _client.auth.currentSession?.user;
    if (user == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        return UserMapper.fromMap(data);
      }
    } catch (_) {}

    final role = user.userMetadata?['role']?.toString() ?? 'comprador';
    final fullName = user.userMetadata?['full_name']?.toString() ?? user.email?.split('@').first ?? 'Usuario';

    final profileData = {
      'id': user.id,
      'email': user.email ?? '',
      'full_name': fullName,
      'role': role,
    };

    try {
      await _client.from('profiles').upsert(profileData);
    } catch (_) {}

    return UserProfile(
      id: user.id,
      email: user.email ?? '',
      fullName: fullName,
      role: role,
      createdAt: DateTime.now(),
    );
  }
}
