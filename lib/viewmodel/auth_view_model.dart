import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  // parametro per verificare lo stato dell'utente loggato
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  //getter
  bool get isLoggedIn => _isLoggedIn;

  //* costruttore per controllo automatico dell'istanza dell'utente loggato
  AuthViewModel() {
    checkCurrentUser();
  }

  void checkCurrentUser() {
    _isLoggedIn = _authService.currentUser != null;
    notifyListeners();
  }

  //* Registra un utente
  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    _setLoading(true);

    try {
      await _authService.signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      // successo -> non c'è errore, puoi navigare o notificare l'utente
    } on AuthException catch (error) {
      // Cattura messaggio si AuthException e lo assegna a _errorMessage
      _errorMessage = error.message;
    } catch (e) {
      // Cattura eventuali altri errori e li assegna a _errorMessage
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);

    try {
      await _authService.signIn(email: email, password: password);
      // Successo -> utente loggato
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    checkCurrentUser();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    // reset errore quando ricomincia il loading
    if (value) {
      _errorMessage = null;
    }
    notifyListeners();
  }
}
