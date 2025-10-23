# Multi-Currency Budgeting App

A Flutter-based personal finance management application that enables users to track income and expenses across multiple currencies and accounts with powerful filtering and analytics capabilities.

## Overview

This budgeting application helps you manage your finances by:
- Tracking transactions (income and expenses) across multiple bank accounts
- Supporting multiple currencies simultaneously
- Providing detailed filtering options by currency, account, period, and category
- Visualizing financial data with charts and summaries
- Managing recurring transactions and payment tracking

## Features

### Core Functionality

#### 1. **Multi-Currency Support**
- Add and manage multiple currencies (USD, CAD, KRW, etc.)
- Each account is linked to a specific currency
- Filter transactions by currency to see all accounts in that currency
- Currency-specific balance calculations

#### 2. **Account Management**
- Create multiple accounts per currency
- Track individual account balances
- View computed balances based on transaction history
- Automatic balance updates with new transactions

#### 3. **Transaction Tracking**
- **Income & Expense Categories:**
  - Income (salary, interest, refunds, etc.)
  - Food (groceries)
  - Dining (restaurants)
  - Drinks (cafes, beverages)
  - Transportation (public transport, fuel)
  - Housing (rent, utilities)
  - Subscriptions (Netflix, etc.)
  - Shopping (lifestyle goods)
  - Health (medical, insurance)
  - Education (courses, books)
  - Entertainment (movies, hobbies)
  - Gifts (donations)
  - Investment (savings)
  - Others (miscellaneous)

- **Transaction Features:**
  - Add, edit, and delete transactions
  - Attach notes to transactions
  - Set transaction dates
  - Support for recurring transactions

#### 4. **Advanced Filtering**
The home screen provides four powerful filters:

- **Currency Filter:** View all transactions in a specific currency across all accounts
- **Account Filter:** View transactions for a specific account
- **Period Filter:**
  - All Time
  - Today
  - This Week
  - This Month
  - This Year
  - Custom Date Range
- **Category Filter:** Filter by any transaction category

**Special Case:** When currency is specified but account is not, the app shows all transactions from all accounts using that currency.

#### 5. **Summary & Analytics**
- Real-time bar chart showing:
  - Total Income (green bar)
  - Total Expense (red bar)
  - Balance/Net (blue/orange bar)
- All summaries respect active filters
- Monthly income/expense tracking
- Category-based expense analysis
- Exportable data for further analysis

#### 6. **User Interface**
- **Onboarding Flow:** First-time setup with language selection and initial account creation
- **Bottom Navigation:**
  - Home: Transaction list with filters and summary
  - Summary: Detailed analytics and charts (in development)
  - Settings: App preferences and configuration (in development)
- **Transaction Management:**
  - Tap to edit transactions
  - Edit/Delete buttons on each transaction card
  - Confirmation dialogs for destructive actions
- **FloatingActionButton:** Quick access to add new transactions

## Technology Stack

### Framework & Language
- **Flutter** (Dart 3.0+)
- Cross-platform support: iOS, Android, macOS, Windows, Linux

### Key Dependencies
- **State Management:** Provider (^6.1.1)
- **Database:** SQLite via sqflite (^2.3.0)
- **Charts:** FL Chart (^0.66.0)
- **Localization:** Flutter Localizations (built-in)
- **Date/Time:** intl (^0.20.2)
- **UUID Generation:** uuid (^4.2.2)
- **Local Storage:** shared_preferences (^2.5.3)

### Architecture

#### MVVM Pattern
```
lib/
├── models/           # Data models (Transaction, Account, Currency, FilterState)
├── viewmodels/       # Business logic (HomeViewModel, SummaryViewModel)
├── screens/          # UI screens (OnboardingScreen, HomeScreen, MainNavigation)
├── widgets/          # Reusable UI components
├── db/               # Database layer (DatabaseHelper)
├── repositories/     # Data access layer (TransactionRepository)
└── utils/            # Helper functions (mappers, formatters)
```

#### Database Schema

**Currencies Table:**
```sql
CREATE TABLE currencies(
  code TEXT PRIMARY KEY,      -- e.g., 'USD', 'CAD', 'KRW'
  symbol TEXT,                -- e.g., '$', '₩'
  name TEXT                   -- e.g., 'US Dollar'
)
```

**Accounts Table:**
```sql
CREATE TABLE accounts(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  currencyCode TEXT,
  balance REAL,
  FOREIGN KEY(currencyCode) REFERENCES currencies(code)
)
```

