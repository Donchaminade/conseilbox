import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

class ServiceRequestScreen extends StatelessWidget {
  const ServiceRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demander un service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Besoin d\'accompagnement ?',
              style: AppTextStyles.title.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 12),
            Text(
              'Kaizen propose des prestations sur-mesure pour les entreprises, '
              'communautes et institutions.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),
            const Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Services populaires'),
                    SizedBox(height: 8),
                    Text('• Coaching de prise de parole'),
                    Text('• Facilitation d\'ateliers collaboratifs'),
                    Text('• Production de podcasts / capsules'),
                    Text('• Coaching de prise de parole'),
                    Text('• Facilitation d\'ateliers collaboratifs'),
                    Text('• Production de podcasts / capsules'),
                    Text('• Coaching de prise de parole'),
                    Text('• Facilitation d\'ateliers collaboratifs'),
                    Text('• Production de podcasts / capsules'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Contactez-nous à l\'adresse chaminade.dondah,adjolou@gmail.com'),
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Remplir une demande'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: AppColors.chocolat),
                foregroundColor: AppColors.chocolat,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
