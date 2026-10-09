import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maply/models/place.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static bool get isAuthenticated => currentUser != null;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<List<Place>> getPlaces() async {
    final user = currentUser;
    if (user == null) return [];

    final response = await client
        .from('places')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return response.map((item) => Place.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  static Future<Place> addPlace(Place place) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final placeData = place.copyWith(userId: user.id).toJson();
    final response = await client.from('places').insert(placeData).select().single();

    return Place.fromJson(Map<String, dynamic>.from(response));
  }

  static Future<Place> updatePlace(Place place) async {
    final placeData = place.toJson(isUpdate: true);
    final response = await client
        .from('places')
        .update(placeData)
        .eq('id', place.id)
        .select()
        .single();

    return Place.fromJson(Map<String, dynamic>.from(response));
  }

  static Future<void> deletePlace(String placeId) async {
    await client.from('places').delete().eq('id', placeId);
  }
}
