import 'package:flutter/foundation.dart';
import 'package:budgeting/models/filter_state.dart';
import 'package:budgeting/repositories/transaction_repository.dart';

class SummaryViewModel extends ChangeNotifier {
  SummaryViewModel(this._repo, {FilterState? initial})
      : _filter = initial ?? FilterState.all();

  final TransactionRepository _repo;

  FilterState _filter;
  FilterState get filter => _filter;

  // Monthly income/expense graph data
  List<Map<String, dynamic>> monthly = [];

  // Category total for a specific month (Pie)
  List<Map<String, dynamic>> categoryForMonth = [];

  // Monthly total for a specific category (Bar Chart)
  List<Map<String, dynamic>> monthlyForCategory = [];

  bool _loading = false;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true; notifyListeners();

    monthly = await _repo.getMonthlyIncomeExpense(
      currencyCode: _filter.mode == 'currency' ? _filter.currencyCode : null,
      accountId   : _filter.mode == 'account' ? _filter.accountId : null,
      startDate   : _filter.startDate,
      endDate     : _filter.endDate,
    );

    // Load category data for the current month
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final monthStartStr = monthStart.toString().substring(0, 10);
    final monthEndStr = monthEnd.toString().substring(0, 10);

    await loadCategoryTotalsForMonth(
      monthStart: monthStartStr,
      monthEnd: monthEndStr,
    );

    _loading = false; notifyListeners();
  }

  void updateFilter(FilterState f) {
    _filter = f;
    load();
  }

  Future<void> loadCategoryTotalsForMonth({
    required String monthStart, // 'YYYY-MM-01'
    required String monthEnd,   // 'YYYY-MM-last day'
  }) async {
    categoryForMonth = await _repo.getCategoryTotalsForMonth(
      currencyCode: _filter.mode == 'currency' ? _filter.currencyCode : null,
      accountId   : _filter.mode == 'account' ? _filter.accountId : null,
      monthStart  : monthStart,
      monthEnd    : monthEnd,
    );
    notifyListeners();
  }

  Future<void> loadMonthlyForCategory(String category) async {
    monthlyForCategory = await _repo.getMonthlyTotalsForCategory(
      currencyCode: _filter.mode == 'currency' ? _filter.currencyCode : null,
      accountId   : _filter.mode == 'account' ? _filter.accountId : null,
      category    : category,
      startDate   : _filter.startDate,
      endDate     : _filter.endDate,
    );
    notifyListeners();
  }
}
