import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aullet/core/theme/app_color.dart';

class MonthDropdown extends StatelessWidget {
  // il valore può essere null se si vogliono selezionare tutti i mesi
  final int? value;
  final ValueChanged<int?> onChanged;

  const MonthDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final List<String> _months = const [
    'Gen', 'Feb', 'Mar', 'Apr',
    'Mag', 'Giu', 'Lug', 'Ago',
    'Set', 'Ott', 'Nov', 'Dic',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int?>(
      value: value,
      isExpanded: true,
      dropdownColor: AppColors.card,
      style: GoogleFonts.outfit(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Tutti i mesi'),
        ),
        ...List.generate(12, (index) {
          return DropdownMenuItem<int?>(
            value: index + 1,
            child: Text(_months[index]),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}