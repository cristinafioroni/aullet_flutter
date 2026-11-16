import 'package:flutter/material.dart';
import 'package:aullet/core/theme/app_color.dart';

class CustomBottomNavBar extends StatelessWidget {
  final bool showAddButton;
  const CustomBottomNavBar({super.key, this.showAddButton = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Barra inferiore
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: AppColors.secondary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Statistiche
                  IconButton(
                    icon: const Icon(Icons.bar_chart),
                    color: AppColors.textLight,
                    onPressed: () {
                      Navigator.pushNamed(context, '/statistic');
                    },
                  ), // IconButton Home
                  // Spazio per il pulsante centrale
                  // Spazio centrale soltanto quando è presente il pulsante +
                  if (showAddButton) const SizedBox(width: 60),

                  // Profilo
                  IconButton(
                    icon: const Icon(Icons.person),
                    color: AppColors.textLight,
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ), // IconButton Profilo
                ],
              ), // Row
            ), // Container
          ), // Positioned barra inferiore
          // Pulsante + rialzato
          // Pulsante + rialzato
          if (showAddButton)
            Positioned(
              top: -20,

              // Material gestisce il colore, gli angoli arrotondati e l'ombra del pulsante.
              child: Material(
                color: AppColors.lime,
                elevation: 6,
                borderRadius: BorderRadius.circular(16),

                // GestureDetector rileva il tocco senza effetti visivi.
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/newexpense');
                  },
                  child: const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(
                      Icons.add,
                      color: AppColors.secondary,
                      size: 30,
                    ), // Icon
                  ), // SizedBox
                ), // GestureDetector
              ), // Material
            ), // Positioned pulsante +
        ],
      ), // Stack
    ); // SizedBox
  } // build
} // CustomBottomNavBar
