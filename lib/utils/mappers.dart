import 'package:budgeting/models/transaction.dart' as M;
import 'package:intl/intl.dart';
import 'package:budgeting/models/recurring.dart';

// Date Formatter: 'YYYY-MM-DD'
final DateFormat _df = DateFormat('yyyy-MM-dd');

// ---- Category <-> DB(String) ----
String categoryToDb(M.Category c) => c.name;
M.Category categoryFromDb(String s) =>
  M.Category.values.firstWhere((e) => e.name == s, orElse: () => M.Category.others);

/// ---- bool <-> int ----
int boolToInt(bool b) => b ? 1 : 0;
bool intToBool(Object? i) => (i is num ? i.toInt() : int.parse(i.toString())) == 1;

/// ---- DateTime <-> 'YYYY-MM-DD' ----
String dateToDb(DateTime d) => _df.format(DateTime(d.year, d.month, d.day));
DateTime dbToDate(String s) {
  final parts = s.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

/// ---- Recurring 직렬화 ----
String? recurringToDb(Recurring? r) => r?.toJsonString();
Recurring? recurringFromDb(Object? s) {
  if (s == null) return null;
  return Recurring.fromJsonString(s.toString());
}

/// ---- Model <-> DB Row 매핑 ----
Map<String, dynamic> txToRow(M.Transaction t) => {
  'id'       : t.id,
  'title'    : t.title,
  'amount'   : t.amount,
  'type'     : boolToInt(t.type),       // 1/0
  'date'     : dateToDb(t.date),        // 'YYYY-MM-DD'
  'accountId': t.accountId,
  'category' : categoryToDb(t.category),
  'note'     : t.note,
  'recurring': recurringToDb(t.recurring),
};
M.Transaction rowToTx(Map<String, dynamic> r) => M.Transaction(
  id       : r['id'] as String,
  title    : r['title'] as String,
  amount   : (r['amount'] as num).toDouble(),
  type     : intToBool(r['type']),
  date     : dbToDate(r['date'] as String),
  accountId: (r['accountId'] as num).toInt(),
  category : categoryFromDb(r['category'] as String),
  note     : r['note'] as String?,
  recurring: recurringFromDb(r['recurring']),
);