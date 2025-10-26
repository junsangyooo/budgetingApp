import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budgeting/viewmodels/summary_view_model.dart';
import 'package:budgeting/generated/app_localizations.dart';

class CategoryPieChart extends StatefulWidget {
  final SummaryViewModel viewModel;
  final String selectedPeriod;
  final Set<String> selectedCategories;

  const CategoryPieChart({
    super.key,
    required this.viewModel,
    this.selectedPeriod = '1month',
    required this.selectedCategories,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  @override
  void initState() {
    super.initState();
    _loadDataForPeriod();
  }

  void _loadDataForPeriod() {
    final now = DateTime.now();
    late String startDate;
    final endDate = now.toString().substring(0, 10);

    switch (widget.selectedPeriod) {
      case '1day':
        startDate = now.toString().substring(0, 10);
        break;
      case '1week':
        final weekAgo = now.subtract(const Duration(days: 7));
        startDate = weekAgo.toString().substring(0, 10);
        break;
      case '1month':
        final monthStart = DateTime(now.year, now.month, 1);
        startDate = monthStart.toString().substring(0, 10);
        break;
      case '3months':
        final threeMonthsAgo = DateTime(now.year, now.month - 2, 1);
        startDate = threeMonthsAgo.toString().substring(0, 10);
        break;
      case '6months':
        final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
        startDate = sixMonthsAgo.toString().substring(0, 10);
        break;
      case '12months':
        final yearAgo = DateTime(now.year - 1, now.month, 1);
        startDate = yearAgo.toString().substring(0, 10);
        break;
    }

    widget.viewModel.loadCategoryTotalsForMonth(
      monthStart: startDate,
      monthEnd: endDate,
    );
  }

  @override
  void didUpdateWidget(CategoryPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      _loadDataForPeriod();
    }
  }

  static const Map<String, Color> _categoryColors = {
    'food': Color(0xFFFF6B6B),
    'dining': Color(0xFFFF8C8C),
    'drinks': Color(0xFFFFB3B3),
    'transportation': Color(0xFF4ECDC4),
    'housing': Color(0xFF45B7D1),
    'subscription': Color(0xFF96CEB4),
    'shopping': Color(0xFFFFA07A),
    'health': Color(0xFF98D8C8),
    'education': Color(0xFF6C5CE7),
    'entertainment': Color(0xFFA29BFE),
    'gifts': Color(0xFFFF6B9D),
    'investment': Color(0xFF54A0FF),
    'others': Color(0xFFCCCCCC),
  };

  String _getLocalizedCategoryName(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;

    switch (category) {
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
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // Prepare pie chart data (only selected categories)
    final categoryForMonth = widget.viewModel.categoryForMonth;
    final filteredData = categoryForMonth
        .where(
          (item) {
            final category = item['category'] as String;
            final expense = (item['expense'] as num?) ?? 0;
            return widget.selectedCategories.contains(category) && (expense > 0);
          },
        )
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              l10n.categoryBreakdown,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // Chart
          Padding(
            padding: const EdgeInsets.all(16),
            child: filteredData.isEmpty
                ? SizedBox(
                    height: 250,
                    child: Center(
                      child: Text(l10n.noData),
                    ),
                  )
                : SizedBox(
                    height: 300,
                    child: _buildPieChart(filteredData),
                  ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildLegend(context, filteredData),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<Map<String, dynamic>> data) {
    // Filter to show only expenses (expense > 0)
    final expenseData = data
        .where((item) => ((item['expense'] as num?) ?? 0) > 0)
        .toList();

    final total = expenseData.fold<num>(
      0,
      (sum, item) => sum + ((item['expense'] as num?) ?? 0),
    );

    if (total == 0) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noData),
      );
    }

    // Prepare pie chart sections (only expenses)
    final pieSections = <PieChartSectionData>[];

    for (final item in expenseData) {
      final category = item['category'] as String;
      final expense = (item['expense'] as num?) ?? 0;
      final percentage = (expense / total * 100).toStringAsFixed(1);
      final color = _categoryColors[category] ?? Colors.grey;

      pieSections.add(
        PieChartSectionData(
          color: color,
          value: expense.toDouble(),
          title: '$percentage%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: pieSections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildLegend(
    BuildContext context,
    List<Map<String, dynamic>> data,
  ) {
    // Filter to show only expenses
    final expenseData = data
        .where((item) => ((item['expense'] as num?) ?? 0) > 0)
        .toList();

    final total = expenseData.fold<num>(
      0,
      (sum, item) => sum + ((item['expense'] as num?) ?? 0),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: expenseData.map((item) {
          final category = item['category'] as String;
          final expense = (item['expense'] as num?) ?? 0;
          final percentage = total > 0
              ? (expense / total * 100).toStringAsFixed(1)
              : '0.0';
          final color = _categoryColors[category] ?? Colors.grey;
          final label = _getLocalizedCategoryName(context, category);

          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

}
