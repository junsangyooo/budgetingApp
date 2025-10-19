import 'package:budgeting/models/recurring.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

/// Domain model for inner app (UI <-> Repository <-> DB Mapping Target)
/// - id: UUID v4 (identical to PK in DB)
/// - type: true(Income) / false(Expense)
/// - date: 'YYYY-MM-DD', (Save as String in DB)
/// - category: Single Category (Save as enum.name in DB)
enum Category {
  income,            // (pay, interest, refund, etc.)
  food,              // groceries
  dining,            // dining out
  drinks,            // cafe/drinks
  transportation,    // transportation/public transport/fuel
  housing,           // rent/utilities/electricity/water/gas
  subscription,      // subscription (e.g. Netflix)
  shopping,          // shopping/lifestyle goods
  health,            // hospital/pharmacy/insurance
  education,         // learning/lectures/books
  entertainment,     // movies/leisure/hobbies
  gifts,             // gifts/donations
  investment,        // investment, savings
  others,           // others/miscellaneous
}

class Transaction{
  Transaction({
    String? id,
    required this.title,
    required this.amount,
    required this.type,   // true income / false expense
    required this.date,
    required this.accountId,
    required this.category,
    this.note,
    this.recurring,
  }) : id = id ?? uuid.v4();

  final String id;
  final String title;
  final double amount;
  final bool type;
  final DateTime date;
  final int accountId;
  final Category category;
  String? note;
  Recurring? recurring;

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    bool? type,
    DateTime? date,
    int? accountId,
    Category? category,
    String? note,
    Recurring? recurring,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
      category: category ?? this.category,
      note: note ?? this.note,
      recurring: recurring ?? this.recurring,
    );
  }
}