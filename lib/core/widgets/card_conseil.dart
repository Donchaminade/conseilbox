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
    final metadata = [
      if (location != null) location,
      formattedDate,
    ].join(' • ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(conseil.title, style: AppTextStyles.title),
                        const SizedBox(height: 4),
                        Text(
                          'par ${conseil.author}',
                          style: AppTextStyles.small,
                        ),
                      ],
                    ),
                  ),
                  if (!conseil.isPublished)
                    Chip(
                      label: const Text('En attente'),
                      backgroundColor:
                          AppColors.chocolat.withValues(alpha: 0.1),
                      labelStyle: AppTextStyles.label
                          .copyWith(color: AppColors.chocolat),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                conseil.content,
                style: AppTextStyles.body,
              ),
              if (conseil.anecdote?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.chocolat.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Anecdote: ${conseil.anecdote!}',
                    style: AppTextStyles.body,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text(metadata, style: AppTextStyles.small)),
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
            ],
          ),
        ),
      ),
    );
  }
}
