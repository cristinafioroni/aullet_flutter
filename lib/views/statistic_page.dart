import 'package:aullet/viewmodel/statistic_viewmodel.dart';
import 'package:aullet/core/theme/app_color.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/components/custom_app_bar.dart';
import 'auth/components/bottom_nav_bar.dart';
import 'auth/components/years_dropdown.dart';
import 'auth/components/month_dropdown.dart';
import 'auth/components/category_pie_chart.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  int _selectedYear = DateTime.now().year;
  int _year1 = DateTime.now().year;
  int? _month1;
  int _year2 = DateTime.now().year;
  int? _month2;

  Map<String, dynamic>? _comparison;

  final List<String> _months = [
    'Gen',
    'Feb',
    'Mar',
    'Apr',
    'Mag',
    'Giu',
    'Lug',
    'Ago',
    'Set',
    'Ott',
    'Nov',
    'Dic',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<StatisticViewModel>().loadExpenses();
    });
  }

  Future<void> _doCompare() async {
    final vm = context.read<StatisticViewModel>();

    final result = await vm.comparePeriods(_year1, _month1, _year2, _month2);

    if (!mounted) return;

    setState(() {
      _comparison = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatisticViewModel>();

    // Recuperiamo gli anni delle spese
    final currentYear = DateTime.now().year;

    final yearList = List.generate(5, (index) => currentYear - index);

    if (!yearList.contains(_selectedYear)) {
      yearList.insert(0, _selectedYear);
    }

    // Totali mensili calcolati dal ViewModel
    final monthlyExpenses = vm.calculateMonthlyExpenses(_selectedYear);
    // Totali delle spese per categoria
    final categoryExpenses = vm.calculateCategoryExpenses(_selectedYear);

    // Totale delle spese del periodo selezionato
    final totalExpenses = monthlyExpenses.values.fold<double>(
      0.0,

      (sum, amount) => sum + amount,
    );

    // Importo massimo per dimensionare il grafico
    final maxExpense = monthlyExpenses.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      //* custom app bar and bottom navigation bar
      appBar: const CustomAppBar(),
      bottomNavigationBar: const CustomBottomNavBar(),

      backgroundColor: AppColors.secondary,

      // body*
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.lime),
            )
          : vm.errorMessage != null
          ? Center(
              child: Text(
                vm.errorMessage!,

                style: const TextStyle(color: AppColors.accent),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  //* Titolo

                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Le tue ',

                          style: GoogleFonts.outfit(
                            fontSize: 26,

                            fontWeight: FontWeight.bold,

                            color: AppColors.textPrimary,
                          ),
                        ),

                        TextSpan(
                          text: 'statistiche',

                          style: GoogleFonts.caveat(
                            fontSize: 32,

                            fontWeight: FontWeight.bold,

                            color: AppColors.lime,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  //* Filtri anno e mese
                  Row(
                    children: [
                      Expanded(
                        child: YearDropdown(
                          value: _selectedYear,
                          years: yearList,
                          onChanged: (year) {
                            if (year != null) {
                              setState(() {
                                _selectedYear = year;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MonthDropdown(
                          value: vm.monthFilter,
                          onChanged: (month) {
                            vm.setMonthFilter(month);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  //* Card con totale delle spese
                  Card(
                    color: AppColors.surface,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(20),

                      child: Column(
                        children: [
                          Text(
                            vm.monthFilter == null
                                ? 'Totale spese $_selectedYear'
                                : 'Totale ${_months[vm.monthFilter! - 1]} $_selectedYear',

                            style: GoogleFonts.outfit(
                              fontSize: 16,

                              color: AppColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '€ ${totalExpenses.toStringAsFixed(2)}',

                            style: GoogleFonts.outfit(
                              fontSize: 28,

                              fontWeight: FontWeight.bold,

                              color: AppColors.lime,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  //* Titolo grafico
                  Text(
                    'Spese mensili',

                    style: GoogleFonts.outfit(
                      fontSize: 20,

                      fontWeight: FontWeight.bold,

                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  //* Grafico a barre
                  SizedBox(
                    height: 300,

                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,

                        maxY: maxExpense == 0 ? 100 : maxExpense * 1.2,

                        barGroups: List.generate(12, (index) {
                          final month = index + 1;

                          return BarChartGroupData(
                            x: index,

                            barRods: [
                              BarChartRodData(
                                toY: monthlyExpenses[month] ?? 0,

                                color: AppColors.primary,

                                width: 14,

                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }),

                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,

                              reservedSize: 30,

                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();

                                if (index < 0 || index >= _months.length) {
                                  return const SizedBox.shrink();
                                }

                                return SideTitleWidget(
                                  meta: meta,

                                  child: Text(
                                    _months[index],

                                    style: GoogleFonts.outfit(
                                      fontSize: 10,

                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        gridData: const FlGridData(show: false),

                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Confronto tra periodi
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Le tue spese nel ',

                              style: GoogleFonts.outfit(
                                fontSize: 26,

                                fontWeight: FontWeight.bold,

                                color: AppColors.textPrimary,
                              ),
                            ),

                            TextSpan(
                              text: 'tempo',

                              style: GoogleFonts.caveat(
                                fontSize: 32,

                                fontWeight: FontWeight.bold,

                                color: AppColors.lime,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Selezione periodo 1

                      Row(
                        children: [
                          Expanded(
                            child: YearDropdown(
                              value: _year1,
                              years: yearList.contains(_year1)
                                  ? yearList
                                  : ([...yearList, _year1]..sort()),
                              onChanged: (year) {
                                if (year != null) setState(() => _year1 = year);
                              },
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: MonthDropdown(
                              value: _month1,
                              onChanged: (month) {
                                setState(() => _month1 = month);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Selezione periodo 2
                      Row(
                        children: [
                          Expanded(
                            child: YearDropdown(
                              value: _year2,
                              years: yearList.contains(_year2)
                                  ? yearList
                                  : ([...yearList, _year2]..sort()),
                              onChanged: (year) {
                                if (year != null) setState(() => _year2 = year);
                              },
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: MonthDropdown(
                              value: _month2,
                              onChanged: (month) {
                                setState(() => _month2 = month);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lime,
                        ),
                        onPressed: _doCompare,

                        child: Text(
                          'Confronta',
                          style: GoogleFonts.outfit(
                            color: AppColors.background,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      if (_comparison != null) ...[
                        Text(
                          'Totale Periodo 1: €${_comparison!['periodo1'].toStringAsFixed(2)}',
                        ),

                        Text(
                          'Totale Periodo 2: €${_comparison!['periodo2'].toStringAsFixed(2)}',
                        ),

                        Text(
                          'Differenza: €${_comparison!['difference'].toStringAsFixed(2)}',
                        ),

                        Text(
                          'Variazione %: ${_comparison!['percentChange'].toStringAsFixed(1)}%',
                        ),

                        const SizedBox(height: 24),

                        // Grafico a colonne comparativo
                        SizedBox(
                          height: 200,

                          child: BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: true),

                              borderData: FlBorderData(show: false),

                              alignment: BarChartAlignment.spaceAround,

                              maxY:
                                  [
                                    _comparison!['periodo1'] as double,

                                    _comparison!['periodo2'] as double,
                                  ].reduce((a, b) => a > b ? a : b) *
                                  1.2,

                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,

                                    getTitlesWidget: (x, meta) {
                                      if (x.toInt() == 0) {
                                        return const Text('P1');
                                      }

                                      return const Text('P2');
                                    },
                                  ),
                                ),

                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),

                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),

                              barGroups: [
                                BarChartGroupData(
                                  x: 0,

                                  barRods: [
                                    BarChartRodData(
                                      toY: _comparison!['periodo1'] as double,

                                      width: 20,
                                    ),
                                  ],
                                ),

                                BarChartGroupData(
                                  x: 1,

                                  barRods: [
                                    BarChartRodData(
                                      toY: _comparison!['periodo2'] as double,

                                      width: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Grafico delle spese per categoria
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Come si dividono le tue',

                          style: GoogleFonts.outfit(
                            fontSize: 26,

                            fontWeight: FontWeight.bold,

                            color: AppColors.textPrimary,
                          ),
                        ),

                        TextSpan(
                          text: ' spese',

                          style: GoogleFonts.caveat(
                            fontSize: 32,

                            fontWeight: FontWeight.bold,

                            color: AppColors.lime,
                          ),
                        ),

                        TextSpan(
                          text: ' ?',

                          style: GoogleFonts.outfit(
                            fontSize: 26,

                            fontWeight: FontWeight.bold,

                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  CategoryPieChart(
                    categoryExpenses: categoryExpenses,
                    isDonut: false,
                    showPercentage: true,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
