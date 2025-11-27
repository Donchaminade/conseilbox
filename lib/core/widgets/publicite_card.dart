import 'package:flutter/material.dart';

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
                  Text(publicite.title, style: AppTextStyles.title),
                  const SizedBox(height: 8),
                  Text(publicite.content, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
