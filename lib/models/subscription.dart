class Subscription {
  final int? id;
  final String name;
  final double amount;
  final int accountId;
  final DateTime startDate;
  final DateTime? endDate;
  final String frequency; // 'daily', 'weekly', 'monthly'
  final int payingDate; // Day of month (1-31) for monthly subscriptions
  final DateTime? lastCreatedDate; // Track when transaction was last created

  Subscription({
    this.id,
    required this.name,
    required this.amount,
    required this.accountId,
    required this.startDate,
    this.endDate,
    this.frequency = 'monthly',
    required this.payingDate,
    this.lastCreatedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'amount': amount,
      'accountId': accountId,
      'startDate': startDate.toString().substring(0, 10),
      'endDate': endDate?.toString().substring(0, 10),
      'frequency': frequency,
      'payingDate': payingDate,
      'lastCreatedDate': lastCreatedDate?.toString().substring(0, 10),
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      accountId: map['accountId'] as int,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      frequency: map['frequency'] as String? ?? 'monthly',
      payingDate: map['payingDate'] as int,
      lastCreatedDate: map['lastCreatedDate'] != null ? DateTime.parse(map['lastCreatedDate'] as String) : null,
    );
  }

  Subscription copyWith({
    int? id,
    String? name,
    double? amount,
    int? accountId,
    DateTime? startDate,
    DateTime? endDate,
    String? frequency,
    int? payingDate,
    DateTime? lastCreatedDate,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      frequency: frequency ?? this.frequency,
      payingDate: payingDate ?? this.payingDate,
      lastCreatedDate: lastCreatedDate ?? this.lastCreatedDate,
    );
  }

  @override
  String toString() => '$name (\$$amount / $frequency)';
}
