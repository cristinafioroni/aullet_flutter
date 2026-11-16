import 'package:flutter/material.dart';
import 'package:aullet/core/theme/app_color.dart';
import 'package:aullet/models/category.dart';

// Mappa statica nome -> IconData
final Map<String, IconData> iconMap = {
  'local_hospital': Icons.local_hospital,
  'fastfood': Icons.fastfood,
  'checkroom': Icons.checkroom,
  'directions_bus': Icons.directions_bus,
  'directions_car': Icons.directions_car,
  'store': Icons.store,
  'home': Icons.home,
  'clean_hands': Icons.clean_hands,
  'sports_soccer': Icons.sports_soccer,
  'card_giftcard': Icons.card_giftcard,
  'restaurant': Icons.restaurant,
  'movie': Icons.movie,
};

// Nella UI
Widget buildCategoryItem(Category cat) {
  final iconData = iconMap[cat.icon] ?? Icons.category;

  return ListTile(leading: Icon(iconData), title: Text(cat.name));
}
