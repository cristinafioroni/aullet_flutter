import 'package:flutter/material.dart';

import '../models/category.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRepository {
  final _client = Supabase.instance.client;

  // restituisce tutte le categorie
  Future<List<Category>> fetchAll() async {
    final data = await _client.from('categories').select().order('sort_order', ascending: true);

    return (data as List<dynamic>)
        .map((m) => Category.fromMap(m as Map<String, dynamic>))
        .toList();
  }
}
 