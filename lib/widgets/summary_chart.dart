import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budgeting/viewmodels/home_view_model.dart';
import 'package:budgeting/generated/app_localizations.dart';

class SummaryChart extends StatelessWidget {
  const SummaryChart({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      height: 140,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _calculateMaxY(viewModel),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String label;
                switch (group.x.toInt()) {
                  case 0:
                    label = l10n.income;
                    break;
                  case 1:
                    label = l10n.expense;
                    break;
                  case 2:
                    label = l10n.balance;
                    break;
                  default:
                    label = '';
                }
                return BarTooltipItem(
                  '$label\n${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = l10n.income;
                      break;
                    case 1:
                      text = l10n.expense;
                      break;
                    case 2:
                      text = l10n.balance;
                      break;
                    default:
                      text = '';
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
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
          barGroups: [
            // Income bar
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: viewModel.income.toDouble(),
                  color: Colors.green,
                  width: 30,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
            // Expense bar
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: viewModel.expense.toDouble(),
                  color: Colors.red,
                  width: 30,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
            // Balance bar
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: viewModel.net.toDouble().abs(),
                  color: viewModel.net >= 0 ? Colors.blue : Colors.orange,
                  width: 30,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY(HomeViewModel viewModel) {
    final values = [
      viewModel.income.toDouble(),
      viewModel.expense.toDouble(),
      viewModel.net.toDouble().abs(),
    ];

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    // Add 20% padding to max value, ensure minimum of 100
    return maxValue > 0 ? maxValue * 1.2 : 100;
  }
}
