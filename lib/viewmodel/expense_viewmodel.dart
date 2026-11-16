import 'package:aullet/models/expense.dart';
import 'package:aullet/repositories/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseViewModel extends ChangeNotifier {
  final _repo = ExpenseRepository();

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchExpenses(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _repo.fetchExpenses(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.insertExpense(expense);

      // aggiorna la lista delle spese
      await fetchExpenses(expense.userId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // metodo per l'aggiornamento della spesa
  Future<void> updateExpense(Expense exp) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Utente non autenticato');

      await _repo.updateExpense(exp);

      // aggiorna la lista delle spese
      _expenses = await _repo.fetchExpenses(user.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // metodo per la cancellazione e aggiornamento della lista
  Future<void> deleteExpense(String id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Utente non autenticato');

      await _repo.deleteExpense(id);

      // aggiorna la lista delle spese
      _expenses = await _repo.fetchExpenses(user.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // gestisce lo stato di caricamento e aggiorna i widget in ascolto
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
