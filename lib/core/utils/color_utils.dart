import 'package:flutter/material.dart';

Color parseHexColor(String hex) {
  String value = hex.trim();

  // Rimuove il prefisso #
  if (value.startsWith('#')) {
    value = value.substring(1);
  }

  // Rimuove il prefisso 0x
  if (value.toLowerCase().startsWith('0x')) {
    value = value.substring(2);
  }

  // Se sono presenti solo 6 caratteri, aggiunge FF per l'opacità
  if (value.length == 6) {
    value = 'FF$value';
  }

  return Color(int.parse(value, radix: 16));
}