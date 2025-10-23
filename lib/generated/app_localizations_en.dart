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

  @override
  String get transactions => 'Transactions';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get allAccounts => 'All Accounts';

  @override
  String get allTime => 'All Time';

  @override
  String get allCategories => 'All Categories';

  @override
  String get selectAccountOrCurrency => 'Select Account or Currency';

  @override
  String get currencies => 'Currencies';

  @override
  String get accounts => 'Accounts';

  @override
  String get selectPeriod => 'Select Period';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastThreeMonths => 'Last 3 Months';

  @override
  String get customRange => 'Custom Range';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get balance => 'Balance';

  @override
  String get food => 'Food';

  @override
  String get dining => 'Dining';

  @override
  String get drinks => 'Drinks';

  @override
  String get transportation => 'Transportation';

  @override
  String get housing => 'Housing';

  @override
  String get subscription => 'Subscription';

  @override
  String get shopping => 'Shopping';

  @override
  String get health => 'Health';

  @override
  String get education => 'Education';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get gifts => 'Gifts';

  @override
  String get investment => 'Investment';

  @override
  String get others => 'Others';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String deleteConfirmation(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get title => 'Title';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get account => 'Account';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note (Optional)';

  @override
  String get save => 'Save';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseSelectAccount => 'Please select an account';

  @override
  String get transactionAdded => 'Transaction added';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get noAccounts => 'No Accounts';

  @override
  String get createAccountFirst =>
      'Please create an account first before adding transactions.';

  @override
  String get ok => 'OK';

  @override
  String get loading => 'Loading...';

  @override
  String currencyLabel(String code) {
    return 'Currency: $code';
  }

  @override
  String accountLabel(int id) {
    return 'Account: #$id';
  }
}
