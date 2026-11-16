import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aullet/models/income.dart';
import 'package:aullet/repositories/income_repository.dart';

class IncomeViewModel extends ChangeNotifier {
  final _repo = IncomeRepository();

  List<Income> _incomes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getter
  List<Income> get incomes => _incomes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Recupera tutte le entrate dell'utente
  Future<void> fetchIncomes(String userId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _incomes = await _repo.fetchIncomes(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Inserisce una nuova entrata
  Future<void> addIncome(Income income) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _repo.insertIncome(income);

      // Aggiorna la lista delle entrate
      _incomes = await _repo.fetchIncomes(income.userId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Modifica un'entrata esistente
  Future<void> updateIncome(Income income) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Utente non autenticato');
      }

      await _repo.updateIncome(income);

      // Aggiorna la lista delle entrate
      _incomes = await _repo.fetchIncomes(user.id);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Elimina un'entrata
  Future<void> deleteIncome(String id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Utente non autenticato');
      }

      await _repo.deleteIncome(id);

      // Aggiorna la lista delle entrate
      _incomes = await _repo.fetchIncomes(user.id);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Gestisce lo stato di caricamento
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}