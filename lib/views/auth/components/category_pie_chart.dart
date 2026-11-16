import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aullet/models/category.dart';
import 'package:aullet/core/theme/app_color.dart';
import 'package:aullet/core/utils/color_utils.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<Category, double> categoryExpenses;
  final bool isDonut;
  final bool showPercentage;

  const CategoryPieChart({
    super.key,
    required this.categoryExpenses,
    this.isDonut = false,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    // Calcola il totale delle spese
    final total = categoryExpenses.values.fold<double>(
      0.0,
      (sum, amount) => sum + amount,
    );

    // Se non ci sono spese mostra un messaggio
    if (total == 0) {
      if (isDonut) {
        return const SizedBox.shrink();
      } else {
        return const Center(
          child: Text(
            'Nessuna spesa per il periodo selezionato',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        );
      }
    }

    // Crea una sezione del grafico per ogni categoria
    final sections = categoryExpenses.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value;

      final color = category.color != null
          ? parseHexColor(category.color!)
          : AppColors.primary;

      return PieChartSectionData(
        color: color,
        value: amount,
        title: showPercentage ? '${(amount / total * 100).toStringAsFixed(1)}%' : '',
        radius: isDonut ? 45 : 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.background,
        ),
      );
    }).toList();

    return Column(
      children: [
        // Grafico a torta o donut
        SizedBox(
          height: 250,

          // Stack permette di sovrapporre i widget
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Grafico a torta o donut
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: isDonut ? 50 : 0,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),

              // Totale al centro, il testo al centro viene mostrato
              // solo se il componente è un donut
              if (isDonut)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Il mio mese',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    Text(
                      '€ ${total.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Legenda delle categorie
        const SizedBox(height: 24),

        ...categoryExpenses.entries.map((entry) {
          final category = entry.key;
          final amount = entry.value;

          final percentage = total > 0 ? (amount / total) * 100 : 0.0;

          final color = category.color != null
              ? parseHexColor(category.color!)
              : AppColors.primary;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                // Indicatore colorato
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 12),

                // Nome della categoria
                Expanded(
                  child: Text(
                    category.name,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                // Importo della categoria
                Text(
                  '${!showPercentage ? '${percentage.toStringAsFixed(1)}%  •  ' : ''}€ ${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
