class Account {
  final int id;
  final String name; // 예: "하나은행 통장", "TD Chequing"
  final String currencyCode;
  double balance;
  Account({required this.id, required this.name, required this.currencyCode, this.balance = 0});
}
