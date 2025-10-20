import 'package:flutter/material.dart';
import 'package:budgeting/db/database.dart';
import 'package:budgeting/repositories/transaction_repository.dart';
import 'package:budgeting/viewmodels/home_view_model.dart';
import 'package:budgeting/viewmodels/summary_view_model.dart';
import 'package:budgeting/screens/main_navigation.dart';
import 'package:budgeting/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = DatabaseHelper.instance;
  final repo = TransactionRepository(db);

  // Check if onboarding is completed
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => HomeViewModel(repo)),
      ChangeNotifierProvider(create: (_) => SummaryViewModel(repo)),
    ],
    child: MyApp(showOnboarding: !onboardingCompleted),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MainNavigation(),
    );
  }
}