import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aullet/core/theme/app_color.dart';

import 'aullet_logotipo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    return AppBar(
      backgroundColor: AppColors.secondary,
      centerTitle: true,

      // Logo Aullet sempre presente
      title: const AulletLogoTipo(),

      // Home a sinistra, solo se l'utente è autenticato
      leading: isLoggedIn
          ? IconButton(
              icon: const Icon(Icons.home),
              color: AppColors.textLight,
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
            )
          : null,

      // Logout a destra, solo se l'utente è autenticato
      actions: [
        if (isLoggedIn)
          IconButton(
            icon: const Icon(Icons.logout),
            color: AppColors.textLight,
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!context.mounted) return;
              Navigator.pushNamed(context, '/home');
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}