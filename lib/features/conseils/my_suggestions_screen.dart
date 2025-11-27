import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../core/managers/favorites_manager.dart';
import '../../core/models/conseil.dart';
import '../../core/widgets/card_conseil.dart';
import 'conseil_detail_screen.dart';

class MySuggestionsScreen extends StatelessWidget {
  const MySuggestionsScreen({
    super.key,
    required this.suggestions,
    required this.favorites,
    required this.onCreate,
  });

  final List<Conseil> suggestions;
  final FavoritesManager favorites;
  final Future<void> Function() onCreate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes suggestions'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onCreate,
        backgroundColor: AppColors.chocolat,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: suggestions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Vous n’avez pas encore proposé de conseil. Touchez “+” pour partager votre première suggestion.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                  bottom: 120, left: 16, right: 16, top: 16),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final conseil = suggestions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CardConseil(
                    conseil: conseil,
                    onTap: () => _openDetail(context, conseil),
                    onShare: () => _share(conseil),
                    onFavorite: () {
                      favorites.toggle(conseil);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            favorites.isFavorite(conseil)
                                ? 'Ajouté aux favoris'
                                : 'Retiré des favoris',
                          ),
                        ),
                      );
                    },
                    isFavorite: favorites.isFavorite(conseil),
                  ),
                );
              },
            ),
    );
  }

  void _openDetail(BuildContext context, Conseil conseil) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConseilDetailScreen(
          conseil: conseil,
          favorites: favorites,
        ),
      ),
    );
  }

  void _share(Conseil conseil) {
    final message =
        '${conseil.title}\n${conseil.content}\nPartagé via ConseilBox';
    Share.share(message);
  }
}
