import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:budgeting/db/database.dart';
import 'package:budgeting/repositories/transaction_repository.dart';
import 'package:budgeting/viewmodels/home_view_model.dart';
import 'package:budgeting/viewmodels/summary_view_model.dart';
import 'package:budgeting/providers/locale_provider.dart';
import 'package:budgeting/screens/main_navigation.dart';
import 'package:budgeting/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgeting/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = DatabaseHelper.instance;
  final repo = TransactionRepository(db);

  // Check if onboarding is complete
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => HomeViewModel(repo)),
        ChangeNotifierProvider(create: (_) => SummaryViewModel(repo)),
      ],
      child: MyApp(showOnboarding: !onboardingComplete),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Budget Tracker',
          
          // 다국어 설정
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ko'), // Korean
          ],
          
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          
          home: showOnboarding ? const OnboardingScreen() : const MainNavigation(),
        );
      },
    );
  }
}