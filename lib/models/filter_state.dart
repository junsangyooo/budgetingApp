/// Home/Summary sharing filters state
/// - mode: 'all' | 'currency' | 'account'
/// - currencyCode/accountId depends on mode
/// - categories: multiple categories can be selected (if specified, 'expense' in home totals will only include those categories)
/// - period is startDate/endDate (YYYY-MM-DD), null means all
class FilterState {
  final String mode;         // 'all' | 'currency' | 'account'
  final String? currencyCode;
  final int? accountId;
  final List<String> categories;    // list of enum.name
  final String? startDate;   // 'YYYY-MM-DD'
  final String? endDate;     // 'YYYY-MM-DD'

  const FilterState({
    this.mode = 'all',
    this.currencyCode,
    this.accountId,
    this.categories = const [],
    this.startDate,
    this.endDate,
  });

  FilterState copyWith({
    String? mode,
    String? currencyCode,
    int? accountId,
    List<String>? categories,
    String? startDate,
    String? endDate,
    bool clearRange = false,   // refresh period
    bool clearCategories = false,
  }) {
    return FilterState(
      mode: mode ?? this.mode,
      currencyCode: currencyCode ?? this.currencyCode,
      accountId: accountId ?? this.accountId,
      categories: clearCategories ? const [] : (categories ?? this.categories),
      startDate: clearRange ? null : (startDate ?? this.startDate),
      endDate: clearRange ? null : (endDate ?? this.endDate),
    );
  }

  // Convenience constructors
  factory FilterState.all() => const FilterState(mode: 'all');

  factory FilterState.forCurrency(String code,
      {String? startDate, String? endDate, List<String>? categories}) {
    return FilterState(
      mode: 'currency',
      currencyCode: code,
      startDate: startDate,
      endDate: endDate,
      categories: categories ?? const [],
    );
  }

  factory FilterState.forAccount(int id,
      {String? startDate, String? endDate, List<String>? categories}) {
    return FilterState(
      mode: 'account',
      accountId: id,
      startDate: startDate,
      endDate: endDate,
      categories: categories ?? const [],
    );
  }
}
