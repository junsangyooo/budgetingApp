class Currency {
  final String code;
  final String symbol;
  final String name;
  
  Currency(this.code, this.symbol, this.name);

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'symbol': symbol,
      'name': name,
    };
  }

  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      map['code'] as String,
      map['symbol'] as String,
      map['name'] as String,
    );
  }

  @override
  String toString() => '$code - $name';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Currency && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}