**Transactions Table:**
```sql
CREATE TABLE transactions(
  id TEXT PRIMARY KEY,        -- UUID v4
  title TEXT,
  amount REAL,
  type INTEGER,              -- 1 = income, 0 = expense
  date TEXT,                 -- 'YYYY-MM-DD'
  accountId INTEGER,
  category TEXT,             -- enum.name
  note TEXT,
  recurring TEXT,            -- JSON string for recurring config
  FOREIGN KEY(accountId) REFERENCES accounts(id) ON DELETE CASCADE
)
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0 <4.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Visual Studio (for Windows development)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd budgeting
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### First-Time Setup

When you first launch the app:

1. **Language Selection:** Choose between English and Korean
2. **Currency Selection:** Select your primary currency
3. **Create First Account:** Add your first bank account
4. **Start Tracking:** Begin adding transactions

## Usage Guide

### Adding a Transaction

1. Tap the **+ button** (FloatingActionButton) on the home screen
2. Choose transaction type: **Income** or **Expense**
3. Fill in the details:
   - Title (required)
   - Amount (required)
   - Category (required)
   - Account (required)
   - Date (defaults to today)
   - Note (optional)
4. Tap **Save**

### Editing a Transaction

1. Tap on any transaction card in the list, OR
2. Tap the **edit icon** (pencil) on the transaction card
3. Modify the fields as needed
4. Tap **Save**

### Deleting a Transaction

1. Tap the **delete icon** (trash) on the transaction card
2. Confirm deletion in the dialog

### Using Filters

1. **Filter by Currency:**
   - Tap "By Currency" chip
   - Select a currency from the list
   - View all transactions across all accounts in that currency

2. **Filter by Account:**
   - Tap "By Account" chip
   - Select a specific account
   - View transactions only for that account

3. **Filter by Period:**
   - Select a predefined period (Today, This Month, etc.), OR
   - Choose "Custom" to set a specific date range

4. **Filter by Category:**
   - Tap any category chip to filter
   - Tap "All Categories" to remove category filter

5. **Combine Filters:**
   - All filters work together
   - Example: "CAD currency + Food category + This Month" shows all food expenses in CAD accounts this month

### Understanding the Summary Chart

- **Green Bar:** Total income for the filtered period/accounts
- **Red Bar:** Total expenses for the filtered period/accounts
- **Blue/Orange Bar:** Net balance (blue if positive, orange if negative)
- Hover/tap bars to see exact amounts

## Project Status

### Completed Features ✅
- ✅ Multi-currency support
- ✅ Account management
- ✅ Transaction CRUD operations
- ✅ Advanced filtering (currency, account, period, category)
- ✅ Home screen with transaction list
- ✅ Summary bar chart
- ✅ Onboarding flow
- ✅ Database schema with foreign key constraints
- ✅ Transaction repository pattern
- ✅ State management with Provider

### In Development 🚧
- 🚧 Summary screen with detailed analytics
- 🚧 Settings screen
- 🚧 Category pie charts
- 🚧 Monthly trend charts
- 🚧 Recurring transaction automation
- 🚧 Data export functionality
- 🚧 Multiple language support (EN/KR)

### Future Enhancements 💡
- 💡 Budget limits and alerts
- 💡 Bill reminders
- 💡 Cloud sync
- 💡 Data backup/restore
- 💡 Receipt photo attachments
- 💡 Multiple account transfers
- 💡 Investment tracking
- 💡 Debt management
- 💡 Financial goal setting
- 💡 Dark mode theme

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Development Notes

### Code Style
- Follow Dart/Flutter style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Database Migrations
- Version is managed in `DatabaseHelper._initDB()`
- Current version: 2
- To add migrations, update `_onUpgrade()` method

### Adding New Categories
1. Add to `Category` enum in `lib/models/transaction.dart`
2. Update category icon mapping in `TransactionListItem`
3. Update category color mapping in `TransactionListItem`

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Troubleshooting

### Common Issues

**Issue:** App crashes on first launch
- **Solution:** Ensure database is properly initialized. Check `DatabaseHelper.instance`

**Issue:** Transactions not appearing after adding
- **Solution:** Verify account exists and filters are not hiding the transaction

**Issue:** Foreign key constraint errors
- **Solution:** Ensure currency exists before creating accounts, and account exists before creating transactions

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- FL Chart for beautiful chart components
- SQLite for robust local storage

## Contact

For questions, issues, or suggestions, please open an issue on GitHub.

---

**Version:** 1.0.0+1

**Last Updated:** 2025

**Maintained by:** [Your Name]
