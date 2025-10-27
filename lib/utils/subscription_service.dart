import 'package:uuid/uuid.dart';
import 'package:budgeting/db/database.dart';
import 'package:budgeting/models/subscription.dart';

class SubscriptionService {
  static final SubscriptionService instance = SubscriptionService._init();
  static const uuid = Uuid();
  final DatabaseHelper _db = DatabaseHelper.instance;

  SubscriptionService._init();

  /// Generate a human-readable frequency description for a subscription
  String _getFrequencyDescription(String frequency) {
    if (frequency == 'monthly') {
      return 'month';
    } else if (frequency == 'yearly') {
      return 'year';
    } else if (frequency.startsWith('custom:')) {
      final months = frequency.split(':')[1];
      return '$months months';
    }
    return 'month';
  }

  /// Check for due subscriptions and create transactions automatically
  Future<void> processSubscriptions() async {
    try {
      final subscriptions = await _db.getAllSubscriptions();
      final today = DateTime.now();
      final todayString = today.toString().substring(0, 10);

      for (final sub in subscriptions) {
        final subscription = Subscription.fromMap(sub);

        // Check if subscription is active (started and not ended)
        if (subscription.startDate.isAfter(today)) {
          continue; // Subscription hasn't started yet
        }

        if (subscription.endDate != null && subscription.endDate!.isBefore(today)) {
          continue; // Subscription has ended
        }

        // Check if subscription is due today
        if (_isSubscriptionDueToday(subscription, today)) {
          final lastCreated = subscription.lastCreatedDate;

          // If no transaction was created today yet, create one
          if (lastCreated == null || lastCreated.toString().substring(0, 10) != todayString) {
            await _createTransactionForSubscription(subscription, today);

            // Update the lastCreatedDate
            await _db.updateSubscriptionLastCreatedDate(
              subscription.id!,
              todayString,
            );
          }
        }
      }
    } catch (e) {
      print('Error processing subscriptions: $e');
    }
  }

  /// Check if a subscription is due today based on its frequency
  bool _isSubscriptionDueToday(Subscription subscription, DateTime today) {
    // Must be the correct day of month
    if (today.day != subscription.payingDate) {
      return false;
    }

    final frequency = subscription.frequency;

    if (frequency == 'monthly') {
      // Monthly: due every month on the same day
      return true;
    } else if (frequency == 'yearly') {
      // Yearly: due on the same month and day each year
      return today.month == subscription.startDate.month;
    } else if (frequency.startsWith('custom:')) {
      // Custom: due every N months
      final customIntervalStr = frequency.split(':')[1];
      final customInterval = int.tryParse(customIntervalStr) ?? 3;

      // Calculate months between start date and today
      int monthsDiff = (today.year - subscription.startDate.year) * 12 +
          (today.month - subscription.startDate.month);

      // Check if monthsDiff is a multiple of customInterval
      return monthsDiff >= 0 && monthsDiff % customInterval == 0;
    }

    return false;
  }

  /// Create a transaction for a subscription
  Future<void> _createTransactionForSubscription(
    Subscription subscription,
    DateTime transactionDate,
  ) async {
    final frequencyDesc = _getFrequencyDescription(subscription.frequency);
    final transactionData = {
      'id': uuid.v4(),
      'title': 'Subscription: ${subscription.name}',
      'amount': subscription.amount,
      'type': 0, // 0 = expense
      'date': transactionDate.toString().substring(0, 10),
      'accountId': subscription.accountId,
      'category': 'subscription',
      'note': 'Subscription: ${subscription.name}\nPayment: Every $frequencyDesc',
      'recurring': null,
    };

    await _db.insertTransaction(transactionData);
  }
}
