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

  // Summary totals
  num income = 0;
  num expense = 0;
  num net = 0;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    // Fetch transactions based on filters
    if (_filter.categories.isEmpty) {
      // No category filter - fetch all
      _items = await _repo.fetchTransactions(
        category: null,
        startDate: _filter.startDate,
        endDate: _filter.endDate,
        accountId: _filter.mode == 'account' ? _filter.accountId : null,
        currencyCode: _filter.mode == 'currency' ? _filter.currencyCode : null,
      );
    } else if (_filter.categories.length == 1) {
      // Single category - use existing method
      _items = await _repo.fetchTransactions(
        category: _filter.categories.first,
        startDate: _filter.startDate,
        endDate: _filter.endDate,
        accountId: _filter.mode == 'account' ? _filter.accountId : null,
        currencyCode: _filter.mode == 'currency' ? _filter.currencyCode : null,
      );
    } else {
      // Multiple categories - fetch for each and combine
      final allTransactions = <M.Transaction>[];
      for (final category in _filter.categories) {
        final txs = await _repo.fetchTransactions(
          category: category,
          startDate: _filter.startDate,
          endDate: _filter.endDate,
          accountId: _filter.mode == 'account' ? _filter.accountId : null,
          currencyCode: _filter.mode == 'currency' ? _filter.currencyCode : null,
        );
        allTransactions.addAll(txs);
      }
      // Remove duplicates and sort by date descending
      final seen = <String>{};
      _items = allTransactions
          .where((tx) => seen.add(tx.id))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }

    // Calculate totals
    // For multiple categories, we need to sum up expenses for selected categories only
    income = 0;
    expense = 0;
    for (final tx in _items) {
      if (tx.type) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    net = income - expense;

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
