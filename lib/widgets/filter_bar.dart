import 'package:flutter/material.dart';
import 'package:budgeting/models/filter_state.dart';
import 'package:budgeting/models/transaction.dart';
import 'package:budgeting/db/database.dart';
import 'package:budgeting/generated/app_localizations.dart';

class FilterBar extends StatelessWidget {
  final FilterState currentFilter;
  final Function(FilterState) onFilterChanged;
  final bool showCategoryFilter;
  final bool showPeriodFilter;

  const FilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    this.showCategoryFilter = true,
    this.showPeriodFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Currency/Account Filter + Period Filter
          Row(
            children: [
              // Currency/Account Filter (expandable dropdown)
              Expanded(
                child: _CurrencyAccountFilterDropdown(
                  currentFilter: currentFilter,
                  onFilterChanged: onFilterChanged,
                ),
              ),
              const SizedBox(width: 12),
              // Period Filter (expandable dropdown)
              if (showPeriodFilter)
                Expanded(
                  child: _PeriodFilterDropdown(
                    currentFilter: currentFilter,
                    onFilterChanged: onFilterChanged,
                  ),
                ),
            ],
          ),

          // Category Filter (multiple selection - horizontal scrollable)
          if (showCategoryFilter) ...[
            const SizedBox(height: 12),
            _CategoryMultiSelect(
              selectedCategories: currentFilter.categories,
              onCategoriesChanged: (categories) {
                onFilterChanged(currentFilter.copyWith(categories: categories));
              },
            ),
          ],
        ],
      ),
    );
  }
}

// Currency/Account Filter Dropdown
class _CurrencyAccountFilterDropdown extends StatelessWidget {
  final FilterState currentFilter;
  final Function(FilterState) onFilterChanged;

