import 'package:uuid/uuid.dart';
import 'package:budgeting/db/database.dart';
import 'package:budgeting/models/subscription.dart';

class SubscriptionService {
  static final SubscriptionService instance = SubscriptionService._init();
  static const uuid = Uuid();
  final DatabaseHelper _db = DatabaseHelper.instance;

  SubscriptionService._init();

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

        // Check if this is the paying date and transaction hasn't been created today
        if (today.day == subscription.payingDate) {
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

  /// Create a transaction for a subscription
  Future<void> _createTransactionForSubscription(
    Subscription subscription,
    DateTime transactionDate,
  ) async {
    final transactionData = {
      'id': uuid.v4(),
      'title': 'Subscription: ${subscription.name}',
      'amount': subscription.amount,
      'type': 0, // 0 = expense
      'date': transactionDate.toString().substring(0, 10),
      'accountId': subscription.accountId,
      'category': 'subscription',
      'note': 'Auto-generated from subscription',
      'recurring': null,
    };

    await _db.insertTransaction(transactionData);
  }
}
