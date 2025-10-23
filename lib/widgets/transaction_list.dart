import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeting/viewmodels/home_view_model.dart';
import 'package:budgeting/models/transaction.dart' as M;
import 'package:budgeting/widgets/transaction_dialog.dart';
import 'package:intl/intl.dart';
import 'package:budgeting/generated/app_localizations.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final transactions = viewModel.items;

    return ListView.builder(
      itemCount: transactions.length,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionListItem(
          transaction: transaction,
          onEdit: () => _showEditDialog(context, transaction, viewModel),
          onDelete: () => _confirmDelete(context, transaction, viewModel),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, M.Transaction transaction, HomeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: viewModel,
        child: TransactionDialog(existingTransaction: transaction),
      ),
    );
  }

  void _confirmDelete(BuildContext context, M.Transaction transaction, HomeViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.deleteConfirmation(transaction.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteTx(transaction.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.transactionDeleted)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final M.Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(transaction.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(transaction.category),
                  color: _getCategoryColor(transaction.category),
                ),
              ),
              const SizedBox(width: 12),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _getLocalizedCategoryName(context, transaction.category),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateFormat.format(transaction.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount and Action Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.type ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: transaction.type ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onEdit,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onDelete,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(M.Category category) {
    switch (category) {
      case M.Category.income:
        return Icons.attach_money;
      case M.Category.food:
        return Icons.shopping_cart;
      case M.Category.dining:
        return Icons.restaurant;
      case M.Category.drinks:
        return Icons.local_cafe;
      case M.Category.transportation:
        return Icons.directions_car;
      case M.Category.housing:
        return Icons.home;
      case M.Category.subscription:
        return Icons.subscriptions;
      case M.Category.shopping:
        return Icons.shopping_bag;
      case M.Category.health:
        return Icons.local_hospital;
      case M.Category.education:
        return Icons.school;
      case M.Category.entertainment:
        return Icons.movie;
      case M.Category.gifts:
        return Icons.card_giftcard;
      case M.Category.investment:
        return Icons.trending_up;
      case M.Category.others:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(M.Category category) {
    switch (category) {
      case M.Category.income:
        return Colors.green;
      case M.Category.food:
        return Colors.orange;
      case M.Category.dining:
        return Colors.red;
      case M.Category.drinks:
        return Colors.brown;
      case M.Category.transportation:
        return Colors.blue;
      case M.Category.housing:
        return Colors.purple;
      case M.Category.subscription:
        return Colors.pink;
      case M.Category.shopping:
        return Colors.teal;
      case M.Category.health:
        return Colors.red;
      case M.Category.education:
        return Colors.indigo;
      case M.Category.entertainment:
        return Colors.deepOrange;
      case M.Category.gifts:
        return Colors.pinkAccent;
      case M.Category.investment:
        return Colors.green;
      case M.Category.others:
        return Colors.grey;
    }
  }

  String _getLocalizedCategoryName(BuildContext context, M.Category category) {
    final l10n = AppLocalizations.of(context)!;

    switch (category) {
      case M.Category.income:
        return l10n.income;
      case M.Category.food:
        return l10n.food;
      case M.Category.dining:
        return l10n.dining;
      case M.Category.drinks:
        return l10n.drinks;
      case M.Category.transportation:
        return l10n.transportation;
      case M.Category.housing:
        return l10n.housing;
      case M.Category.subscription:
        return l10n.subscription;
      case M.Category.shopping:
        return l10n.shopping;
      case M.Category.health:
        return l10n.health;
      case M.Category.education:
        return l10n.education;
      case M.Category.entertainment:
        return l10n.entertainment;
      case M.Category.gifts:
        return l10n.gifts;
      case M.Category.investment:
        return l10n.investment;
      case M.Category.others:
        return l10n.others;
    }
  }
}
