import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aullet/core/theme/app_color.dart';

class AulletLogoTipo extends StatelessWidget {
  final double size;

  const AulletLogoTipo({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // la row si adatta al contenuto
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo Aullet sempre presente
        Text.rich(
          TextSpan(
            style: GoogleFonts.outfit(
              fontSize: size,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'Aul',
                style: TextStyle(color: AppColors.textLight),
              ),
              TextSpan(
                text: 'let',
                style: GoogleFonts.caveat(
                  color: AppColors.lime,
                  fontSize: size * 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