  const _CurrencyAccountFilterDropdown({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<({List<Map<String, dynamic>> currencies, List<Map<String, dynamic>> accounts})>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return OutlinedButton(
            onPressed: null,
            child: Text(l10n.loading),
          );
        }

        final currencies = snapshot.data!.currencies;
        final accounts = snapshot.data!.accounts;

        return OutlinedButton(
          onPressed: () => _showFilterMenu(context, currencies, accounts),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _getDisplayText(context),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        );
      },
    );
  }

  Future<({List<Map<String, dynamic>> currencies, List<Map<String, dynamic>> accounts})> _loadData() async {
    final db = await DatabaseHelper.instance.database;
    final currencies = await db.query('currencies');
    final accounts = await db.query('accounts');
    return (currencies: currencies, accounts: accounts);
  }

  String _getDisplayText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (currentFilter.mode == 'all') {
      return l10n.allAccounts;
    } else if (currentFilter.mode == 'currency') {
      return l10n.currencyLabel(currentFilter.currencyCode ?? '');
    } else if (currentFilter.mode == 'account') {
      return l10n.accountLabel(currentFilter.accountId ?? 0);
    }
    return l10n.allAccounts;
  }

  void _showFilterMenu(
    BuildContext context,
    List<Map<String, dynamic>> currencies,
    List<Map<String, dynamic>> accounts,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.selectAccountOrCurrency,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // All option
                    ListTile(
                      leading: const Icon(Icons.select_all),
                      title: Text(l10n.allAccounts),
                      selected: currentFilter.mode == 'all',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onFilterChanged(FilterState.all().copyWith(
                          categories: currentFilter.categories,
                          startDate: currentFilter.startDate,
                          endDate: currentFilter.endDate,
                        ));
                      },
                    ),

                    // Currencies section
                    if (currencies.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.currencies,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      ...currencies.map((currency) {
                        final code = currency['code'] as String;
                        return ListTile(
                          leading: const Icon(Icons.monetization_on),
                          title: Text(_getLocalizedCurrencyName(context, code)),
                          subtitle: Text(code),
                          selected: currentFilter.mode == 'currency' && currentFilter.currencyCode == code,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            onFilterChanged(FilterState.forCurrency(
                              code,
                              startDate: currentFilter.startDate,
                              endDate: currentFilter.endDate,
                              categories: currentFilter.categories,
                            ));
                          },
                        );
                      }),
                    ],

                    // Accounts section
                    if (accounts.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.accounts,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      ...accounts.map((account) {
                        final id = account['id'] as int;
                        return ListTile(
                          leading: const Icon(Icons.account_balance_wallet),
                          title: Text('${account['name']}'),
                          subtitle: Text(account['currencyCode'] as String),
                          selected: currentFilter.mode == 'account' && currentFilter.accountId == id,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            onFilterChanged(FilterState.forAccount(
                              id,
                              startDate: currentFilter.startDate,
                              endDate: currentFilter.endDate,
                              categories: currentFilter.categories,
                            ));
                          },
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedCurrencyName(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;

    switch (code) {
      case 'USD':
        return l10n.currency_USD;
      case 'EUR':
        return l10n.currency_EUR;
      case 'GBP':
        return l10n.currency_GBP;
      case 'JPY':
        return l10n.currency_JPY;
      case 'CNY':
        return l10n.currency_CNY;
      case 'KRW':
        return l10n.currency_KRW;
      case 'CAD':
        return l10n.currency_CAD;
      case 'AUD':
        return l10n.currency_AUD;
      case 'CHF':
        return l10n.currency_CHF;
      case 'HKD':
        return l10n.currency_HKD;
      case 'SGD':
        return l10n.currency_SGD;
      case 'NZD':
        return l10n.currency_NZD;
      default:
        return code;
    }
  }
}

// Period Filter Dropdown
class _PeriodFilterDropdown extends StatelessWidget {
  final FilterState currentFilter;
  final Function(FilterState) onFilterChanged;

  const _PeriodFilterDropdown({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _showPeriodMenu(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              _getDisplayText(context),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
    );
  }

  String _getDisplayText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (currentFilter.startDate == null) {
      return l10n.allTime;
    }

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthStartStr = monthStart.toString().substring(0, 10);

    if (currentFilter.startDate == monthStartStr) {
      return l10n.thisMonth;
    }

    final last3MonthsStart = DateTime(now.year, now.month - 2, 1);
    final last3MonthsStartStr = last3MonthsStart.toString().substring(0, 10);

    if (currentFilter.startDate == last3MonthsStartStr) {
      return l10n.lastThreeMonths;
    }

    return l10n.customRange;
  }

  void _showPeriodMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.selectPeriod,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),

            // All Time
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(l10n.allTime),
              selected: currentFilter.startDate == null,
              onTap: () {
                Navigator.of(ctx).pop();
                onFilterChanged(currentFilter.copyWith(clearRange: true));
              },
            ),

            // This Month
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.thisMonth),
              selected: _isCurrentMonth(),
              onTap: () {
                Navigator.of(ctx).pop();
                final now = DateTime.now();
                final start = DateTime(now.year, now.month, 1);
                final end = DateTime(now.year, now.month + 1, 0);
                onFilterChanged(currentFilter.copyWith(
                  startDate: start.toString().substring(0, 10),
                  endDate: end.toString().substring(0, 10),
                ));
              },
            ),

            // Last 3 Months
            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(l10n.lastThreeMonths),
              selected: _isLast3Months(),
              onTap: () {
                Navigator.of(ctx).pop();
                final now = DateTime.now();
                final start = DateTime(now.year, now.month - 2, 1);
                onFilterChanged(currentFilter.copyWith(
                  startDate: start.toString().substring(0, 10),
                  endDate: now.toString().substring(0, 10),
                ));
              },
            ),

            // Custom
            ListTile(
              leading: const Icon(Icons.edit_calendar),
              title: Text(l10n.customRange),
              onTap: () async {
                Navigator.of(ctx).pop();
                // Delay to ensure bottom sheet is closed before showing date picker
                await Future.delayed(const Duration(milliseconds: 300));

                if (context.mounted) {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: currentFilter.startDate != null
                        ? DateTimeRange(
                            start: DateTime.parse(currentFilter.startDate!),
                            end: DateTime.parse(currentFilter.endDate!),
                          )
                        : null,
                  );

                  if (picked != null && context.mounted) {
                    onFilterChanged(currentFilter.copyWith(
                      startDate: picked.start.toString().substring(0, 10),
                      endDate: picked.end.toString().substring(0, 10),
                    ));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _isCurrentMonth() {
    if (currentFilter.startDate == null) return false;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return currentFilter.startDate == start.toString().substring(0, 10);
  }

  bool _isLast3Months() {
    if (currentFilter.startDate == null) return false;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 2, 1);
    return currentFilter.startDate == start.toString().substring(0, 10);
  }
}

// Category Multi-Select (Horizontal Scrollable)
class _CategoryMultiSelect extends StatelessWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onCategoriesChanged;

  const _CategoryMultiSelect({
    required this.selectedCategories,
    required this.onCategoriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // "All" chip
          FilterChip(
            label: Text(l10n.allCategories),
            selected: selectedCategories.isEmpty,
            onSelected: (selected) {
              if (selected) {
                onCategoriesChanged([]);
              }
            },
          ),
          const SizedBox(width: 8),
          // Individual category chips
          ...Category.values.map((cat) {
            final isSelected = selectedCategories.contains(cat.name);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_getLocalizedCategoryName(context, cat.name)),
                selected: isSelected,
                onSelected: (selected) {
                  final newCategories = List<String>.from(selectedCategories);
                  if (selected) {
                    newCategories.add(cat.name);
                  } else {
                    newCategories.remove(cat.name);
                  }
                  onCategoriesChanged(newCategories);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getLocalizedCategoryName(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;

    switch (category) {
      case 'income':
        return l10n.income;
      case 'food':
        return l10n.food;
      case 'dining':
        return l10n.dining;
      case 'drinks':
        return l10n.drinks;
      case 'transportation':
        return l10n.transportation;
      case 'housing':
        return l10n.housing;
      case 'subscription':
        return l10n.subscription;
      case 'shopping':
        return l10n.shopping;
      case 'health':
        return l10n.health;
      case 'education':
        return l10n.education;
      case 'entertainment':
        return l10n.entertainment;
      case 'gifts':
        return l10n.gifts;
      case 'investment':
        return l10n.investment;
      case 'others':
        return l10n.others;
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }
}
