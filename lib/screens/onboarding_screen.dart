import 'package:flutter/material.dart';
import 'package:budgeting/screens/onboarding/account_setup_screen.dart';
import 'package:budgeting/utils/currency_data.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  void _continue() {
    if (_selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language')),
      );
      return;
    }

    final defaultCurrency = CurrencyData.getDefaultCurrencyForLanguage(_selectedLanguage!);
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AccountSetupScreen(
          languageCode: _selectedLanguage!,
          defaultCurrency: defaultCurrency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Welcome Icon
              Icon(
                Icons.language,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Welcome to Budget Tracker',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Choose your preferred language',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Language Options
              Expanded(
                child: Column(
                  children: [
                    _buildLanguageCard(
                      context,
                      languageCode: 'en',
                      languageName: 'English',
                      flag: '🇺🇸',
                      subtitle: 'Default currency: USD',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageCard(
                      context,
                      languageCode: 'ko',
                      languageName: '한국어',
                      flag: '🇰🇷',
                      subtitle: 'Default currency: KRW',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Continue Button
              FilledButton(
                onPressed: _continue,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
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