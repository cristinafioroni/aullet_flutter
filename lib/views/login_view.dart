
import 'package:aullet/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/components/custom_app_bar.dart';
import 'auth/components/custom_text_field.dart';

import 'package:aullet/viewmodel/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:aullet/views/dashboard_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text.rich(
                  TextSpan(
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: 'Acc',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'edi',
                        style: GoogleFonts.caveat(
                          color: AppColors.accent,
                          fontSize: 34,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Email
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // Password
              CustomTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: true,
              ),

              const SizedBox(height: 20),

              // Bottone di login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.secondary,
                  ),
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          await vm.login(
                            _emailController.text,
                            _passwordController.text,
                          );

                          if (!context.mounted) return;

                          if (vm.errorMessage != null) {
                            // Errore: mostra SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(vm.errorMessage!),
                              ),
                            );
                          } else {
                            // Login avvenuto con successo
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Login avvenuto con successo',
                                ),
                              ),
                            );

                            Navigator.pushReplacementNamed(
                              context,
                              '/dashboard',
                            );
                          }
                        },
                  child: vm.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.secondary,
                          ),
                        )
                      : const Text(
                          'Accedi',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Bottone per registrazione
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.outfit(fontSize: 16),
                      children: [
                        TextSpan(
                          text: 'Non hai un account? ',
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: 'Registrati',
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
