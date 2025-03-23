import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_layout.dart';
import '../widgets/language_selector.dart';
import '../providers/language_provider.dart';
import '../utils/translation_extension.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: context.tr('language_settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            if (languageProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Introduction text
                Text(
                  context.tr('language_settings_description'),
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),

                // Language selector
                const LanguageSelector(),
                const SizedBox(height: 16),

                // Preview of language settings
                const LanguageDisplaySample(),
                const SizedBox(height: 24),

                // Invoice language settings
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('invoice_language_settings'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Invoice language options
                        CheckboxListTile(
                          title: Text(context.tr('enable_multilingual_invoices')),
                          subtitle: Text(context.tr('enable_multilingual_invoices_description')),
                          value: true, // This would be a setting value
                          onChanged: (value) {
                            // Update setting
                          },
                        ),

                        const SizedBox(height: 8),

                        // Default invoice language
                        ListTile(
                          title: Text(context.tr('default_invoice_language')),
                          subtitle: Text(languageProvider.currentLanguage.name),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Show language selector dialog
                            _showLanguageDialog(context);
                          },
                        ),

                        // Allow customer-specific language preference
                        CheckboxListTile(
                          title: Text(context.tr('customer_language_preference')),
                          subtitle: Text(context.tr('customer_language_preference_description')),
                          value: true, // This would be a setting value
                          onChanged: (value) {
                            // Update setting
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Call to action - how to add translations
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('custom_translations'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(context.tr('custom_translations_description')),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: Text(context.tr('manage_custom_translations')),
                          onPressed: () {
                            // Navigate to custom translations editor
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('select_default_invoice_language')),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<LanguageProvider>(
            builder: (context, languageProvider, _) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: 5, // Just show the most common 5 languages
                itemBuilder: (context, index) {
                  final languages = [
                    IndianLanguages.english,
                    IndianLanguages.hindi,
                    IndianLanguages.marathi,
                    IndianLanguages.tamil,
                    IndianLanguages.bengali,
                  ];
                  final language = languages[index];

                  return ListTile(
                    leading: Text(language.flagIcon, style: TextStyle(fontSize: 20)),
                    title: Text(language.name),
                    subtitle: Text(language.localName),
                    trailing: language.code == languageProvider.currentLanguage.code
                        ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                        : null,
                    onTap: () {
                      // Set as default invoice language
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr('cancel')),
          ),
        ],
      ),
    );
  }
}
