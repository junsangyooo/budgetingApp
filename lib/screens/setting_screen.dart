import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:budgeting/providers/locale_provider.dart';
import 'package:budgeting/db/database.dart';
import 'package:budgeting/models/account.dart';
import 'package:budgeting/models/subscription.dart';
import 'package:budgeting/utils/currency_data.dart';
import 'package:budgeting/viewmodels/home_view_model.dart';
import 'package:budgeting/viewmodels/summary_view_model.dart';
import 'package:budgeting/generated/app_localizations.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Account> _accounts;
  late List<Subscription> _subscriptions;
  final DatabaseHelper _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _subscriptions = [];
    _loadAccounts();
    _loadSubscriptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final accountMaps = await _db.getAllAccounts();
    setState(() {
      _accounts = accountMaps.map((map) => Account.fromMap(map)).toList();
    });
  }

  Future<void> _loadSubscriptions() async {
    final subscriptionMaps = await _db.getAllSubscriptions();
    setState(() {
      _subscriptions = subscriptionMaps.map((map) => Subscription.fromMap(map)).toList();
    });
  }

  /// Generate a human-readable frequency description for a subscription
  String _getFrequencyDescription(String frequency) {
    if (frequency == 'monthly') {
      return 'month';
    } else if (frequency == 'yearly') {
      return 'year';
    } else if (frequency.startsWith('custom:')) {
      final months = frequency.split(':')[1];
      return '$months months';
    }
    return 'month';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.subscriptions),
            Tab(text: l10n.accounts),
            Tab(text: l10n.language),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubscriptionsTab(context, l10n),
          _buildAccountsTab(context, l10n),
          _buildLanguageTab(context, l10n),
        ],
      ),
    );
  }

  // ==================== Language Tab ====================
  Widget _buildLanguageTab(BuildContext context, AppLocalizations l10n) {
    final localeProvider = context.read<LocaleProvider>();
    final currentLocale = localeProvider.locale.languageCode;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.selectLanguage,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        _buildLanguageOption(
          context,
          localeProvider,
          'en',
          l10n.english,
          currentLocale == 'en',
        ),
        _buildLanguageOption(
          context,
          localeProvider,
          'ko',
          l10n.korean,
          currentLocale == 'ko',
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    LocaleProvider localeProvider,
    String code,
    String label,
    bool isSelected,
  ) {
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.circle_outlined),
      onTap: isSelected
          ? null
          : () async {
              await localeProvider.setLocale(code);
              if (mounted) {
                final l10nLocal = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${l10nLocal.language} changed to $label')),
                );
              }
            },
    );
  }

  // ==================== Subscriptions Tab ====================
  Widget _buildSubscriptionsTab(BuildContext context, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _loadSubscriptions,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.subscriptions,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                FloatingActionButton.small(
                  onPressed: () => _showAddSubscriptionDialog(context, l10n),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          if (_subscriptions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  l10n.noSubscriptions,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          else
            ..._subscriptions.map((subscription) {
              return _buildSubscriptionTile(context, l10n, subscription);
            }),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTile(
    BuildContext context,
    AppLocalizations l10n,
    Subscription subscription,
  ) {
    final account = _accounts.firstWhere(
      (a) => a.id == subscription.accountId,
      orElse: () => Account(name: 'Unknown', currencyCode: ''),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(subscription.name),
        subtitle: Text('${account.name} • \$${subscription.amount.toStringAsFixed(2)}'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => _showEditSubscriptionDialog(context, l10n, subscription),
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.editCategory),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => _showDeleteSubscriptionDialog(context, l10n, subscription),
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    l10n.deleteSubscription,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubscriptionDialog(BuildContext context, AppLocalizations l10n) {
    _showSubscriptionDialog(context, l10n, null);
  }

  void _showEditSubscriptionDialog(
    BuildContext context,
    AppLocalizations l10n,
    Subscription subscription,
  ) {
    _showSubscriptionDialog(context, l10n, subscription);
  }

  void _showSubscriptionDialog(
    BuildContext context,
    AppLocalizations l10n,
    Subscription? subscription,
  ) {
    final nameController = TextEditingController(text: subscription?.name ?? '');
    final amountController = TextEditingController(
      text: subscription?.amount.toString() ?? '',
    );

    // Parse frequency from subscription or use default
    String selectedFrequency = 'monthly';
    int customInterval = 3;

    if (subscription != null) {
      final freq = subscription.frequency;
      if (freq.startsWith('custom:')) {
        selectedFrequency = 'custom';
        customInterval = int.tryParse(freq.split(':')[1]) ?? 3;
      } else {
        selectedFrequency = freq;
      }
    }

    DateTime? selectedStartDate = subscription?.startDate ?? DateTime.now();
    DateTime? selectedEndDate = subscription?.endDate;
    int? selectedAccountId = subscription?.accountId;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(
            subscription == null ? l10n.addSubscription : l10n.editCategory,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Subscription Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.subscriptionName,
                    hintText: l10n.subscriptionName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Amount (numeric only)
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.subscriptionAmount,
                    hintText: '0.00',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Account Selection
                DropdownButtonFormField<int>(
                  initialValue: selectedAccountId,
                  decoration: InputDecoration(
                    labelText: l10n.subscriptionAccount,
                    border: const OutlineInputBorder(),
                  ),
                  items: _accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.name} (${account.currencyCode})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAccountId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Start Date Picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedStartDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedStartDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.subscriptionStartDate,
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      selectedStartDate != null
                          ? '${selectedStartDate!.year}-${selectedStartDate!.month.toString().padLeft(2, '0')}-${selectedStartDate!.day.toString().padLeft(2, '0')}'
                          : 'Select date',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Frequency Selection
                DropdownButtonFormField<String>(
                  initialValue: selectedFrequency,
                  decoration: InputDecoration(
                    labelText: l10n.subscriptionFrequency,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'monthly',
                      child: Text(l10n.subscriptionFrequencyMonthly),
                    ),
                    DropdownMenuItem(
                      value: 'yearly',
                      child: Text(l10n.subscriptionFrequencyYearly),
                    ),
                    DropdownMenuItem(
                      value: 'custom',
                      child: Text(l10n.subscriptionFrequencyCustom),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedFrequency = value ?? 'monthly';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Custom Interval Input (only if Custom is selected)
                if (selectedFrequency == 'custom')
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    controller: TextEditingController(text: customInterval.toString()),
                    decoration: InputDecoration(
                      labelText: l10n.subscriptionCustomInterval,
                      hintText: '3',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      customInterval = int.tryParse(value) ?? 3;
                    },
                  ),

                if (selectedFrequency == 'custom')
                  const SizedBox(height: 16),

                // End Date Picker (Optional)
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedEndDate ?? selectedStartDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedEndDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.subscriptionEndDate,
                      border: const OutlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (selectedEndDate != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedEndDate = null;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.clear, size: 20),
                              ),
                            ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.calendar_today),
                          ),
                        ],
                      ),
                    ),
                    child: Text(
                      selectedEndDate != null
                          ? '${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}'
                          : 'Optional',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  if (mounted && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(l10n.pleaseEnterSubscriptionName)),
                    );
                  }
                  return;
                }

                if (amountController.text.isEmpty) {
                  if (mounted && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(l10n.pleaseEnterSubscriptionAmount)),
                    );
                  }
                  return;
                }

                if (selectedAccountId == null) {
                  if (mounted && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(l10n.pleaseSelectSubscriptionAccount)),
                    );
                  }
                  return;
                }

                try {
                  // Build frequency string
                  String frequencyString = selectedFrequency;
                  if (selectedFrequency == 'custom') {
                    if (customInterval < 1) {
                      throw Exception('Custom interval must be at least 1 month');
                    }
                    frequencyString = 'custom:$customInterval';
                  }

                  // For monthly subscriptions, use day of start date
                  int payingDate = selectedStartDate!.day;

                  final newSubscription = Subscription(
                    id: subscription?.id,
                    name: nameController.text,
                    amount: double.parse(amountController.text),
                    accountId: selectedAccountId!,
                    startDate: selectedStartDate!,
                    endDate: selectedEndDate,
                    frequency: frequencyString,
                    payingDate: payingDate,
                  );

                  final isNewSubscription = subscription == null;

                  if (isNewSubscription) {
                    await _db.insertSubscription(newSubscription.toMap());

                    // Create initial transaction on start date
                    await _createInitialSubscriptionTransaction(newSubscription);
                  } else {
                    await _db.updateSubscription(subscription.id!, newSubscription.toMap());
                  }

                  await _loadSubscriptions();

                  // Refresh home and summary screens if this is a new subscription
                  if (isNewSubscription && mounted && dialogContext.mounted) {
                    try {
                      final homeViewModel = dialogContext.read<HomeViewModel>();
                      await homeViewModel.load();
                    } catch (e) {
                      // HomeViewModel might not be available in context
                    }
                    try {
                      final summaryViewModel = dialogContext.read<SummaryViewModel>();
                      await summaryViewModel.load();
                    } catch (e) {
                      // SummaryViewModel might not be available in context
                    }
                  }

                  if (mounted && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          isNewSubscription
                              ? l10n.subscriptionAdded
                              : l10n.subscriptionUpdated,
                        ),
                      ),
                    );

                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  if (mounted && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(l10n.errorOccurred(e.toString())),
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  /// Create an initial transaction for a new subscription on its start date
  Future<void> _createInitialSubscriptionTransaction(Subscription subscription) async {
    try {
      final frequencyDesc = _getFrequencyDescription(subscription.frequency);
      final transactionDate = subscription.startDate.toString().substring(0, 10);
      final transactionData = {
        'id': const Uuid().v4(),
        'title': 'Subscription: ${subscription.name}',
        'amount': subscription.amount,
        'type': 0, // 0 = expense
        'date': transactionDate,
        'accountId': subscription.accountId,
        'category': 'subscription',
        'note': 'Subscription: ${subscription.name}\nPayment: Every $frequencyDesc',
        'recurring': null,
      };

      await _db.insertTransaction(transactionData);

      // Set lastCreatedDate to prevent SubscriptionService from creating duplicate
      // transaction on the same date
      if (subscription.id != null) {
        await _db.updateSubscriptionLastCreatedDate(subscription.id!, transactionDate);
      }
    } catch (e) {
      print('Error creating initial subscription transaction: $e');
    }
  }

  void _showDeleteSubscriptionDialog(
    BuildContext context,
    AppLocalizations l10n,
    Subscription subscription,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteSubscription),
        content: Text(
          l10n.deleteSubscriptionConfirm(subscription.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _db.deleteSubscription(subscription.id!);
                await _loadSubscriptions();

                if (mounted && dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(l10n.subscriptionDeleted)),
                  );

                  Navigator.pop(dialogContext);
                }
              } catch (e) {
                if (mounted && dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorOccurred(e.toString())),
                    ),
                  );

                  Navigator.pop(dialogContext);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  // ==================== Accounts Tab ====================
  Widget _buildAccountsTab(BuildContext context, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _loadAccounts,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.accounts,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                FloatingActionButton.small(
                  onPressed: () => _showAddAccountDialog(context, l10n),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          if (_accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  l10n.noAccounts,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          else
            ..._accounts.map((account) {
              return _buildAccountTile(context, l10n, account);
            }),
        ],
      ),
    );
  }

  Widget _buildAccountTile(
    BuildContext context,
    AppLocalizations l10n,
    Account account,
  ) {
    final currency =
        CurrencyData.getCurrency(account.currencyCode) ??
        (throw 'Currency not found');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(account.name),
        subtitle: Text(
          '${currency.symbol} ${currency.code} • Balance: ${currency.symbol}${account.balance.toStringAsFixed(2)}',
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () =>
                  _showDeleteAccountDialog(context, l10n, account),
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    l10n.deleteAccount,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, AppLocalizations l10n) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String? selectedCurrency;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(l10n.newAccountTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.accountName,
                    hintText: l10n.accountNameHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedCurrency,
                  decoration: InputDecoration(
                    labelText: l10n.currency,
                    border: const OutlineInputBorder(),
                  ),
                  items: CurrencyData.allCurrencies.map((currency) {
                    return DropdownMenuItem(
                      value: currency.code,
                      child: Text('${currency.code} - ${currency.name}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCurrency = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.initialBalance,
                    hintText: '0.00',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  if (mounted && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(l10n.pleaseEnterAccountName)),
                    );
                  }
                  return;
                }

                if (selectedCurrency == null) {
                  if (mounted && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(l10n.pleaseSelectAccount)),
                    );
                  }
                  return;
                }

                // Add currency if not exists
                try {
                  final currencyExists =
                      await _db.currencyExists(selectedCurrency!);
                  if (!currencyExists) {
                    final currency =
                        CurrencyData.getCurrency(selectedCurrency!)!;
                    await _db.insertCurrency({
                      'code': currency.code,
                      'symbol': currency.symbol,
                      'name': currency.name,
                    });
                  }
                } catch (e) {
                  // Currency might already exist
                }

                // Add account
                try {
                  double balance = 0.0;
                  if (balanceController.text.isNotEmpty) {
                    balance = double.parse(balanceController.text);
                  }

                  await _db.insertAccount({
                    'name': nameController.text,
                    'currencyCode': selectedCurrency,
                    'balance': balance,
                  });

                  await _loadAccounts();

                  if (mounted && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(l10n.accountAdded)),
                    );

                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  if (mounted && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(l10n.errorOccurred(e.toString())),
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    AppLocalizations l10n,
    Account account,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(
          l10n.deleteAccountConfirm(account.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _db.deleteAccount(account.id!);
                await _loadAccounts();

                if (mounted && dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(l10n.accountDeleted)),
                  );

                  Navigator.pop(dialogContext);
                }
              } catch (e) {
                if (mounted && dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorOccurred(e.toString())),
                    ),
                  );

                  Navigator.pop(dialogContext);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
