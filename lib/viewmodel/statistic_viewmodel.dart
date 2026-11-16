import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/expense.dart';
import '../models/category.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';

class StatisticViewModel extends ChangeNotifier {
  final _repo = ExpenseRepository();
  //* recuperare la categoria dal db
  final _catRepo = CategoryRepository();
  // lista delle categorie
  List<Category> _allCategories = [];

  List<Category> get allCategories => _allCategories;
  List<Expense> _allExpenses = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _monthFilter;

  List<Expense> get allExpenses => _allExpenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get monthFilter => _monthFilter;

  void setMonthFilter(int? month) {
    _monthFilter = month;
    notifyListeners();
  }

  // carica tutte le spese dell'utente
  Future<void> loadExpenses() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Utente non autenticato');
      _allExpenses = await _repo.fetchExpenses(user.id);
      _allCategories = await _catRepo.fetchAll();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // calcola la somma totale delle spese
  Map<int, double> calculateMonthlyExpenses(int year) {
    final Map<int, double> totals = {for (var m = 1; m <= 12; m++) m: 0.0};

    for (final exp in _allExpenses) {
      if (exp.date.year == year) {
        if (_monthFilter == null || exp.date.month == _monthFilter) {
          totals[exp.date.month] = totals[exp.date.month]! + exp.amount;
        }
      }
    }

    return totals;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Map<Category, double> calculateCategoryExpenses(int year) {
    final Map<String, double> temp = {};
    for (final exp in _allExpenses) {
      if (exp.date.year == year &&
          (_monthFilter == null || exp.date.month == _monthFilter)) {
        temp.update(
          exp.categoryId,
          (value) => value + exp.amount,
          ifAbsent: () => exp.amount,
        );
      }
    }

    final result = <Category, double>{};
    for (final cat in _allCategories) {
      final val = temp[cat.id] ?? 0.0;
      if (val > 0) {
        result[cat] = val;
      }
    }

    return result;
  }

  //* calcola il totale delle spese per anno/mese
  // Restituisce 0 se non ci sono spese in quel periodo

  Future<double> calculateTotalForPeriod(int year, int? month) async {
    double total = 0.0;
    for (final exp in _allExpenses) {
      if (exp.date.year == year && (month == null || exp.date.month == month)) {
        total += exp.amount;
      }
    }
    return total;
  }

  //* confronta due periodi (anno 1, mese 1) e (anno 2, mese 2)
  // Ritorna mappa con chiavi 'periodo1' e 'periodo2' 'difference, 'percentChange'
  Future<Map<String, dynamic>> comparePeriods(
    int year1, int? month1, int year2, int? month2) async {
    final total1 = await calculateTotalForPeriod(year1, month1);
    final total2 = await calculateTotalForPeriod(year2, month2);
    final difference = total1 - total2;
    final percentChange = total2 != 0 ? (difference / total2) * 100 : 0;
    return {
      'periodo1': total1,
      'periodo2': total2,
      'difference': difference,
      'percentChange': percentChange,
    };
  }
}
