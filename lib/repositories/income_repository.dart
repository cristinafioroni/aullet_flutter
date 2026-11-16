import 'package:aullet/models/income.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IncomeRepository {
  final _client = Supabase.instance.client;

  // Inserisce una nuova entrata
  Future<void> insertIncome(Income income) async {
    await _client
        .from('incomes')
        .insert(income.toMap());
  }

  // Recupera le entrate dell'utente ordinate per data
  Future<List<Income>> fetchIncomes(String userId) async {
    final data = await _client
        .from('incomes')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return (data as List<dynamic>)
        .map((e) => Income.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // Aggiorna un'entrata esistente
  Future<void> updateIncome(Income income) async {
    await _client
        .from('incomes')
        .update(income.toMap())
        .eq('id', income.id)
        .eq('user_id', income.userId);
  }

  // Elimina un'entrata esistente
  Future<void> deleteIncome(String id) async {
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Utente non autenticato');
    }

    await _client
        .from('incomes')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }
}
