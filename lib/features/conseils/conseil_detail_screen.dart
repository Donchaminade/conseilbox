import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../core/managers/favorites_manager.dart';
import '../../core/models/conseil.dart';

class ConseilDetailScreen extends StatelessWidget {
  const ConseilDetailScreen({
    super.key,
    required this.conseil,
    required this.favorites,
  });

  final Conseil conseil;
  final FavoritesManager favorites;

  @override
  Widget build(BuildContext context) {
    final isFavorite = favorites.isFavorite(conseil);
    final date = conseil.createdAt;
    final socialLinks = conseil.socialLinks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du conseil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () => _shareConseil(),
          ),
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              favorites.toggle(conseil);
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shareConseil,
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text(
          'Partager',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.chocolat,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(conseil.title,
              style: AppTextStyles.title.copyWith(fontSize: 26)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'par ${conseil.author}',
                  style: AppTextStyles.body,
                ),
              ),
              if (date != null)
                Text(
                  MaterialLocalizations.of(context)
                      .formatMediumDate(date.toLocal()),
                  style: AppTextStyles.small,
                ),
            ],
          ),
          if (conseil.location?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.place, size: 16, color: AppColors.chocolat),
                  const SizedBox(width: 4),
                  Text(conseil.location!, style: AppTextStyles.small),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Text(conseil.content,
              style: AppTextStyles.body.copyWith(fontSize: 18)),
          if (conseil.anecdote?.isNotEmpty == true) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.chocolat.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Anecdote', style: AppTextStyles.title),
                  const SizedBox(height: 8),
                  Text(conseil.anecdote!, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
          if (socialLinks.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Réseaux sociaux', style: AppTextStyles.title),
            const SizedBox(height: 8),
            ...socialLinks.map(
              (link) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.link, color: AppColors.chocolat),
                title: Text(link, style: AppTextStyles.body),
                onTap: () => _showComingSoon(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _shareConseil() {
    final message = '${conseil.title} - ${conseil.content}\n'
        'Partagé via ConseilBox';
    Share.share(message);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ouverture du lien bientôt disponible')),
    );
  }
}
