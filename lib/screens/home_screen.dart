import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgeting/viewmodels/home_view_model.dart';
import 'package:budgeting/widgets/filter_bar.dart';
import 'package:budgeting/widgets/summary_chart.dart';
import 'package:budgeting/widgets/transaction_list.dart';
import 'package:budgeting/widgets/transaction_dialog.dart';
import 'package:budgeting/models/transaction.dart' as M;
import 'package:budgeting/utils/subscription_service.dart';
import 'package:budgeting/generated/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the existing HomeViewModel from the parent MultiProvider in main.dart
    // This ensures we have a single instance across the app
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);

    // Load data and process subscriptions when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.load();
      // Process subscriptions (auto-create transactions if due)
      SubscriptionService.instance.processSubscriptions();
    });

    return const HomeScreenContent();
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: viewModel.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Bar - Fixed at top
                FilterBar(
                  currentFilter: viewModel.filter,
                  onFilterChanged: viewModel.updateFilter,
                ),

                // Scrollable content: Summary + Transactions
                Expanded(
                  child: viewModel.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noTransactionsFound,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : CustomScrollView(
                          slivers: [
                            // Summary Chart
                            const SliverToBoxAdapter(
                              child: SummaryChart(),
                            ),

                            // Transactions List
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final transaction = viewModel.items[index];
                                  return TransactionListItem(
                                    transaction: transaction,
                                    onEdit: () => _showEditDialog(context, transaction, viewModel),
                                    onDelete: () => _confirmDelete(context, transaction, viewModel),
                                  );
                                },
                                childCount: viewModel.items.length,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: context.read<HomeViewModel>(),
        child: const TransactionDialog(),
      ),
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
