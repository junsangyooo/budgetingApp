// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle => 'Welcome to Budget Tracker';

  @override
  String get chooseLanguage => 'Choose your preferred language';

  @override
  String get confirm => 'Confirm';

  @override
  String get createFirstAccount => 'Create Your First Account';

  @override
  String get setupAccountDesc => 'Set up at least one account to get started';

  @override
  String get accountName => 'Account Name';

  @override
  String get accountNameHint => 'e.g., My Checking Account';

  @override
  String get currency => 'Currency';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get finishSetup => 'Finish Setup';

  @override
  String get youCanAddMore =>
      'You can add more currencies and accounts later in Settings';

  @override
  String get english => 'English';

  @override
  String get korean => '한국어';

  @override
  String get defaultCurrencyUSD => 'Default currency: USD';

  @override
  String get defaultCurrencyKRW => 'Default currency: KRW';

  @override
  String get pleaseSelectLanguage => 'Please select a language';

  @override
  String get pleaseEnterAccountName => 'Please enter an account name';

  @override
  String get pleaseEnterBalance => 'Please enter initial balance';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String errorOccurred(String error) {
    return 'Error: $error';
  }

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get searchCurrency => 'Search currency...';
}
