import 'package:flutter/material.dart';

import '../repositories/category_repository.dart';
import '../models/category.dart';

class CategoryViewModel extends ChangeNotifier {
  final _repo = CategoryRepository();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carica tutte le categorie
  Future<void> loadCategories() async {
    setLoading(true);
    try {
      _categories = await _repo.fetchAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      setLoading(false);
    }
  }
  void setLoading(bool v) {
    _isLoading = v;
    if (v) _error = null;
    notifyListeners();
  }
}
