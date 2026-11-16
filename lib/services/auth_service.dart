import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // Registra un utente via mail/password
  // Ho aggiunto firstName e lastName perché voglio
  // che displayName prenda automaticamente firstName
  Future<AuthResponse> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {

    // Registra l'utente su Supabase Auth
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Recupera l'utente appena registrato
    final user = response.user;

    if (user == null || response.session == null) {
      throw Exception('Registrazione non completata');
    }

    // Crea il profilo nella tabella profiles
    await _supabase.from('profiles').insert({
      'user_id': user.id,
      'first_name': firstName,
      'last_name': lastName,
      'display_name': firstName,
    });

    return response;
  }

  // Esegue il login di un utente via mail/password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Esegue il logout dell'utente corrente
  Future<void> signOut() {
    return _supabase.auth.signOut();
  }

  // Restituisce l'utente corrente loggato
  User? get currentUser => _supabase.auth.currentUser;
}