import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aullet/core/theme/app_color.dart';
import 'package:aullet/core/utils/color_utils.dart';
import 'package:aullet/core/utils/icon_map.dart';

import 'package:aullet/viewmodel/expense_viewmodel.dart';
import 'package:aullet/viewmodel/category_viewmodel.dart';

import 'auth/components/custom_app_bar.dart';
import 'auth/components/bottom_nav_bar.dart';

import 'new_expenses_page.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseVM = context.watch<ExpenseViewModel>();
    final catVM = context.watch<CategoryViewModel>();
    final expenses = expenseVM.expenses;

    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: const CustomBottomNavBar(),
      backgroundColor: AppColors.secondary,

      body: expenseVM.isLoading || catVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.lime),
            )
          : Column(
            mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Le mie ',
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'spese',
                          style: GoogleFonts.caveat(
                            color: AppColors.lime,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //* Lista delle spese oppure messaggio se vuota
                Expanded(
                  child: expenses.isEmpty
                      ? const Center(
                          // messaggio con lista vuota
                          child: Text(
                            'Non è stata aggiunta nessuna spesa',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          // // la listra occupa lo spazio necessario per mostrare le card
                          // shrinkWrap: true,
                          // // evita che la lista sia scrollabile singolarmente, delegando lo scroll al genitore
                          // physics: const NeverScrollableScrollPhysics(),
                          itemCount: expenses.length,

                          separatorBuilder: (_, _) => const SizedBox(height: 4),

                          itemBuilder: (context, index) {
                            final exp = expenses[index];

                            // Cerca la categoria associata alla spesa
                            final categoryIndex = catVM.categories.indexWhere(
                              (c) => c.id == exp.categoryId,
                            );

                            final cat = categoryIndex >= 0
                                ? catVM.categories[categoryIndex]
                                : null;

                            // Recupera l'icona della categoria
                            final iconData = cat != null
                                ? (iconMap[cat.icon] ?? Icons.category)
                                : Icons.category;

                            // Recupera il colore della categoria
                            final color = cat?.color != null
                                ? parseHexColor(cat!.color!)
                                : AppColors.primary;

                            // Recupera il nome della categoria
                            final categoryName =
                                cat?.name ?? 'Categoria sconosciuta';

                            // Formatta la data
                            final date = exp.date;

                            final formattedDate =
                                '${date.day.toString().padLeft(2, '0')}/'
                                '${date.month.toString().padLeft(2, '0')}/'
                                '${date.year}';

                            //* Container della spesa con gradiente colorato basato sulla categoria + CARD spesa

                            return Container(
                              // personalizzazione del container della spesa con aggiunta del gradiente colorato che riprende colore della categoria associata
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              padding: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: SweepGradient(
                                  colors: [
                                    color,
                                    color.withValues(alpha: 0.0),
                                    color.withValues(alpha: 0.0),
                                    color,
                                  ],
                                ),
                              ),
                              child: Card(
                                color: AppColors.card,
                                margin: EdgeInsets.zero,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),

                                  // Icona della categoria
                                  leading: Icon(
                                    iconData,
                                    color: color,
                                    size: 28,
                                  ),

                                  // Importo della spesa
                                  title: Text(
                                    '€ ${exp.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  // Categoria, data e descrizione
                                  subtitle: Text(
                                    '$categoryName - $formattedDate'
                                    '${exp.description != null && exp.description!.isNotEmpty ? '\n${exp.description}' : ''}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),

                                  // Pulsanti modifica ed elimina
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: AppColors.textPrimary,
                                        ),
                                        onPressed: () async {
                                          // Modifica spesa
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  NewExpensesPage(expense: exp),
                                            ),
                                          );
                                        },
                                      ),

                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                        ),
                                        onPressed: () async {
                                          // Mostra la finestra di conferma
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (dialogContext) =>
                                                AlertDialog(
                                                  backgroundColor:
                                                      AppColors.card,
                                                  title: Text(
                                                    'Elimina spesa',
                                                    style: GoogleFonts.outfit(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    'Sei sicuro di voler eliminare questa spesa? L\'operazione non potrà essere annullata.',
                                                    style: GoogleFonts.outfit(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  actions: [
                                                    // Pulsante Annulla
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          dialogContext,
                                                          false,
                                                        );
                                                      },
                                                      child: Text(
                                                        'Annulla',
                                                        style:
                                                            GoogleFonts.outfit(
                                                              color: AppColors
                                                                  .textPrimary,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),

                                                    // Pulsante Elimina
                                                    TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                            foregroundColor:
                                                                AppColors
                                                                    .textPrimary,
                                                            backgroundColor:
                                                                AppColors
                                                                    .accent,
                                                          ),
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          dialogContext,
                                                          true,
                                                        );
                                                      },
                                                      child: Text(
                                                        'Elimina',
                                                        style:
                                                            GoogleFonts.outfit(
                                                              color: AppColors
                                                                  .textPrimary,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );

                                          // Se l'utente annulla, non facciamo nulla
                                          if (confirm != true ||
                                              !context.mounted)
                                            return;

                                          // Elimina la spesa tramite il ViewModel
                                          await expenseVM.deleteExpense(exp.id);

                                          if (!context.mounted) return;

                                          // Controlla se l'eliminazione ha generato errori
                                          final error = expenseVM.errorMessage;

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                error == null
                                                    ? 'Spesa eliminata correttamente!'
                                                    : 'Errore durante l\'eliminazione: $error',
                                              ),
                                              backgroundColor: error == null
                                                  ? AppColors.primary
                                                  : AppColors.accent,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
