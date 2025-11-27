import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final socials = [
      (Icons.business_center, 'LinkedIn'),
      (Icons.play_circle_outline, 'YouTube'),
      (Icons.menu_book_outlined, 'Medium'),
      (Icons.camera_alt_outlined, 'Instagram'),
      (Icons.videocam_outlined, 'TikTok'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/kaizen.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'À propos de ConseilBox',
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  'Une initiative portée par Kaizen pour valoriser les voix et '
                  'expériences communautaires, amplifier les parcours inspirants '
                  'et créer un espace d’entraide authentique.',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/irokou.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Irene Amedji',
                        style: AppTextStyles.title
                            .copyWith(color: Colors.white, fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Project Manager • Quantum Enthusiast\nCommunity Manager',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Réseaux sociaux',
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final social in socials)
                      Chip(
                        avatar: Icon(
                          social.$1,
                          color: AppColors.blanc,
                          size: 18,
                        ),
                        label: Text(
                          social.$2,
                          style: const TextStyle(color: AppColors.blanc),
                        ),
                        backgroundColor:
                            AppColors.chocolat.withValues(alpha: 0.4),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
