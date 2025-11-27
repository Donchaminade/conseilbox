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
    final chips = <Widget>[
      if (date != null)
        _DetailChip(
          icon: Icons.calendar_today_outlined,
          label: MaterialLocalizations.of(context)
              .formatMediumDate(date.toLocal()),
        ),
      if (conseil.location?.isNotEmpty == true)
        _DetailChip(
          icon: Icons.place_outlined,
          label: conseil.location!,
        ),
      if (socialLinks.isNotEmpty)
        _DetailChip(
          icon: Icons.link,
          label:
              '${socialLinks.length} lien${socialLinks.length > 1 ? 's' : ''}',
        ),
    ];

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
          _DetailHero(
            title: conseil.title,
            author: conseil.author,
            chips: chips,
          ),
          const SizedBox(height: 24),
          _DetailSection(
            title: 'Le conseil',
            child: Text(
              conseil.content,
              style: AppTextStyles.body.copyWith(fontSize: 18, height: 1.4),
            ),
          ),
          if (conseil.anecdote?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _DetailSection(
              title: 'Anecdote',
              background: AppColors.chocolat.withValues(alpha: 0.05),
              child: Text(conseil.anecdote!, style: AppTextStyles.body),
            ),
          ],
          if (socialLinks.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailSection(
              title: 'Réseaux sociaux',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: socialLinks
                    .map(
                      (link) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => _showComingSoon(context),
                          child: Row(
                            children: [
                              const Icon(Icons.link,
                                  size: 18, color: AppColors.chocolat),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  link,
                                  style: AppTextStyles.body,
                                ),
                              ),
                              const Icon(Icons.open_in_new,
                                  size: 16, color: AppColors.chocolat),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
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

class _DetailHero extends StatelessWidget {
  const _DetailHero({
    required this.title,
    required this.author,
    required this.chips,
  });

  final String title;
  final String author;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppColors.chocolat,
            AppColors.cafe.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cafe.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title.copyWith(
              color: Colors.white,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: Icon(Icons.person,
                    color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Par $author',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.child,
    this.background = Colors.transparent,
  });

  final String title;
  final Widget child;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: background == Colors.transparent
              ? AppColors.chocolat.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
