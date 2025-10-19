import 'package:budgeting/db/database.dart';
import 'package:budgeting/models/transaction.dart' as M;
import 'package:budgeting/utils/mappers.dart';

class TransactionRepository {
  TransactionRepository(this._db);
  final DatabaseHelper _db;

  // C/U/D
  Future<void> addTransaction(M.Transaction t) async {
    await _db.insertTransaction(txToRow(t));
  }

  Future<void> updateTransaction(M.Transaction t) async {
    await _db.updateTransaction(t.id, txToRow(t));
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
  }

  // Find List (send value from FilterState)
  Future<List<M.Transaction>> fetchTransactions({
    String? category,
    String? startDate, // 'YYYY-MM-DD'
    String? endDate,
    int? accountId,
    String? currencyCode,
    int? limit,
    int? offset,
  }) async {
    final rows = await _db.getTransactions(
      category: category,
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
      currencyCode: currencyCode,
      limit: limit,
      offset: offset,
    );
    return rows.map(rowToTx).toList();
  }

  // Summary: Home Screen Totals
  Future<({num income, num expense, num net})> getTotals({
    String? currencyCode,
    int? accountId,
    String? startDate,
    String? endDate,
    String? categoryForExpenseOnly,
  }) async {
    final map = await _db.getTotals(
      currencyCode: currencyCode,
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
      categoryForExpenseOnly: categoryForExpenseOnly,
    );
    return (income: map['income']!, expense: map['expense']!, net: map['net']!);
  }

  // Remains(Per Account)
  Future<num> getComputedBalanceForAccount(int accountId) =>
      _db.getComputedBalanceForAccount(accountId);

  // Summary: Monthly income/expense
  Future<List<Map<String, dynamic>>> getMonthlyIncomeExpense({
    String? currencyCode,
    int? accountId,
    String? startDate,
    String? endDate,
  }) =>
      _db.getMonthlyIncomeExpense(
        currencyCode: currencyCode,
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
      );

  // Summary: Monthly total for a specific category (Pie Chart)
  Future<List<Map<String, dynamic>>> getCategoryTotalsForMonth({
    String? currencyCode,
    int? accountId,
    required String monthStart,
    required String monthEnd,
  }) =>
      _db.getCategoryTotalsForMonth(
        currencyCode: currencyCode,
        accountId: accountId,
        monthStart: monthStart,
        monthEnd: monthEnd,
      );

  // Summary: Monthly total for a specific category (Bar Chart)
  Future<List<Map<String, dynamic>>> getMonthlyTotalsForCategory({
    String? currencyCode,
    int? accountId,
    required String category,
    String? startDate,
    String? endDate,
  }) =>
      _db.getMonthlyTotalsForCategory(
        currencyCode: currencyCode,
        accountId: accountId,
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
}
