import 'package:aullet/models/expense.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseRepository {
  final _client = Supabase.instance.client;

  Future<void> insertExpense(Expense exp) async {
    await _client.from('expenses').insert(exp.toMap());
  }

  // recupera tutte le spese di un utente ordinate per data
  Future<List<Expense>> fetchExpenses(String userId) async {
    final data = await _client
        .from('expenses')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);
    return (data as List<dynamic>)
    .map((e) => Expense.fromMap(e as Map<String, dynamic>))
    .toList();
  }

  // aggiorna una spesa esistente
  Future<void> updateExpense(Expense exp) async {
    await _client
    .from('expenses')
    .update(exp.toMap())
    .eq('id', exp.id);
  }

  // elimina una spesa esistente
  Future<void> deleteExpense(String id) async {
    await _client
    .from('expenses')
    .delete()
    .eq('id', id);
  }
}
