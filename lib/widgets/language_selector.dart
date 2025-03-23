import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/language_model.dart';
import '../providers/language_provider.dart';
import '../utils/translation_extension.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.currentLanguage;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('language_settings'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('select_language'),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: IndianLanguages.supportedLanguages.map((language) {
                final isSelected = language.code == currentLanguage.code;
                return InkWell(
                  onTap: () {
                    languageProvider.setLanguage(language.code);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          language.flagIcon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language.localName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              language.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white70 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('language_note'),
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageDisplaySample extends StatelessWidget {
  const LanguageDisplaySample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('language_preview'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(context.tr('sample_invoice_number')),
              subtitle: Text("INV-2023-001"),
            ),
            ListTile(
              title: Text(context.tr('sample_amount')),
              subtitle: Text(context.formatCurrency(1250000.50)),
            ),
            ListTile(
              title: Text(context.tr('sample_amount_in_words')),
              subtitle: Text(context.numberToWords(1250000.50)),
            ),
            ListTile(
              title: Text(context.tr('sample_gstin')),
              subtitle: Text("22AAAAA0000A1Z5"),
            ),
          ],
        ),
      ),
    );
  }
}
