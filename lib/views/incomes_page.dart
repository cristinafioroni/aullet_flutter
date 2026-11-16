import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aullet/core/theme/app_color.dart';
import 'package:aullet/viewmodel/income_viewmodel.dart';

import 'new_income_page.dart';

import 'auth/components/custom_app_bar.dart';
import 'auth/components/bottom_nav_bar.dart';

class IncomesPage extends StatelessWidget {
  const IncomesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final incomeVM = context.watch<IncomeViewModel>();
    final incomes = incomeVM.incomes;

    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: const CustomBottomNavBar(showAddButton: false),
      backgroundColor: AppColors.secondary,

      body: incomeVM.isLoading
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
                          text: 'entrate',
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
                //* Pulsante per registrare una nuova entrata
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewIncomePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, color: AppColors.background),
                      label: Text(
                        'Aggiungi nuova entrata',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.background,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lime,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),

                //* Lista dei guadagni oppure messaggio se vuota
                Expanded(
                  child: incomes.isEmpty
                      ? const Center(
                          // messaggio con lista vuota
                          child: Text(
                            'Non è stata aggiunta nessuna entrata',
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
                          itemCount: incomes.length,

                          separatorBuilder: (_, _) => const SizedBox(height: 4),

                          itemBuilder: (context, index) {
                            final income = incomes[index];

                            // Formatta la data
                            final date = income.date;

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

                                  leading: const Icon(
                                    Icons.account_balance_wallet,
                                    color: AppColors.lime,
                                    size: 28,
                                  ),

                                  // Importo dell'entrata
                                  title: Text(
                                    '€ ${income.amount.toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.lime,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  // Categoria, data e descrizione
                                  subtitle: Text(
                                    '$formattedDate'
                                    '${income.description != null && income.description!.isNotEmpty ? '\n${income.description}' : ''}',
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
                                                  NewIncomePage(income: income),
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
                                                    'Elimina entrata',
                                                    style: GoogleFonts.outfit(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    'Sei sicuro di voler eliminare questa entrata? L\'operazione non potrà essere annullata.',
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
                                          await incomeVM.deleteIncome(
                                            income.id,
                                          );

                                          if (!context.mounted) return;

                                          // Controlla se l'eliminazione ha generato errori
                                          final error = incomeVM.errorMessage;

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                error == null
                                                    ? 'Entrata eliminata correttamente!'
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
