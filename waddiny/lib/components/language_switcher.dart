import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../contexts/language_provider.dart';
import '../main.dart'; // Import to use getLocalizations helper

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the correct localizations using the helper function
    final localizations = getLocalizations(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  localizations.language,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.current(_getCurrentLanguageFlag(context),
                  _getCurrentLanguageName(context)),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.tapLanguageToChange,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildLanguageButton(context, 'ar', '🇸🇦', 'العربية'),
                _buildLanguageButton(context, 'en', '🇺🇸', 'English'),
                _buildLanguageButton(context, 'ku', '🇮🇶', 'کوردی'),
                _buildLanguageButton(context, 'tr', '🇹🇷', 'Türkçe'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String languageCode,
    String flag,
    String languageName,
  ) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isSelected = languageProvider.locale.languageCode == languageCode;

    return GestureDetector(
      onTap: () => _changeLanguage(context, languageCode, languageName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              languageName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentLanguageFlag(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    switch (languageProvider.locale.languageCode) {
      case 'ar':
        return '🇸🇦';
      case 'en':
        return '🇺🇸';
      case 'ku':
        return '🇮🇶';
      case 'tr':
        return '🇹🇷';
      default:
        return '🇸🇦';
    }
  }

  String _getCurrentLanguageName(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    switch (languageProvider.locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'ku':
        return 'کوردی';
      case 'tr':
        return 'Türkçe';
      default:
        return 'العربية';
    }
  }

  Future<void> _changeLanguage(
    BuildContext context,
    String languageCode,
    String languageName,
  ) async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    // Don't change if already selected
    if (languageProvider.locale.languageCode == languageCode) {
      return;
    }

    await languageProvider.changeLanguage(languageCode);

    // Show confirmation
    if (context.mounted) {
      final localizations = getLocalizations(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.languageChangedTo(languageName)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
