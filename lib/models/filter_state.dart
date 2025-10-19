/// Home/Summary sharing filters state
/// - mode: 'all' | 'currency' | 'account' 
/// - currencyCode/accountId depends on mode
/// - category is optional (if specified, 'expense' in home totals will only include that category)
/// - period is startDate/endDate (YYYY-MM-DD), null means all
class FilterState {
  final String mode;         // 'all' | 'currency' | 'account'
  final String? currencyCode;
  final int? accountId;
  final String? category;    // enum.name
  final String? startDate;   // 'YYYY-MM-DD'
  final String? endDate;     // 'YYYY-MM-DD'

  const FilterState({
    this.mode = 'all',
    this.currencyCode,
    this.accountId,
    this.category,
    this.startDate,
    this.endDate,
  });

  FilterState copyWith({
    String? mode,
    String? currencyCode,
    int? accountId,
    String? category,
    String? startDate,
    String? endDate,
    bool clearRange = false,   // refresh period
    bool clearCategory = false,
  }) {
    return FilterState(
      mode: mode ?? this.mode,
      currencyCode: currencyCode ?? this.currencyCode,
      accountId: accountId ?? this.accountId,
      category: clearCategory ? null : (category ?? this.category),
      startDate: clearRange ? null : (startDate ?? this.startDate),
      endDate: clearRange ? null : (endDate ?? this.endDate),
    );
  }

  // Convenience constructors
  factory FilterState.all() => const FilterState(mode: 'all');

  factory FilterState.forCurrency(String code,
      {String? startDate, String? endDate, String? category}) {
    return FilterState(
      mode: 'currency',
      currencyCode: code,
      startDate: startDate,
      endDate: endDate,
      category: category,
    );
  }

  factory FilterState.forAccount(int id,
      {String? startDate, String? endDate, String? category}) {
    return FilterState(
      mode: 'account',
      accountId: id,
      startDate: startDate,
      endDate: endDate,
      category: category,
    );
  }
}
