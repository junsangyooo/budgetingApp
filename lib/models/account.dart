class Account {
  final int? id;
  final String name;
  final String currencyCode;
  double balance;
  
  Account({
    this.id,
    required this.name,
    required this.currencyCode,
    this.balance = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'currencyCode': currencyCode,
      'balance': balance,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      name: map['name'] as String,
      currencyCode: map['currencyCode'] as String,
      balance: (map['balance'] as num).toDouble(),
    );
  }

  Account copyWith({
    int? id,
    String? name,
    String? currencyCode,
    double? balance,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      balance: balance ?? this.balance,
    );
  }

  @override
  String toString() => '$name ($currencyCode)';
}