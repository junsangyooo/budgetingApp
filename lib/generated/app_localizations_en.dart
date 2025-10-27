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
  String get filter => 'Filter';

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

  @override
  String get currency_USD => 'US Dollar';

  @override
  String get currency_EUR => 'Euro';

  @override
  String get currency_GBP => 'British Pound';

  @override
  String get currency_JPY => 'Japanese Yen';

  @override
  String get currency_CNY => 'Chinese Yuan';

  @override
  String get currency_KRW => 'Korean Won';

  @override
  String get currency_CAD => 'Canadian Dollar';

  @override
  String get currency_AUD => 'Australian Dollar';

  @override
  String get currency_CHF => 'Swiss Franc';

  @override
  String get currency_HKD => 'Hong Kong Dollar';

  @override
  String get currency_SGD => 'Singapore Dollar';

  @override
  String get currency_NZD => 'New Zealand Dollar';

  @override
  String get navHome => 'Home';

  @override
  String get navSummary => 'Summary';

  @override
  String get navSettings => 'Settings';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get addSubscription => 'Add Subscription';

  @override
  String get subscriptionName => 'Subscription Name';

  @override
  String get subscriptionAmount => 'Amount';

  @override
  String get subscriptionAccount => 'Account';

  @override
  String get subscriptionStartDate => 'Start Date';

  @override
  String get subscriptionEndDate => 'End Date (Optional)';

  @override
  String get subscriptionPayingDate => 'Day of Month';

  @override
  String get subscriptionFrequency => 'Frequency';

  @override
  String get deleteSubscription => 'Delete Subscription';

  @override
  String deleteSubscriptionConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get subscriptionAdded => 'Subscription added successfully';

  @override
  String get subscriptionUpdated => 'Subscription updated successfully';

  @override
  String get subscriptionDeleted => 'Subscription deleted successfully';

  @override
  String get noSubscriptions => 'No Subscriptions';

  @override
  String get monthly => 'Monthly';

  @override
  String get pleaseEnterSubscriptionName => 'Please enter a subscription name';

  @override
  String get pleaseEnterSubscriptionAmount =>
      'Please enter a subscription amount';

  @override
  String get pleaseSelectSubscriptionAccount => 'Please select an account';

  @override
  String get categories => 'Categories';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get newAccountTitle => 'New Account';

  @override
  String get addNewAccount => 'Add New Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String deleteAccountConfirm(String name) {
    return 'Are you sure you want to delete account \"$name\"? All associated transactions will be deleted.';
  }

  @override
  String get accountDeleted => 'Account deleted successfully';

  @override
  String get accountAdded => 'Account added successfully';

  @override
  String get categoryAdded => 'Category added successfully';

  @override
  String get categoryDeleted => 'Category deleted successfully';

  @override
  String get pleaseEnterCategoryName => 'Please enter a category name';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get categoryUpdated => 'Category updated successfully';

  @override
  String get summary => 'Summary';

  @override
  String get monthlyNetStats => 'Monthly Net Stats';

  @override
  String get categoryBreakdown => 'Category Breakdown';

  @override
  String get selectCategories => 'Select Categories';

  @override
  String get selectAccountOrCurrencyForChart => 'Select Account or Currency';

  @override
  String get noData => 'No data available';

  @override
  String get all => 'All';

  @override
  String get subscriptionFrequencyMonthly => 'Monthly';

  @override
  String get subscriptionFrequencyYearly => 'Yearly';

  @override
  String get subscriptionFrequencyCustom => 'Custom';

  @override
  String get subscriptionCustomInterval => 'Every (months)';

  @override
  String get subscriptionInfoMessage =>
      'To manage subscription payments, please use Settings → Subscriptions';
}
