import 'package:flutter/foundation.dart';
import 'package:budgeting/models/filter_state.dart';
import 'package:budgeting/models/transaction.dart' as M;
import 'package:budgeting/repositories/transaction_repository.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repo, {FilterState? initial})
      : _filter = initial ?? FilterState.all();

  final TransactionRepository _repo;

  FilterState _filter;
  FilterState get filter => _filter;

  List<M.Transaction> _items = [];
  List<M.Transaction> get items => _items;

  num income = 0, expense = 0, net = 0;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    // List of Transactions
    _items = await _repo.fetchTransactions(
      category   : _filter.category,
      startDate  : _filter.startDate,
      endDate    : _filter.endDate,
      accountId  : _filter.mode == 'account' ? _filter.accountId : null,
      currencyCode: _filter.mode == 'currency' ? _filter.currencyCode : null,
    );

    // Total (if category is specified, only include that category in 'expense')
    final t = await _repo.getTotals(
      currencyCode: _filter.mode == 'currency' ? _filter.currencyCode : null,
      accountId   : _filter.mode == 'account' ? _filter.accountId : null,
      startDate   : _filter.startDate,
      endDate     : _filter.endDate,
      categoryForExpenseOnly: _filter.category,
    );
    income = t.income; expense = t.expense; net = t.net;

    _loading = false;
    notifyListeners();
  }

  void updateFilter(FilterState f) {
    _filter = f;
    load();
  }

  Future<void> deleteTx(String id) async {
    await _repo.deleteTransaction(id);
    await load();
  }

  Future<void> addOrUpdate(M.Transaction tx, {bool isUpdate = false}) async {
    if (isUpdate) {
      await _repo.updateTransaction(tx);
    } else {
      await _repo.addTransaction(tx);
    }
    await load();
  }
}
