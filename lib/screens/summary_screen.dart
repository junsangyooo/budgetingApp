import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeting/viewmodels/summary_view_model.dart';
import 'package:budgeting/models/filter_state.dart';
import 'package:budgeting/widgets/monthly_chart.dart';
import 'package:budgeting/widgets/category_pie_chart.dart';
import 'package:budgeting/db/database.dart';
import 'package:budgeting/generated/app_localizations.dart';

String _getPeriodLabel(String period) {
  switch (period) {
    case '1day':
      return '1 Day';
    case '1week':
      return '1 Week';
    case '1month':
      return '1 Month';
    case '3months':
      return '3 Months';
    case '6months':
      return '6 Months';
    case '12months':
      return '12 Months';
    default:
      return '1 Month';
  }
}

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SummaryViewModel>(context, listen: false);

    // Load data when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.load();
    });

    return const SummaryScreenContent();
  }
}

class SummaryScreenContent extends StatefulWidget {
  const SummaryScreenContent({super.key});

  @override
  State<SummaryScreenContent> createState() => _SummaryScreenContentState();
}

class _SummaryScreenContentState extends State<SummaryScreenContent> {
  bool _showFilter = false;
  bool _showCategoryPeriodFilter = false;
  bool _showCategoryFilter = false;
  late List<Map<String, dynamic>> _currencies;
  late List<Map<String, dynamic>> _accounts;
  String _selectedPeriod = '1month';
  late Set<String> _selectedCategories;

  static const Map<String, dynamic> _categoryColors = {
    'food': 'Color',
    'dining': 'Color',
    'drinks': 'Color',
    'transportation': 'Color',
    'housing': 'Color',
    'subscription': 'Color',
    'shopping': 'Color',
    'health': 'Color',
    'education': 'Color',
    'entertainment': 'Color',
    'gifts': 'Color',
    'investment': 'Color',
    'others': 'Color',
  };

  @override
  void initState() {
    super.initState();
    _currencies = [];
    _accounts = [];
    _selectedCategories = {..._categoryColors.keys};
    _loadFilterData();
  }

  Future<void> _loadFilterData() async {
    final db = await DatabaseHelper.instance.database;
    final currencies = await db.query('currencies');
    final accounts = await db.query('accounts');

    if (mounted) {
      setState(() {
        _currencies = currencies;
        _accounts = accounts;
      });
    }
  }

  void _applyFilter(BuildContext context, String filter) {
    final viewModel = context.read<SummaryViewModel>();

    setState(() {
      _showFilter = false;
    });

    if (filter == 'all') {
      viewModel.updateFilter(FilterState.all().copyWith(
        startDate: viewModel.filter.startDate,
        endDate: viewModel.filter.endDate,
        categories: viewModel.filter.categories,
      ));
    } else if (filter.startsWith('account_')) {
      final accountId = int.parse(filter.split('_')[1]);
      viewModel.updateFilter(FilterState.forAccount(
        accountId,
        startDate: viewModel.filter.startDate,
        endDate: viewModel.filter.endDate,
        categories: viewModel.filter.categories,
      ));
    } else {
      // Currency code
      viewModel.updateFilter(FilterState.forCurrency(
        filter,
        startDate: viewModel.filter.startDate,
        endDate: viewModel.filter.endDate,
        categories: viewModel.filter.categories,
      ));
    }
  }

  String _getFilterDisplayName(BuildContext context) {
    final viewModel = context.read<SummaryViewModel>();
    final l10n = AppLocalizations.of(context)!;

    if (viewModel.filter.mode == 'all') {
      return l10n.allAccounts;
    } else if (viewModel.filter.mode == 'account') {
      final accountId = viewModel.filter.accountId;
      final account = _accounts.firstWhere(
        (a) => a['id'] == accountId,
        orElse: () => {'name': 'Unknown', 'currencyCode': ''},
      );
      return '${account['name']}';
    } else {
      // Currency code
      return viewModel.filter.currencyCode ?? 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SummaryViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: viewModel.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Overall Filter Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.filter,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  setState(() => _showFilter = !_showFilter),
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              label: Text(
                                _getFilterDisplayName(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),

                        if (_showFilter)
                          Column(
                            children: [
                              const SizedBox(height: 12),
                              ListTile(
                                leading: const Icon(Icons.select_all),
                                title: Text(l10n.allAccounts),
                                selected:
                                    viewModel.filter.mode == 'all',
                                onTap: () => _applyFilter(context, 'all'),
                              ),
                              if (_currencies.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      l10n.currencies,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                ..._currencies.map((currency) {
                                  final code = currency['code'] as String;
                                  return ListTile(
                                    leading: const Icon(Icons.monetization_on,
                                        size: 20),
                                    title: Text(code),
                                    selected: viewModel.filter.mode ==
                                            'currency' &&
                                        viewModel.filter.currencyCode == code,
                                    onTap: () => _applyFilter(context, code),
                                  );
                                }),
                              ],
                              if (_accounts.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      l10n.accounts,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                ..._accounts.map((account) {
                                  final id = account['id'] as int;
                                  return ListTile(
                                    leading:
                                        const Icon(Icons.account_balance_wallet,
                                            size: 20),
                                    title: Text('${account['name']}'),
                                    subtitle: Text(
                                        account['currencyCode'] as String),
                                    selected: viewModel.filter.mode ==
                                            'account' &&
                                        viewModel.filter.accountId == id,
                                    onTap: () =>
                                        _applyFilter(context, 'account_$id'),
                                  );
                                }),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Monthly Net Stats Section
                  MonthlyChart(
                    viewModel: viewModel,
                  ),
                  const SizedBox(height: 24),

                  // Category Breakdown Filters
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              setState(() => _showCategoryPeriodFilter = !_showCategoryPeriodFilter),
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _getPeriodLabel(_selectedPeriod),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => setState(
                              () => _showCategoryFilter = !_showCategoryFilter),
                          icon: const Icon(Icons.filter_list, size: 16),
                          label: Text(
                            '${_selectedCategories.length}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Period Filter Dropdown
                  if (_showCategoryPeriodFilter)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildPeriodOption(context, '1day', '1 Day'),
                          _buildPeriodOption(context, '1week', '1 Week'),
                          _buildPeriodOption(context, '1month', '1 Month'),
                          _buildPeriodOption(context, '3months', '3 Months'),
                          _buildPeriodOption(context, '6months', '6 Months'),
                          _buildPeriodOption(context, '12months', '12 Months'),
                        ],
                      ),
                    ),

                  // Category Filter Dropdown
                  if (_showCategoryFilter)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categoryColors.keys.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          return FilterChip(
                            label: Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            selected: isSelected,
                            backgroundColor: Colors.grey[200],
                            selectedColor: Colors.blue,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCategories.add(category);
                                } else {
                                  _selectedCategories.remove(category);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Category Breakdown Section
                  CategoryPieChart(
                    viewModel: viewModel,
                    selectedPeriod: _selectedPeriod,
                    selectedCategories: _selectedCategories,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodOption(
    BuildContext context,
    String periodKey,
    String periodLabel,
  ) {
    return ListTile(
      title: Text(periodLabel),
      selected: _selectedPeriod == periodKey,
      onTap: () {
        setState(() {
          _selectedPeriod = periodKey;
          _showCategoryPeriodFilter = false;
        });
      },
    );
  }
}
