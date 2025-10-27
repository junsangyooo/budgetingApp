# 💰 Multi-Currency Budgeting App

A powerful Flutter-based personal finance management application for tracking income and expenses across multiple currencies, accounts, and categories with advanced analytics and automation features.

**Languages:** English 🇬🇧 | Korean 🇰🇷

---

## 📋 Overview

This budgeting application helps you manage your finances efficiently by:

- 📊 Tracking transactions (income & expenses) across multiple accounts
- 💱 Supporting multiple currencies simultaneously
- 📈 Visualizing financial data with charts (monthly bar chart, category pie chart)
- 🎯 Filtering by currency, account, period, and category
- 🔄 Managing subscriptions with automatic transaction generation
- ⚙️ Customizing accounts and settings

---

## ✨ Features

### 🏠 Home Screen - Transaction Management

- **Transaction CRUD Operations**
  - Add, edit, delete transactions with full details
  - Attach notes to transactions
  - Set custom transaction dates
  - Support for recurring transactions

- **Advanced Filtering**
  - Filter by currency (view all accounts in a currency)
  - Filter by specific account
  - Filter by period (All Time, Today, This Week, This Month, This Year, Custom Date Range)
  - Filter by category (multi-select)
  - Combine multiple filters for precise results

- **Real-Time Summary Chart**
  - Green bar: Total income
  - Red bar: Total expenses
  - Blue/Orange bar: Net balance (positive/negative)
  - Updates dynamically with active filters

- **Transaction List**
  - Chronologically sorted (newest first)
  - Category icons and color coding
  - Quick edit/delete buttons
  - Account and currency display

### 📊 Summary Screen - Analytics & Insights

- **Monthly Net Stats**
  - Bar chart showing 12 months of income vs. expenses
  - Smart month range (current month only if no history, January to current if data exists)
  - Y-axis with formatted amounts (k, M notation)
  - Locale-aware month labels (English: Jan, Feb; Korean: 1월, 2월)
  - Account/currency filter integration

- **Category Breakdown**
  - Pie chart showing expense distribution by category
  - Expandable period filter (1 Day, 1 Week, 1 Month, 3 Months, 6 Months, 12 Months)
  - Expandable category filter (multi-select)
  - Color-coded categories
  - Legend with percentage breakdown
  - Filters appear between Monthly Stats and Category Breakdown

- **Overall Filter Bar**
  - Top-level account/currency filter affecting all charts
  - Matches home screen filter behavior

### ⚙️ Settings Screen - Configuration & Management

#### 1. Subscriptions Tab
- **Add Subscriptions**
  - Subscription name
  - Amount (numeric only)
  - Paying account (dropdown)
  - Paying date (day of month, 1-31)
  - Optional end date

- **Subscription Management**
  - View all active subscriptions
  - Edit existing subscriptions
  - Delete subscriptions with confirmation
  - Auto-transaction creation on subscription due date

- **Auto-Transaction Features**
  - Automatically creates expense transactions on paying date
  - Prevents duplicate daily transactions using `lastCreatedDate` tracking
  - Transaction categorized as "subscription"
  - Respects subscription start/end dates

#### 2. Accounts Tab
- **View All Accounts**
  - Account name and balance display
  - Currency symbol and code
  - Account balance shown in subtitle

- **Create New Account**
  - Account name (required)
  - Currency selection (required)
  - Initial balance (numeric, optional, defaults to 0.00)
  - Automatic balance updates with transactions

- **Account Management**
  - Delete accounts (with confirmation)
  - Balances update based on transaction history

#### 3. Language Tab
- **Bilingual Support**
  - English (English)
  - Korean (한국어)
  - Change language with instant app refresh
  - All content includes both languages

---

## 🗂️ Technology Stack

### Framework & Language
- **Flutter** (Dart 3.0+)
- Cross-platform: iOS, Android, macOS, Windows, Linux

### Key Dependencies
- **State Management:** Provider (^6.1.1)
- **Database:** SQLite via sqflite (^2.3.0)
- **Charts:** FL Chart (^0.66.0)
- **Localization:** Flutter Localizations + intl (^0.20.2)
- **UUID Generation:** uuid (^4.2.2)
- **Utilities:** shared_preferences (^2.5.3)

### Architecture

#### MVVM Pattern
```
lib/
├── models/
│   ├── transaction.dart
│   ├── account.dart
│   ├── subscription.dart
│   ├── filter_state.dart
│   └── currency.dart
├── viewmodels/
│   ├── home_view_model.dart
│   └── summary_view_model.dart
├── screens/
│   ├── home_screen.dart
│   ├── summary_screen.dart
│   ├── setting_screen.dart
│   ├── main_navigation.dart
│   └── onboarding_screen.dart
├── widgets/
│   ├── transaction_list.dart
│   ├── transaction_dialog.dart
│   ├── filter_bar.dart
│   ├── summary_chart.dart
│   ├── monthly_chart.dart
│   └── category_pie_chart.dart
├── db/
│   └── database.dart
├── repositories/
│   └── transaction_repository.dart
├── utils/
│   ├── currency_data.dart
│   ├── mappers.dart
│   └── subscription_service.dart
└── l10n/
    ├── app_en.arb
    └── app_ko.arb
```

#### Database Schema (Version 4)

**Currencies Table**
```sql
CREATE TABLE currencies(
  code TEXT PRIMARY KEY,
  symbol TEXT,
  name TEXT
)
```

**Accounts Table**
```sql
CREATE TABLE accounts(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  currencyCode TEXT,
  balance REAL,
  FOREIGN KEY(currencyCode) REFERENCES currencies(code)
)
```

