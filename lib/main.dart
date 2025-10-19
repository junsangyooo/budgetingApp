import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeting/db/database.dart';
import 'package:budgeting/repositories/transaction_repository.dart';
import 'package:budgeting/viewmodels/home_view_model.dart';
import 'package:budgeting/viewmodels/summary_view_model.dart';
import 'package:budgeting/screens/home_screen.dart';
import 'package:budgeting/screens/summary_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final db = DatabaseHelper.instance;
  final repo = TransactionRepository(db);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => HomeViewModel(repo)),
      ChangeNotifierProvider(create: (_) => SummaryViewModel(repo)),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(), // 네가 만든 화면
      routes: {
        '/summary': (_) => const SummaryScreen(),
      },
    );
  }
}
