import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

enum ChartType { income, expense }

class MonthlyChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final ChartType type;

  const MonthlyChart({
    super.key,
    required this.data,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final color = type == ChartType.income ? Colors.green : Colors.red;
    final maxY = _getMaxValue();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2, // Add 20% padding
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final monthData = data[groupIndex];
                final value = type == ChartType.income
                    ? monthData['income']
                    : monthData['expense'];
                return BarTooltipItem(
                  '\$${value.toStringAsFixed(2)}',
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
                  if (value.toInt() >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final monthData = data[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _getMonthAbbr(monthData['month']),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${_formatCompactNumber(value)}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
          ),
          borderData: FlBorderData(show: false),
          barGroups: _buildBarGroups(color),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(Color color) {
    return List.generate(data.length, (index) {
      final monthData = data[index];
      final value = type == ChartType.income
          ? (monthData['income'] as num).toDouble()
          : (monthData['expense'] as num).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: color,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    });
  }

  double _getMaxValue() {
    double max = 0;
    for (var monthData in data) {
      final value = type == ChartType.income
          ? (monthData['income'] as num).toDouble()
          : (monthData['expense'] as num).toDouble();
      if (value > max) max = value;
    }
    return max == 0 ? 100 : max;
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatCompactNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}