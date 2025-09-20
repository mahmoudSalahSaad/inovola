import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/storage_service.dart';
import 'services/currency_service.dart';
import 'repositories/expense_repository.dart';
import 'repositories/user_repository.dart';
import 'blocs/user/user_bloc.dart';
import 'blocs/expense/expense_bloc.dart';
import 'blocs/currency/currency_bloc.dart';
import 'screens/dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Hive
  await StorageService.initialize();
  
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ExpenseRepository>(
          create: (context) => ExpenseRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(),
        ),
        RepositoryProvider<CurrencyService>(
          create: (context) => CurrencyService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>(
            create: (context) => UserBloc(
              userRepository: context.read<UserRepository>(),
            ),
          ),
          BlocProvider<ExpenseBloc>(
            create: (context) => ExpenseBloc(
              expenseRepository: context.read<ExpenseRepository>(),
              userRepository: context.read<UserRepository>(),
              currencyService: context.read<CurrencyService>(),
            ),
          ),
          BlocProvider<CurrencyBloc>(
            create: (context) => CurrencyBloc(
              currencyService: context.read<CurrencyService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Expenser',
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
