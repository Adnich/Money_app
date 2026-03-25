import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/transaction_model.dart';
import 'models/loan_decision_model.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'blocs/transaction/transaction_event.dart';
import 'screens/transactions_screen.dart';
import 'blocs/loan/loan_bloc.dart';
import 'services/loan_decision_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(LoanDecisionModelAdapter());

  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<LoanDecisionModel>('loan');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc()..add(LoadTransactions()),
        ),
        BlocProvider<LoanBloc>(
          create: (context) => LoanBloc(
            transactionBloc: context.read<TransactionBloc>(),
            service: LoanDecisionService(),
            loanBox: Hive.box<LoanDecisionModel>('loan'),
            txBox: Hive.box<TransactionModel>('transactions'),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoneyApp',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const TransactionsScreen(),
    );
  }
}
