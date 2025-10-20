import 'package:flutter/material.dart';
import 'package:budgeting/models/filter_state.dart';
import 'package:budgeting/models/transaction.dart';

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
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Mode (All, Currency, Account)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: currentFilter.mode == 'all',
                  onSelected: (selected) {
                    if (selected) {
                      onFilterChanged(FilterState.all());
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('By Currency'),
                  selected: currentFilter.mode == 'currency',
                  onSelected: (selected) {
                    if (selected) {
                      _showCurrencyPicker(context);
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('By Account'),
                  selected: currentFilter.mode == 'account',
                  onSelected: (selected) {
                    if (selected) {
                      _showAccountPicker(context);
                    }
                  },
                ),
              ],
            ),
          ),
          
          if (currentFilter.mode == 'currency' && currentFilter.currencyCode != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Chip(
                label: Text('Currency: ${currentFilter.currencyCode}'),
                onDeleted: () => onFilterChanged(FilterState.all()),
              ),
            ),
            
          if (currentFilter.mode == 'account' && currentFilter.accountId != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Chip(
                label: Text('Account ID: ${currentFilter.accountId}'),
                onDeleted: () => onFilterChanged(FilterState.all()),
              ),
            ),

          // Category Filter
          if (showCategoryFilter) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Categories'),
                    selected: currentFilter.category == null,
                    onSelected: (selected) {
                      if (selected) {
                        onFilterChanged(currentFilter.copyWith(clearCategory: true));
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ...Category.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_formatCategoryName(cat.name)),
                          selected: currentFilter.category == cat.name,
                          onSelected: (selected) {
                            onFilterChanged(
                              currentFilter.copyWith(
                                category: selected ? cat.name : null,
                                clearCategory: !selected,
                              ),
                            );
                          },
                        ),
                      )),
                ],
              ),
            ),
          ],

          // Period Filter
          if (showPeriodFilter) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Time'),
                    selected: currentFilter.startDate == null,
                    onSelected: (selected) {
                      if (selected) {
                        onFilterChanged(currentFilter.copyWith(clearRange: true));
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('This Month'),
                    selected: _isCurrentMonth(),
                    onSelected: (selected) {
                      if (selected) {
                        final now = DateTime.now();
                        final start = DateTime(now.year, now.month, 1);
                        final end = DateTime(now.year, now.month + 1, 0);
                        onFilterChanged(currentFilter.copyWith(
                          startDate: start.toString().substring(0, 10),
                          endDate: end.toString().substring(0, 10),
                        ));
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Last 3 Months'),
                    selected: _isLast3Months(),
                    onSelected: (selected) {
                      if (selected) {
                        final now = DateTime.now();
                        final start = DateTime(now.year, now.month - 2, 1);
                        onFilterChanged(currentFilter.copyWith(
                          startDate: start.toString().substring(0, 10),
                          endDate: now.toString().substring(0, 10),
                        ));
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Custom'),
                    selected: currentFilter.startDate != null && 
                              !_isCurrentMonth() && 
                              !_isLast3Months(),
                    onSelected: (selected) {
                      if (selected) {
                        _showDateRangePicker(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
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

  void _showCurrencyPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('USD - US Dollar'),
              onTap: () {
                Navigator.of(ctx).pop();
                onFilterChanged(FilterState.forCurrency('USD'));
              },
            ),
            ListTile(
              title: const Text('CAD - Canadian Dollar'),
              onTap: () {
                Navigator.of(ctx).pop();
                onFilterChanged(FilterState.forCurrency('CAD'));
              },
            ),
            ListTile(
              title: const Text('KRW - Korean Won'),
              onTap: () {
                Navigator.of(ctx).pop();
                onFilterChanged(FilterState.forCurrency('KRW'));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('TD Chequing (CAD)'),
              onTap: () {
                Navigator.of(ctx).pop();
                onFilterChanged(FilterState.forAccount(1));
              },
            ),
            ListTile(
              title: const Text('Chase Checking (USD)'),
              onTap: () {
                Navigator.of(ctx).pop();
                onFilterChanged(FilterState.forAccount(2));
              },
            ),
            ListTile(
              title: const Text('하나은행 통장 (KRW)'),
              onTap: () {
                Navigator.of(ctx).pop();
                onFilterChanged(FilterState.forAccount(3));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
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

    if (picked != null) {
      onFilterChanged(currentFilter.copyWith(
        startDate: picked.start.toString().substring(0, 10),
        endDate: picked.end.toString().substring(0, 10),
      ));
    }
  }

  String _formatCategoryName(String category) {
    return category[0].toUpperCase() + category.substring(1);
  }
}
