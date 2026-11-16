import 'package:flutter/material.dart';
import 'package:aullet/core/theme/app_color.dart';
import 'package:provider/provider.dart';
import 'package:aullet/viewmodel/profile_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/components/custom_app_bar.dart';
import 'auth/components/bottom_nav_bar.dart';
import 'auth/components/category_pie_chart.dart';

import 'new_income_page.dart';
import 'expenses_page.dart';
import 'incomes_page.dart';

import 'package:aullet/viewmodel/income_viewmodel.dart';
import 'package:aullet/viewmodel/expense_viewmodel.dart';
import 'package:aullet/viewmodel/category_viewmodel.dart';
import 'package:aullet/models/category.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId != null) {
        context.read<ExpenseViewModel>().fetchExpenses(userId);
        context.read<IncomeViewModel>().fetchIncomes(userId);
        context.read<ProfileViewModel>().loadProfile();
      }

      context.read<CategoryViewModel>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: const CustomBottomNavBar(),
      backgroundColor: AppColors.secondary,

      body: Builder(
        builder: (context) {
          final expenseVM = context.watch<ExpenseViewModel>();
          final catVM = context.watch<CategoryViewModel>();
          final incomeVM = context.watch<IncomeViewModel>();

          return expenseVM.isLoading || catVM.isLoading || incomeVM.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(expenseVM, catVM, incomeVM);
        },
      ),
    );
  }

  // Costruisce il contenuto della Dashboard
  Widget _buildBody(
    ExpenseViewModel expenseVM,
    CategoryViewModel catVM,
    IncomeViewModel incomeVM,
  ) {
    final expenses = expenseVM.expenses;

    // Recupera il mese e l'anno corrente
    final now = DateTime.now();

    // Recupera le entrate
    final incomes = incomeVM.incomes;

    // Calcola le entrate del mese corrente
    final monthlyIncome = incomes
        .where(
          (income) =>
              income.date.month == now.month && income.date.year == now.year,
        )
        .fold<double>(0.0, (sum, income) => sum + income.amount);

    // Calcola tutte le spese del mese corrente
    final monthlyExpenses = expenses
        .where(
          (expense) =>
              expense.date.month == now.month && expense.date.year == now.year,
        )
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);

    // Calcola il saldo disponibile
    final monthlyBalance = monthlyIncome - monthlyExpenses;

    // Totali delle spese del mese corrente per categoria
    final monthlyCategoryExpenses = <Category, double>{};

    for (final exp in expenses) {
      // Considera soltanto le spese del mese corrente
      if (exp.date.year == now.year && exp.date.month == now.month) {
        // Cerca la categoria associata alla spesa
        final categoryIndex = catVM.categories.indexWhere(
          (cat) => cat.id == exp.categoryId,
        );

        if (categoryIndex >= 0) {
          final category = catVM.categories[categoryIndex];

          monthlyCategoryExpenses.update(
            category,
            (total) => total + exp.amount,
            ifAbsent: () => exp.amount,
          );
        }
      }
    }

    // Calcola il totale delle spese del mese corrente
    final monthlyTotal = monthlyCategoryExpenses.values.fold<double>(
      0.0,
      (sum, amount) => sum + amount,
    );

    // Recupera il nome dal profilo
    final profileVM = context.watch<ProfileViewModel>();
    final name = profileVM.profile?.displayName ?? 'utente';

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //* Saluto personalizzato
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Ciao, ',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: '$name',
                    style: GoogleFonts.caveat(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lime,
                    ),
                  ),
                  TextSpan(
                    text: ' !',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //* Donut chart delle categorie con le spese del mese
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // Text(
                //   'Spese del mese',
                //   style: GoogleFonts.outfit(
                //     fontSize: 22,
                //     fontWeight: FontWeight.bold,
                //     color: AppColors.textPrimary,
                //   ),
                // ),

                const SizedBox(height: 16),
                CategoryPieChart(
                  categoryExpenses: monthlyCategoryExpenses,
                  isDonut: true,
                  showPercentage: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Card del saldo disponibile
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                children: [
                  Text(
                    'Saldo disponibile',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '€ ${monthlyBalance.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: monthlyBalance > 0
                          ? AppColors.lime
                          : monthlyBalance < 0
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Mese corrente',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Riepilogo spese ed entrate del mese
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Row(
              children: [
                // Card spese
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExpensesPage(),
                        ),
                      );
                    },

                    child: Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.accent, width: 1.2),
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Spese del mese',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),

                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '€ ${monthlyExpenses.toStringAsFixed(2)}',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Card entrate
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IncomesPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lime, width: 1.2),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Entrate del mese',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),

                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.lime,
                                size: 20,
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          //se l'importo dovesse essere troppo lungo(beato chi lo mette), si adatta alla larghezza disponibile
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '€ ${monthlyIncome.toStringAsFixed(2)}',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lime,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
