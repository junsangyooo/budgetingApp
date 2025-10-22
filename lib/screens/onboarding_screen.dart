import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:budgeting/db/database.dart';
import 'package:budgeting/models/account.dart';
import 'package:budgeting/models/currency.dart';
import 'package:budgeting/utils/currency_data.dart';
import 'package:budgeting/providers/locale_provider.dart';
import 'package:budgeting/screens/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgeting/generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Language selection state
  String? _selectedLanguage;
  bool _showAccountSetup = false;
  
  // Account setup state
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0');
  String _selectedCurrency = 'USD';
  
  bool _isLoading = false;

  @override
  void dispose() {
    _accountNameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  /// Step 1: 언어 확인 버튼 클릭
  void _confirmLanguage() {
    if (_selectedLanguage == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectLanguage)),
      );
      return;
    }

    // 앱 전체의 언어를 변경
    context.read<LocaleProvider>().setLocale(_selectedLanguage!);

    // 기본 통화 설정
    setState(() {
      _selectedCurrency = CurrencyData.getDefaultCurrencyForLanguage(_selectedLanguage!);
      _showAccountSetup = true;
    });
  }

  /// Step 2: 설정 완료
  Future<void> _finishSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final db = DatabaseHelper.instance;
      
      // 1. 선택한 통화를 데이터베이스에 추가
      final currencyData = CurrencyData.getCurrency(_selectedCurrency);
      if (currencyData != null) {
        await db.insertCurrency(currencyData.toMap());
      }

      // 2. 첫 번째 계좌 생성
      final account = Account(
        name: _accountNameController.text.trim(),
        currencyCode: _selectedCurrency,
        balance: double.parse(_initialBalanceController.text),
      );
      await db.insertAccount(account.toMap());

      // 3. Onboarding 완료 표시
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);

      if (!mounted) return;

      // 4. 메인 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigation(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorOccurred(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 통화 선택 바텀시트
  void _showCurrencyPicker() {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.currency,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: CurrencyData.allCurrencies.length,
                  itemBuilder: (context, index) {
                    final currency = CurrencyData.allCurrencies[index];
                    final isSelected = currency.code == _selectedCurrency;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[200],
                        child: Text(
                          currency.symbol,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      title: Text(currency.name),
                      subtitle: Text(currency.code),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCurrency = currency.code;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    
                    // Welcome Icon
                    Icon(
                      _showAccountSetup ? Icons.account_balance_wallet : Icons.language,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      _showAccountSetup ? l10n.createFirstAccount : l10n.welcomeTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Subtitle
                    Text(
                      _showAccountSetup ? l10n.setupAccountDesc : l10n.chooseLanguage,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Language Selection (언어 선택 완료 후 사라짐)
                    if (!_showAccountSetup) ...[
                      _buildLanguageCard(
                        context,
                        languageCode: 'en',
                        languageName: l10n.english,
                        flag: '🇺🇸',
                        subtitle: l10n.defaultCurrencyUSD,
                      ),
                      const SizedBox(height: 16),
                      _buildLanguageCard(
                        context,
                        languageCode: 'ko',
                        languageName: l10n.korean,
                        flag: '🇰🇷',
                        subtitle: l10n.defaultCurrencyKRW,
                      ),
                      const SizedBox(height: 24),
                      
                      // Confirm Language Button
                      FilledButton(
                        onPressed: _confirmLanguage,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          l10n.confirm,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                    
                    // Account Setup (언어 선택 후 fade-in)
                    if (_showAccountSetup)
                      AnimatedOpacity(
                        opacity: _showAccountSetup ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Account Name
                              TextFormField(
                                controller: _accountNameController,
                                decoration: InputDecoration(
                                  labelText: l10n.accountName,
                                  hintText: l10n.accountNameHint,
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.account_balance),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.pleaseEnterAccountName;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Currency Selector
                              InkWell(
                                onTap: _showCurrencyPicker,
                                borderRadius: BorderRadius.circular(4),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: l10n.currency,
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.attach_money),
                                    suffixIcon: const Icon(Icons.arrow_drop_down),
                                  ),
                                  child: Text(
                                    CurrencyData.getCurrency(_selectedCurrency)?.toString() ?? 
                                        _selectedCurrency,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Initial Balance
                              TextFormField(
                                controller: _initialBalanceController,
                                decoration: InputDecoration(
                                  labelText: l10n.initialBalance,
                                  hintText: '0.00',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.payments),
                                  prefixText: CurrencyData.getCurrency(_selectedCurrency)?.symbol ?? '\$',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.pleaseEnterBalance;
                                  }
                                  final amount = double.tryParse(value);
                                  if (amount == null) {
                                    return l10n.pleaseEnterValidNumber;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              
                              // Info Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.blue[700]),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        l10n.youCanAddMore,
                                        style: TextStyle(
                                          color: Colors.blue[900],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Finish Button
                              FilledButton(
                                onPressed: _finishSetup,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  l10n.finishSetup,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context, {
    required String languageCode,
    required String languageName,
    required String flag,
    required String subtitle,
  }) {
    final isSelected = _selectedLanguage == languageCode;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = languageCode;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}