**Transactions Table**
```sql
CREATE TABLE transactions(
  id TEXT PRIMARY KEY,          -- UUID v4
  title TEXT,
  amount REAL,
  type INTEGER,                 -- 1 = income, 0 = expense
  date TEXT,                    -- 'YYYY-MM-DD'
  accountId INTEGER,
  category TEXT,
  note TEXT,
  recurring TEXT,               -- JSON string
  FOREIGN KEY(accountId) REFERENCES accounts(id) ON DELETE CASCADE
)
```

**Subscriptions Table**
```sql
CREATE TABLE subscriptions(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  amount REAL NOT NULL,
  accountId INTEGER NOT NULL,
  startDate TEXT NOT NULL,
  endDate TEXT,
  frequency TEXT NOT NULL,      -- 'monthly'
  payingDate INTEGER NOT NULL,  -- 1-31
  lastCreatedDate TEXT,         -- Prevents duplicate daily creation
  FOREIGN KEY(accountId) REFERENCES accounts(id) ON DELETE CASCADE
)
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0 <4.0.0)
- Dart SDK
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd budgeting
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### First-Time Setup

1. **Language Selection** - Choose English or Korean
2. **Currency Selection** - Select your primary currency
3. **Create First Account** - Add your first account with optional initial balance
4. **Start Tracking** - Begin adding transactions

---

## 📖 Usage Guide

### Adding a Transaction

1. Tap the **+** button on the home screen
2. Select transaction type (Income/Expense)
3. Fill in required details:
   - Title
   - Amount
   - Category
   - Account
   - Date (defaults to today)
4. Add optional note
5. Tap **Save**

### Editing & Deleting Transactions

- **Edit:** Tap on transaction card or tap the edit icon
- **Delete:** Tap the delete icon and confirm

### Using Filters

**Combine filters for precise results:**
- Currency + Account + Period + Category

Example: "CAD + Savings Account + This Month + Food" shows all food expenses in your Savings Account for this month

### Managing Accounts

1. Go to **Settings → Accounts**
2. View all accounts with their balances
3. **Add Account:**
   - Account name
   - Currency
   - Initial balance (numeric only)
4. **Delete Account:** Tap account menu → Delete

### Managing Subscriptions

1. Go to **Settings → Subscriptions**
2. **Add Subscription:**
   - Subscription name
   - Amount (numeric only)
   - Paying account
   - Paying date (1-31)
   - Optional end date
3. **Edit/Delete:** Use account menu options

**Auto-Transaction Feature:**
- On subscription due date, app automatically creates an expense transaction
- Prevents duplicate daily creation using `lastCreatedDate` tracking
- Transaction appears in transaction list with "Subscription: {name}" format

### Summary & Analytics

- **Monthly Stats:** Shows 12-month income/expense trends
- **Category Breakdown:** Pie chart with period selection (1d, 1w, 1m, 3m, 6m, 12m)
- **Filters:** Apply account/currency filter to all charts simultaneously

---

## 📱 Device Installation

### iOS (iPhone 16 Pro or later)

1. Connect iPhone via USB
2. Enable Developer Mode:
   - Settings → Privacy & Security → Developer Mode → ON
3. Trust development certificate:
   - Settings → General → VPN & Device Management → Trust certificate
4. Build and run:
   ```bash
   flutter run --release
   ```

### Android

1. Connect Android device via USB
2. Build APK:
   ```bash
   flutter build apk --release
   ```
3. Install APK on device or use:
   ```bash
   flutter run --release
   ```

---

## ✅ Project Status

### Completed Features ✅
- ✅ Multi-currency support with 20+ currencies
- ✅ Account management with initial balance
- ✅ Transaction CRUD operations
- ✅ Advanced filtering (currency, account, period, category)
- ✅ Home screen with transaction list
- ✅ Summary screen with monthly bar chart
- ✅ Category breakdown pie chart
- ✅ Subscription management
- ✅ Auto-transaction creation for subscriptions
- ✅ Bilingual support (English/Korean)
- ✅ Database with proper foreign key constraints (v4)
- ✅ State management with Provider
- ✅ MVVM architecture

### In Development 🚧
- 🚧 Budget limits and alerts
- 🚧 Data export functionality
- 🚧 Receipt photo attachments

### Future Enhancements 💡
- 💡 Bill reminders
- 💡 Cloud sync with Firebase
- 💡 Data backup/restore
- 💡 Investment tracking
- 💡 Debt management
- 💡 Financial goal setting
- 💡 Dark mode theme
- 💡 Multiple account transfers
- 💡 Advanced reports

---

## 🛠️ Development Notes

### Database Migrations
- Current version: 4
- Manage in `DatabaseHelper._initDB()` and `_onUpgrade()`
- Version 4 added subscriptions table and lastCreatedDate column

### Localization
- Add strings to `lib/l10n/app_en.arb` and `lib/l10n/app_ko.arb`
- Regenerate: `flutter gen-l10n`

### Code Style
- Follow Dart/Flutter style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 🐛 Troubleshooting

### Common Issues

**App crashes on first launch**
- Solution: Ensure database is properly initialized

**Transactions not appearing**
- Solution: Check filters aren't hiding transactions

**Subscription transactions not creating**
- Solution: Ensure subscription due date is today or earlier, and app has been opened today

**Input field accepts non-numeric characters**
- Solution: All numeric input fields use `FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))`

---

## 📄 License

MIT License - See LICENSE file for details

---

## 👨‍💻 Author

**Developed by:** 준상 (Junsang Yoo)

---

## 📞 Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

**Version:** 2.0.0

**Last Updated:** January 2025

**Platforms:** iOS | Android | macOS | Windows | Linux
