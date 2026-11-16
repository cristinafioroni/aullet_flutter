import 'package:flutter/material.dart';
import 'package:aullet/core/theme/app_color.dart';
class AulletLogo extends StatelessWidget {
  const AulletLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Color(0xFF5785FF), // Blu neon
            Color(0xFFFF4FD8), // Fucsia neon
            Color(0xFFB5FF5C), // Lime neon
            Color(0xFF5785FF), // Torniamo al blu
          ],
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}