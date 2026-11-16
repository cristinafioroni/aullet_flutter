import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aullet/viewmodel/expense_viewmodel.dart';
import 'package:aullet/viewmodel/category_viewmodel.dart';

import 'package:aullet/core/utils/icon_map.dart';
import 'package:aullet/core/theme/app_color.dart';
import 'package:aullet/core/utils/color_utils.dart';

import 'auth/components/bottom_nav_bar.dart';
import 'auth/components/custom_app_bar.dart';

import 'package:aullet/models/expense.dart';

class NewExpensesPage extends StatefulWidget {
  final Expense? expense;
  const NewExpensesPage({super.key, this.expense});

  @override
  State<NewExpensesPage> createState() => _NewExpensesPageState();
}

class _NewExpensesPageState extends State<NewExpensesPage> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;
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

    if (widget.expense != null) {
      final expense = widget.expense!;

      _amountController.text = expense.amount.toString();
      _descriptionController.text = expense.description ?? '';
      _selectedCategoryId = expense.categoryId;
      _selectedDate = expense.date;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<CategoryViewModel>().loadCategories();
    });
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
  Future<void> _saveExpense() async {
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
    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      userId: userId,
      categoryId: _selectedCategoryId!,
      amount: amount,
      date: _selectedDate,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    try {
      // Salva su Supabase tramite il ViewModel
      final expenseVM = context.read<ExpenseViewModel>();

      if (widget.expense == null) {
        // Nuova spesa
        await expenseVM.addExpense(expense);
      } else {
        // Modifica spesa esistente
        await expenseVM.updateExpense(expense);

        if (expenseVM.errorMessage != null) {
          throw Exception(expenseVM.errorMessage);
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
    final categoryVM = context.watch<CategoryViewModel>();

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
                        text: 'spese',
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

                      const SizedBox(height: 40),

                      // Dropdown delle categorie
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,

                        dropdownColor: AppColors.secondary,

                        style: GoogleFonts.outfit(
                          color: AppColors.textLight,
                          fontSize: 16,
                        ),

                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textLight,
                        ),

                        decoration: InputDecoration(
                          labelText: 'Categoria',

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

                        items: categoryVM.categories.map((category) {
                          // Recupera il colore associato alla categoria
                          final color = category.color != null
                              ? parseHexColor(category.color!)
                              : AppColors.primary;

                          return DropdownMenuItem<String>(
                            value: category.id,

                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icona con il colore della categoria
                                Icon(
                                  iconMap[category.icon] ?? Icons.category,
                                  color: color,
                                ),

                                const SizedBox(width: 8),

                                // Nome della categoria
                                Text(
                                  category.name,
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },

                        validator: (value) {
                          if (value == null) {
                            return 'Seleziona una categoria';
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
                            labelText: 'Data della spesa',

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
                    onPressed: _saveExpense,

                    label: Text(
                      widget.expense == null ? 'Salva' : 'Salva modifiche',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
