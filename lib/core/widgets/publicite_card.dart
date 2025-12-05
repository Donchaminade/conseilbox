import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import pour le formatage de la date

import '../models/publicite.dart';
import '../../config/app_text_styles.dart';

class PubliciteCard extends StatelessWidget {
  const PubliciteCard({
    super.key,
    required this.publicite,
    this.onTap,
  });

  final Publicite publicite;
  final VoidCallback? onTap;

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
                          style: AppTextStyles.title,
                          maxLines: 1, // Limiter le titre à une ligne
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red, // Couleur pour l'étiquette "Nouveau"
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Nouveau',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                      style: AppTextStyles.bodySmall, // Utiliser un style plus petit pour la date
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
