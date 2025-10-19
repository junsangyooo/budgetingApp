import 'package:flutter/material.dart';
import 'package:budgeting/models/transaction.dart';

class HomeScreen extends StatefulWidget{
  const Transactions ({super.key});

  @override
  State<Transactions> createState() {
    return _TransactionsState();
  }
}

class _TransactionsState extends State<Transactions>{
  final List<Transaction> _registeredTransactions = [
    Transaction(
      title: 'Investment Profit',
      amount: 100.0,
      type: true,
      date: DateTime.now(),
      accountId: 1,
      category: Category.income,
      note: 'Selled the stocks for profit',
    ),
    Transaction(
      title: 'Groceries',
      amount: 50.0,
      type: false,
      date: DateTime.now(),
      accountId: 1,
      category: Category.food,
      note: 'Weekly grocery shopping',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('The chart'),
          Text('Expenses list...'),
        ],
      )
    );
  }
}