import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeting/providers/locale_provider.dart';
import 'package:budgeting/db/database.dart';
import 'package:budgeting/models/account.dart';
import 'package:budgeting/models/subscription.dart';
import 'package:budgeting/utils/currency_data.dart';
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
    final payingDateController = TextEditingController(
      text: subscription?.payingDate.toString() ?? '',
    );
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
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.subscriptionName,
                    hintText: l10n.subscriptionName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.subscriptionAmount,
                    hintText: '0.00',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
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
                TextField(
                  controller: payingDateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.subscriptionPayingDate,
                    hintText: '1-31',
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

                if (payingDateController.text.isEmpty) {
                  if (mounted && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(l10n.subscriptionPayingDate)),
                    );
                  }
                  return;
                }

                try {
                  final payingDate = int.parse(payingDateController.text);
                  if (payingDate < 1 || payingDate > 31) {
                    throw Exception('Day must be between 1 and 31');
                  }

                  final newSubscription = Subscription(
                    id: subscription?.id,
                    name: nameController.text,
                    amount: double.parse(amountController.text),
                    accountId: selectedAccountId!,
                    startDate: selectedStartDate!,
                    endDate: selectedEndDate,
                    payingDate: payingDate,
                  );

                  if (subscription == null) {
                    await _db.insertSubscription(newSubscription.toMap());
                  } else {
                    await _db.updateSubscription(subscription.id!, newSubscription.toMap());
                  }

                  await _loadSubscriptions();

                  if (mounted && dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          subscription == null
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
        subtitle: Text('${currency.symbol} ${currency.code}'),
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
                  await _db.insertAccount({
                    'name': nameController.text,
                    'currencyCode': selectedCurrency,
                    'balance': 0.0,
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
