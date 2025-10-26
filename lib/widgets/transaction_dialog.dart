import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:budgeting/viewmodels/home_view_model.dart';
import 'package:budgeting/models/transaction.dart' as M;
import 'package:budgeting/db/database.dart';
import 'package:budgeting/models/account.dart';
import 'package:intl/intl.dart';
import 'package:budgeting/generated/app_localizations.dart';

class TransactionDialog extends StatefulWidget {
  final M.Transaction? existingTransaction;

  const TransactionDialog({super.key, this.existingTransaction});

  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFormatter = NumberFormat('#,###.##');

  bool _isIncome = true;
  M.Category _selectedCategory = M.Category.food;
  DateTime _selectedDate = DateTime.now();
  int? _selectedAccountId;
  List<Account> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();

    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _titleController.text = tx.title;
      _amountController.text = _amountFormatter.format(tx.amount);
      _noteController.text = tx.note ?? '';
      _isIncome = tx.type;
      _selectedCategory = tx.category;
      _selectedDate = tx.date;
      _selectedAccountId = tx.accountId;
    }
  }

  Future<void> _loadAccounts() async {
    final db = DatabaseHelper.instance;
    final accountRows = await db.getAllAccounts();
    setState(() {
      _accounts = accountRows.map((row) => Account.fromMap(row)).toList();
      if (_accounts.isNotEmpty && _selectedAccountId == null) {
        _selectedAccountId = _accounts.first.id;
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_accounts.isEmpty) {
      return AlertDialog(
        title: Text(l10n.noAccounts),
        content: Text(l10n.createAccountFirst),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(widget.existingTransaction == null ? l10n.addTransaction : l10n.editTransaction),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Toggle (Income/Expense)
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text(l10n.expense), icon: const Icon(Icons.remove)),
                  ButtonSegment(value: true, label: Text(l10n.income), icon: const Icon(Icons.add)),
                ],
                selected: {_isIncome},
                onSelectionChanged: (Set<bool> selected) {
                  setState(() {
                    _isIncome = selected.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                  _ThousandsSeparatorInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterAmount;
                  }
                  final cleanValue = value.replaceAll(',', '');
                  if (double.tryParse(cleanValue) == null) {
                    return l10n.pleaseEnterValidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<M.Category>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: l10n.category,
                  border: const OutlineInputBorder(),
                ),
                items: M.Category.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_getLocalizedCategoryName(context, category)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Account
              DropdownButtonFormField<int>(
                initialValue: _selectedAccountId,
                decoration: InputDecoration(
                  labelText: l10n.account,
                  border: const OutlineInputBorder(),
                ),
                items: _accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Text('${account.name} (${account.currencyCode})'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedAccountId = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.date),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Note (Optional)
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: l10n.note,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _saveTransaction,
          child: Text(l10n.save),
        ),
      ],
    );
  }

  void _saveTransaction() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectAccount)),
      );
      return;
    }

    final cleanAmount = _amountController.text.replaceAll(',', '');
    final transaction = M.Transaction(
      id: widget.existingTransaction?.id,
      title: _titleController.text,
      amount: double.parse(cleanAmount),
      type: _isIncome,
      date: _selectedDate,
      accountId: _selectedAccountId!,
      category: _selectedCategory,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    try {
      final viewModel = context.read<HomeViewModel>();
      await viewModel.addOrUpdate(
        transaction,
        isUpdate: widget.existingTransaction != null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingTransaction == null
                  ? l10n.transactionAdded
                  : l10n.transactionUpdated,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorOccurred(e.toString()))),
        );
      }
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

/// Custom input formatter to add thousand separators (commas) as user types
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all commas to get the raw number
    String newText = newValue.text.replaceAll(',', '');

    // If the text is not a valid number format, return old value
    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(newText)) {
      return oldValue;
    }

    // Split into integer and decimal parts
    final parts = newText.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Format the integer part with commas
    if (integerPart.isNotEmpty) {
      final number = int.tryParse(integerPart);
      if (number != null) {
        integerPart = NumberFormat('#,###').format(number);
      }
    }

    // Reconstruct the text
    String formattedText = integerPart;
    if (decimalPart != null) {
      formattedText += '.$decimalPart';
    } else if (newValue.text.endsWith('.')) {
      formattedText += '.';
    }

    // Calculate new cursor position
    int selectionIndex = formattedText.length;
    if (newValue.selection.baseOffset < newValue.text.length) {
      // If cursor is not at the end, try to maintain relative position
      selectionIndex = newValue.selection.baseOffset;
      // Adjust for added/removed commas
      final oldCommas = oldValue.text.substring(0, oldValue.selection.baseOffset).replaceAll(RegExp(r'[^\,]'), '').length;
      final newCommas = formattedText.substring(0, selectionIndex.clamp(0, formattedText.length)).replaceAll(RegExp(r'[^\,]'), '').length;
      selectionIndex += (newCommas - oldCommas);
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: selectionIndex.clamp(0, formattedText.length),
      ),
    );
  }
}
