import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:aullet/views/signup_view.dart';
import 'package:aullet/views/new_expenses_page.dart';
import 'package:aullet/views/new_income_page.dart';
import 'package:aullet/views/login_view.dart';
import 'package:aullet/views/dashboard_view.dart';
import 'package:aullet/views/home_view.dart';
import 'package:aullet/views/profile_view.dart';
import 'package:aullet/views/statistic_page.dart';

import 'package:aullet/viewmodel/auth_view_model.dart';
import 'package:aullet/viewmodel/profile_viewmodel.dart';
import 'package:aullet/viewmodel/expense_viewmodel.dart';
import 'package:aullet/viewmodel/income_viewmodel.dart';
import 'package:aullet/viewmodel/statistic_viewmodel.dart';
import 'package:aullet/viewmodel/category_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Variabili per URL del database e chiave
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception(
      'SUPABASE_URL o SUPABASE_PUBLISHABLE_KEY mancanti nel file .env',
    );
  }

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => ExpenseViewModel()),
        ChangeNotifierProvider(create: (_) => StatisticViewModel()),
        ChangeNotifierProvider(create: (_) => IncomeViewModel()),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, vm, child) {
          return MaterialApp(
            title: 'Aullet',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(textTheme: GoogleFonts.dmSansTextTheme()),
            // Imposta la home in base allo stato di login dell'utente
            home: vm.isLoggedIn ? const DashboardView() : const HomeView(),
            routes: {
              '/signup': (_) => const SignUpView(),
              '/login': (_) => const LoginView(),
              '/home': (_) => const HomeView(),
              '/profile': (_) => const ProfileView(),
              '/dashboard': (_) => const DashboardView(),
              '/newexpense': (_) => const NewExpensesPage(),
              '/statistic': (_) => const StatisticPage(),
              '/newincome': (_) => const NewIncomePage(),
            },
          );
        },
      ),
    );
  }
}
