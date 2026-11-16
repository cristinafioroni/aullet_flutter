import 'package:aullet/core/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/components/custom_app_bar.dart';
import 'auth/components/custom_text_field.dart';

import 'package:aullet/viewmodel/auth_view_model.dart';
import 'package:provider/provider.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                        text: 'Crea un ',
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                      ),
                      TextSpan(
                        text: 'account',
                        style: GoogleFonts.caveat(
                          color: AppColors.accent,
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
          
              // Nome
              CustomTextField(label: 'Nome', controller: _firstNameController),
          
              const SizedBox(height: 20),
          
              // Cognome
              CustomTextField(label: 'Cognome', controller: _lastNameController),
          
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
          
              // Bottone di registrazione
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  onPressed: () async {
                    await vm.register(
                      _firstNameController.text.trim(),
                      _lastNameController.text.trim(),
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
          
                    if (!context.mounted) return;
          
                    if (vm.errorMessage != null) {
                      // Errore: mostra SnackBar con il messaggio di errore
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
                    } else {
                      // Registrazione avvenuta con successo, puoi navigare o mostrare un messaggio
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Registrazione avvenuta con successo'),
                        ),
                      );
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    }
                  },
                  child: Text(
                    'Registrati',
                    style: TextStyle(color: AppColors.secondary, fontSize: 16),
                  ),
                ),
              ),
          
              const SizedBox(height: 20),
          
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.outfit(fontSize: 16),
                      children: const [
                        TextSpan(
                          text: 'Hai già un account? ',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        TextSpan(
                          text: 'Accedi',
                          style: TextStyle(
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
