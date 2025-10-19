//import 'package:budgeting/models/category.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum Category {
  food, transportation, investment, subscription, entertainment, 
  drinks, shopping, gifts, education, health, income, others
}

class Transaction{
  Transaction({
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.accountId,
    required this.category,
    this.note,
  }) : id = uuid.v4();

  final String id;
  final String title;
  final double amount;
  final bool type; // True: income, False: expense
  final DateTime date;
  final int accountId;
  final Category category;
  String? note;
}