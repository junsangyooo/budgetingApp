import 'package:flutter/material.dart';
import 'package:budgeting/models/transaction.dart';

class Transactions extends StatefulWidget{
  const Transactions ({super.key, required this.transactions});
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (ctx, index) => Text(),);
  }
}