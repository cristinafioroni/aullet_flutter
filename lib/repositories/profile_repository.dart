import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class ProfileRepository {
  final _client = Supabase.instance.client;

  // Restituisce il profilo dell'utente o null se non esiste
  Future<Profile?> fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return null;

    return Profile.fromMap(data);
  }

  // Inserisce un nuovo profilo
  Future<Profile> createProfile({
    required String userId,
    required String firstName,
    required String lastName,
  }) async {
    final data = await _client
        .from('profiles')
        .insert({
          'user_id': userId,
          'first_name': firstName,
          'last_name': lastName,
          'display_name': firstName,
        })
        .select()
        .single();

    return Profile.fromMap(data);
  }

  // Aggiorna un profilo esistente
  Future<void> updateProfile(Profile profile) async {
    await _client
        .from('profiles')
        .update(profile.toMap())
        .eq('id', profile.id);
  }
}