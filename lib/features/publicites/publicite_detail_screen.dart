import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../core/models/publicite.dart';

class PubliciteDetailScreen extends StatelessWidget {
  const PubliciteDetailScreen({super.key, required this.publicite});

  final Publicite publicite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace pub'),
      ),
      body: SizedBox(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _HeroBanner(publicite: publicite),
            const SizedBox(height: 24),
            Text(publicite.content,
                style: AppTextStyles.body.copyWith(fontSize: 18)),
            const SizedBox(height: 24),
            _InfoTile(
              icon: Icons.public,
              label: 'Lien cible',
              value: publicite.targetUrl ?? 'Bientôt disponible',
            ),
            _InfoTile(
              icon: Icons.check_circle_outline,
              label: 'Statut',
              value: publicite.isActive ? 'Active' : 'Inactive',
            ),
            if (publicite.createdAt != null)
              _InfoTile(
                icon: Icons.calendar_today_outlined,
                label: 'Publié le',
                value: MaterialLocalizations.of(context)
                    .formatMediumDate(publicite.createdAt!.toLocal()),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.publicite});

  final Publicite publicite;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        height: 220,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (publicite.imageUrl != null)
              Image.network(
                publicite.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.chocolat.withValues(alpha: 0.1),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported),
                ),
              )
            else
              Container(
                color: AppColors.chocolat.withValues(alpha: 0.1),
                alignment: Alignment.center,
                child: const Icon(Icons.image, size: 48),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Text(
                publicite.title,
                style: AppTextStyles.title.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.chocolat),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.small),
                  const SizedBox(height: 4),
                  Text(value, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
