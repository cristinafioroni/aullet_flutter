import 'package:flutter/material.dart';
import 'package:aullet/core/theme/app_color.dart';

class CustomTextField extends StatelessWidget {

  //* Proprietà che riceviamo dalla View
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;

  //* Costruttore del componente
  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //* Label sopra il campo
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        //* Campo di input
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,

          // colore testo digitato dall'utente
          style: const TextStyle(
            color: AppColors.textPrimary,
          ),
          //cursor color
          cursorColor: AppColors.accent,

          decoration: const InputDecoration(
            filled: true,
            fillColor: AppColors.surface,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
              borderSide: BorderSide(
                color: AppColors.secondary,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
              borderSide: BorderSide(
                color: AppColors.border,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
              borderSide: BorderSide(
                color: AppColors.secondary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}