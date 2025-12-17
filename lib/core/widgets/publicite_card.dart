import 'package:conseilbox/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import pour le formatage de la date

import '../models/publicite.dart';
import '../../config/app_text_styles.dart';

class PubliciteCard extends StatelessWidget {
  const PubliciteCard({
    super.key,
    required this.publicite,
    this.onTap,
    this.onShare,
  });

  final Publicite publicite;
  final VoidCallback? onTap;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    // Calculer si la publicité est "nouvelle" (moins de 5 jours)
    final bool isNew = publicite.createdAt != null &&
        DateTime.now().difference(publicite.createdAt!).inDays < 5;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (publicite.imageUrl != null)
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      publicite.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Colors.black12,
                        child: Center(child: Icon(Icons.image_not_supported)),
                      ),
                    ),
                  ),
                  if (isNew)
                    Positioned(
                      top: 0, // Position at top edge
                      right: 0, // Position at right edge
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 6, 158, 11)
                              .withOpacity(0.8), // Using AppColors.chocolat
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(
                                16), // Match card border radius top-right
                            bottomLeft: Radius.circular(
                                12), // Styled bottom-left corner
                          ),
                        ),
                        child: const Text(
                          'Nouveau', // A nice "new" emoji
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.black), // Larger font size for emoji
                        ),
                      ),
                    ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          publicite.title,
                          style: AppTextStyles.title.copyWith(
                              fontSize: 16, fontWeight: FontWeight.bold),

                          maxLines: 1, // Limiter le titre à une ligne
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onShare !=
                          null) // Only show share button if callback is provided
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: onShare,
                          visualDensity:
                              VisualDensity.compact, // Make it smaller
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    publicite.content,
                    style: AppTextStyles.body,
                    maxLines: 1, // Tronquer le contenu à une ligne
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (publicite.createdAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Publié le ${DateFormat('dd/MM/yyyy').format(publicite.createdAt!)}',
                      style: AppTextStyles
                          .bodySmall, // Utiliser un style plus petit pour la date
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
