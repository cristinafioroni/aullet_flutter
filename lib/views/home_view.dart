import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/components/aullet_logo.dart';
import 'auth/components/aullet_logotipo.dart';

import 'package:aullet/core/theme/app_color.dart';

import 'signup_view.dart';
import 'profile_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                AulletLogo(),
                SizedBox(width: 10),
                AulletLogoTipo(size: 50),
              ],
            ),
            Text(
              'Let your spending speak',
              style: GoogleFonts.caveat(
                fontSize: 28,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 220,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  'Crea un account',
                  style: GoogleFonts.outfit(
                    color: AppColors.textLight,
                    fontSize: 14,
                    
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: 220,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.textLight,
                  side: const BorderSide(color: AppColors.textLight),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  'Login',
                  style: GoogleFonts.outfit(
                    color: AppColors.textLight,
                    fontSize: 14,
                    
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
