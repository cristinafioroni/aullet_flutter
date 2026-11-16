import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aullet/viewmodel/income_viewmodel.dart';
import 'package:aullet/viewmodel/category_viewmodel.dart';


import 'package:aullet/core/theme/app_color.dart';


import 'auth/components/bottom_nav_bar.dart';
import 'auth/components/custom_app_bar.dart';

import 'package:aullet/models/income.dart';

class NewIncomePage extends StatefulWidget {
  final Income? income;
  const NewIncomePage({super.key, this.income});

  @override
  State<NewIncomePage> createState() => _NewIncomePageState();
}

class _NewIncomePageState extends State<NewIncomePage> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.income != null) {
      final income = widget.income!;

      _amountController.text = income.amount.toString();
      _descriptionController.text = income.description ?? '';
      _selectedDate = income.date;
    }
  }

  //* Permette di selezionare la data della spesa, altrimenti non possiamo fare le comparazioni nelle statistiche
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),

      // Personalizzazione del calendario
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.lime,
              onPrimary: AppColors.background,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            // Colore del testo digitato nel calendario
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    // Se l'utente seleziona una data
    if (pickedDate != null && mounted) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Salva la nuova spesa
  Future<void> _saveIncome() async {
    // Controlla i campi obbligatori
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Recupera l'utente autenticato
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Utente non autenticato')));
      return;
    }

    // Recupera l'importo
    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    // Crea la spesa
    // Crea una nuova spesa oppure mantiene l'ID di quella esistente
    final income = Income(
      id: widget.income?.id ?? const Uuid().v4(),
      userId: userId,
      amount: amount,
      date: _selectedDate,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    try {
      // Salva su Supabase tramite il ViewModel
      final incomeVM = context.read<IncomeViewModel>();

      if (widget.income == null) {
        // Nuovo reddito
        await incomeVM.addIncome(income);
      } else {
        // Modifica reddito esistente
        await incomeVM.updateIncome(income);

        if (incomeVM.errorMessage != null) {
          throw Exception(incomeVM.errorMessage);
        }
      }

      if (!mounted) return;

      // Torna alla Dashboard
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante il salvataggio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: const CustomBottomNavBar(),
      backgroundColor: AppColors.secondary,
      body: Container(
        width: double.infinity,

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                //* Titolo della pagina
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: 'Inserisci le tue ',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                      TextSpan(
                        text: 'entrate',
                        style: GoogleFonts.caveat(
                          color: AppColors.lime,
                          fontSize: 24 * 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                //* form di inserimento delle spese
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //* campo per l'importo della spesa
                      // importo
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ), // supporta numeri decimali

                        style: GoogleFonts.outfit(
                          color: AppColors.textLight,
                          fontSize: 20,
                        ),
                        cursorColor: AppColors.textLight,
                        decoration: InputDecoration(
                          labelText: 'Importo',
                          labelStyle: GoogleFonts.outfit(
                            color: AppColors.textLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),

                          prefixIcon: const Icon(
                            Icons.euro,
                            color: AppColors.lime,
                          ),
                          filled: true,
                          fillColor: AppColors.card,

                          // bordi
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.lime,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final amount = double.tryParse(
                            (value ?? '').trim().replaceAll(',', '.'),
                          );
                          if (amount == null || amount <= 0) {
                            return 'Inserisci un importo valido';
                          }
                          return null;
                        },
                      ),

                      //* calendario
                      const SizedBox(height: 40),

                      // Campo per selezionare la data della spesa
                      InkWell(
                        onTap: _pickDate,

                        borderRadius: BorderRadius.circular(16),

                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Data dell\'entrata',

                            labelStyle: GoogleFonts.outfit(
                              color: AppColors.textLight,
                              fontSize: 16,
                            ),

                            prefixIcon: const Icon(
                              Icons.calendar_month,
                              color: AppColors.lime,
                            ),

                            filled: true,
                            fillColor: AppColors.card,

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),

                          child: Text(
                            '${_selectedDate.day.toString().padLeft(2, '0')}/'
                            '${_selectedDate.month.toString().padLeft(2, '0')}/'
                            '${_selectedDate.year}',

                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      //* descrizione della spesa
                      TextFormField(
                        controller: _descriptionController,

                        minLines: 5,
                        maxLines: 6,

                        textAlignVertical: TextAlignVertical.top,

                        style: GoogleFonts.outfit(
                          color: AppColors.textLight,
                          fontSize: 16,
                        ),
                        cursorColor: AppColors.lime,
                        decoration: InputDecoration(
                          labelText: 'Descrizione (facoltativa)',
                          alignLabelWithHint: true,
                          labelStyle: GoogleFonts.outfit(
                            color: AppColors.textLight,
                            fontSize: 16,
                          ),

                          filled: true,
                          fillColor: AppColors.card,
                          // bordi
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.lime,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Pulsante per salvare la spesa
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveIncome,

                    label: Text(
                      widget.income == null ? 'Registra nuova entrata' : 'Modifica entrata',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lime,
                      foregroundColor: AppColors.secondary,

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
