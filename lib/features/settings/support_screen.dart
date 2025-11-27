import 'package:flutter/material.dart';

import '../../config/app_text_styles.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      ('Email', 'hello@conseilbox.com'),
      ('WhatsApp', '+228 91 00 00 00'),
      ('Telegram', '@ConseilBox'),
    ];

    final faqs = [
      'Comment proposer un contenu ?',
      'Quels formats sont acceptés ?',
      'Comment retirer un témoignage ?',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support & contact'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Contacts directs', style: AppTextStyles.title),
          const SizedBox(height: 12),
          ...contacts.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text(item.$1, style: AppTextStyles.body),
              subtitle: Text(item.$2, style: AppTextStyles.small),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lien ${item.$1} à configurer')),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text('FAQ express', style: AppTextStyles.title),
          const SizedBox(height: 12),
          ...faqs.map(
            (question) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(question, style: AppTextStyles.body),
                subtitle: const Text(
                  'Réponse détaillée à venir.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
