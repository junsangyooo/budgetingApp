import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:budgeting/viewmodels/summary_view_model.dart';
import 'package:budgeting/generated/app_localizations.dart';

class MonthlyChart extends StatelessWidget {
  final SummaryViewModel viewModel;

  const MonthlyChart({
    super.key,
    required this.viewModel,
  });


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final monthlyData = viewModel.monthly;

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
              l10n.monthlyNetStats,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // Chart
          Padding(
            padding: const EdgeInsets.all(16),
            child: monthlyData.isEmpty
                ? SizedBox(
                    height: 250,
                    child: Center(
                      child: Text(l10n.noData),
                    ),
                  )
                : SizedBox(
                    height: 280,
                    child: _buildBarChart(context, monthlyData),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, List<Map<String, dynamic>> monthlyData) {
    final now = DateTime.now();
    final chartData = <({String month, num income, num expense})>[];

    // Get the range of months from data
    if (monthlyData.isEmpty) {
      // No data, show only current month
      final date = DateTime(now.year, now.month, 1);
      chartData.add((
        month: _getLocalizedMonthName(context, date),
        income: 0,
        expense: 0,
      ));
    } else {
      // Find earliest month with data
      int minYear = now.year;
      int minMonth = now.month;

      for (final record in monthlyData) {
        final recordYear = record['year'] as int;
        final recordMonth = record['month'] as int;
        final recordDate = DateTime(recordYear, recordMonth, 1);

        if (recordDate.isBefore(DateTime(minYear, minMonth, 1))) {
          minYear = recordYear;
          minMonth = recordMonth;
        }
      }

      // Generate months from earliest to current
      final startDate = DateTime(minYear, minMonth, 1);
      var currentDate = startDate;

      while (currentDate.isBefore(DateTime(now.year, now.month + 1, 1))) {
        final monthRecord = monthlyData.firstWhere(
          (record) {
            final recordYear = record['year'] as int;
            final recordMonth = record['month'] as int;
            return recordYear == currentDate.year &&
                recordMonth == currentDate.month;
          },
          orElse: () => {
            'year': currentDate.year,
            'month': currentDate.month,
            'income': 0,
            'expense': 0,
          },
        );

        chartData.add((
          month: _getLocalizedMonthName(context, currentDate),
          income: (monthRecord['income'] as num?) ?? 0,
          expense: (monthRecord['expense'] as num?) ?? 0,
        ));

        currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
      }
    }

    final maxY = _calculateMaxY(chartData);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= chartData.length) return const SizedBox();

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    chartData[index].month,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _formatAmount(value.toInt()),
                    style: const TextStyle(fontSize: 9),
                  ),
                );
              },
              reservedSize: 50,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          chartData.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              // Income bar (green)
              BarChartRodData(
                toY: chartData[index].income.toDouble(),
                color: Colors.green,
                width: 8,
              ),
              // Expense bar (red)
              BarChartRodData(
                toY: chartData[index].expense.toDouble(),
                color: Colors.red,
                width: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateMaxY(List<({String month, num income, num expense})> data) {
    final values = data
        .expand((item) => [item.income.toDouble(), item.expense.toDouble()])
        .toList();

    if (values.isEmpty) return 100;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    return maxValue > 0 ? maxValue * 1.2 : 100;
  }

  String _getLocalizedMonthName(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);

    // Format month name based on current locale
    final formatter = DateFormat('MMM', locale.toString());
    return formatter.format(date);
  }

  String _formatAmount(int value) {
    if (value == 0) return '0';
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toString();
  }
}
