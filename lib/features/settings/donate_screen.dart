import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy me a coffee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merci de soutenir ConseilBox',
              style: AppTextStyles.title.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 12),
            Text(
              'Chaque contribution nous aide à financer l’hébergement, la modération '
              'et la création de nouveaux contenus inspirants.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.chocolat.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Formules suggerees'),
                  SizedBox(height: 8),
                  Text('• 5€ : offrir un cafe a l’equipe'),
                  Text('• 15€ : soutenir une interview'),
                  Text('• 50€ : sponsoriser une capsule video'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lien de paiement à ajouter'),
                  ),
                );
              },
              icon: const Icon(Icons.coffee),
              label: const Text('Ouvrir la page de don'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.chocolat,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
