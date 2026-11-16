import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aullet/core/theme/app_color.dart';

class YearDropdown extends StatelessWidget {
  // anno attualmente selezionato
  final int value;
  // lista degli anni disponibili
  final List<int> years;
  // funzione che chiamerà quando l'anno selezionato cambia
  final ValueChanged<int?> onChanged;

  const YearDropdown({
    super.key,
    required this.value,
    required this.years,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: value,
      isExpanded: true,
      dropdownColor: AppColors.card,
      style: GoogleFonts.outfit(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      items: years.map((year) {
        return DropdownMenuItem<int>(
          value: year,
          child: Text(year.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}