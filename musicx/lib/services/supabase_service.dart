import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:musicx/models/song_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<List<Song>> getSongs() async {
    final response = await _client
        .from('songs')
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((item) => Song.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Song> createSong({
    required String title,
    required String artist,
    required String description,
    required String imageUrl,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client
        .from('songs')
        .insert({
          'user_id': userId,
          'title': title,
          'artist': artist,
          'description': description,
          'image_url': imageUrl,
        })
        .select()
        .single();

    return Song.fromJson(response);
  }

  Future<Song> updateSong({
    required String id,
    required String title,
    required String artist,
    required String description,
    required String imageUrl,
  }) async {
    final response = await _client
        .from('songs')
        .update({
          'title': title,
          'artist': artist,
          'description': description,
          'image_url': imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    return Song.fromJson(response);
  }

  Future<void> deleteSong(String id) async {
    await _client.from('songs').delete().eq('id', id);
  }
}
