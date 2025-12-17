import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../models/conseil.dart';

class CardConseil extends StatelessWidget {
  const CardConseil({
    super.key,
    required this.conseil,
    this.onTap,
    this.onShare,
    this.onFavorite,
    this.isFavorite = false,
  });

  final Conseil conseil;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final formattedDate = conseil.createdAt != null
        ? DateFormat.yMMMd('fr_FR').format(conseil.createdAt!)
        : 'Date inconnue';

    final location =
        conseil.location?.isNotEmpty == true ? conseil.location : null;
    final initials = conseil.author.trim();

    final socialLinks = [
      conseil.socialLink1,
      conseil.socialLink2,
      conseil.socialLink3,
    ].whereType<String>().where((link) => link.isNotEmpty).toList();
    final socialCount = socialLinks.length;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        color: AppColors.blanc,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    AppColors.blanc,
                    AppColors.chocolat.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                    color: AppColors.chocolat.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.chocolat.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppColors.chocolat.withValues(alpha: 0.15),
                        foregroundColor: AppColors.chocolat,
                        radius: 24,
                        child: Text(
                          initials.isNotEmpty ? initials[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(conseil.title,
                                style:
                                    AppTextStyles.title.copyWith(fontSize: 20)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.person_outline,
                                    size: 16, color: AppColors.chocolat),
                                const SizedBox(width: 4),
                                Text(
                                  conseil.author,
                                  style: AppTextStyles.small,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: onShare,
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? AppColors.chocolat : null,
                        ),
                        onPressed: onFavorite,
                      ),
                    ],
                  ),
                  if (!conseil.isPublished) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: const Text('En attente'),
                      backgroundColor:
                          AppColors.chocolat.withValues(alpha: 0.1),
                      labelStyle: AppTextStyles.label
                          .copyWith(color: AppColors.chocolat),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    conseil.content,
                    style: AppTextStyles.body.copyWith(fontSize: 16),
                    maxLines: 2, // Réduit à une ligne
                    overflow:
                        TextOverflow.ellipsis, // Ajouter des points de suspension
                  ),
                  if (conseil.anecdote?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.chocolat.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: AppColors.chocolat),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              conseil.anecdote!,
                              style: AppTextStyles.body,
                              maxLines: 2, // Limiter à deux lignes
                              overflow: TextOverflow
                                  .ellipsis, // Ajouter des points de suspension
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (location != null)
                        _MetaChip(
                          icon: Icons.place_outlined,
                          label: location,
                        ),
                      _MetaChip(
                        icon: Icons.calendar_today_outlined,
                        label: formattedDate,
                      ),
                      if (socialCount > 0)
                        _MetaChip(
                          icon: Icons.link,
                          label:
                              '$socialCount lien${socialCount > 1 ? 's' : ''}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (conseil.isNew)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.chocolat.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '🎖️',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            if (isFavorite) // Added new Positioned widget for favorite badge
              Positioned(
                top: 0,
                left: 0, // Positioned on the top-left
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.chocolat.withOpacity(0.8), // Same color for consistency
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20), // Top-left corner
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '🎀',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.chocolat.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.chocolat),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.small),
        ],
      ),
    );
  }
}
