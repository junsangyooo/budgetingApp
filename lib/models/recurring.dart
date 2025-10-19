import 'package:intl/intl.dart';

// Date Formatter: 'YYYY-MM-DD'
final DateFormat _df = DateFormat('yyyy-MM-dd');

class Recurring {
  Recurring({
    required this.payDate,
    required this.amount,
    this.lastPaidDate,
  });

  final DateTime payDate;
  final double amount;
  DateTime? lastPaidDate;

  String toJsonString() {
    final Map<String, dynamic> data = {
      'payDate': _df.format(DateTime(payDate.year, payDate.month, payDate.day)),
      'amount': amount,
      'lastPaidDate': lastPaidDate != null ? _df.format(DateTime(lastPaidDate!.year, lastPaidDate!.month, lastPaidDate!.day)) : null,
    };
    return data.toString();
  }
  static Recurring fromJsonString(String s) {
    final Map<String, dynamic> data = {};
    final entries = s.substring(1, s.length - 1).split(', ');
    for (var entry in entries) {
      final keyValue = entry.split(': ');
      data[keyValue[0]] = keyValue[1] == 'null' ? null : keyValue[1];
    }

    final payDateParts = data['payDate'].split('-').map(int.parse).toList();
    final payDate = DateTime(payDateParts[0], payDateParts[1], payDateParts[2]);

    DateTime? lastPaidDate;
    if (data['lastPaidDate'] != null) {
      final lastPaidDateParts = data['lastPaidDate'].split('-').map(int.parse).toList();
      lastPaidDate = DateTime(lastPaidDateParts[0], lastPaidDateParts[1], lastPaidDateParts[2]);
    }

    return Recurring(
      payDate: payDate,
      amount: double.parse(data['amount'].toString()),
      lastPaidDate: lastPaidDate,
    );
  }
}