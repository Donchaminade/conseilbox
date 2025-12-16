import 'dart:async';

import 'package:conseilbox/core/network/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';
import '../../core/managers/favorites_manager.dart';
import '../../core/models/conseil.dart';
import '../../core/models/paginated_response.dart';
import '../../core/models/publicite.dart';
import '../../core/services/conseil_service.dart';
import '../../core/services/publicite_service.dart';
import '../../core/widgets/card_conseil.dart';
import '../../core/widgets/custom_navbar.dart';
import '../../core/widgets/publicite_card.dart';
import '../../shared/widgets/bgstyle.dart';
import '../conseils/conseil_detail_screen.dart';
import '../conseils/my_suggestions_screen.dart';
import '../conseils/widgets/conseil_form_sheet.dart';
import '../publicites/publicite_detail_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConseilService _conseilService = ConseilService();
  final PubliciteService _publiciteService = PubliciteService();
  final FavoritesManager _favoritesManager = FavoritesManager();
  final ScrollController _conseilsScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final PageController _carouselController =
      PageController(viewportFraction: 0.9);
  final TextEditingController _publiciteSearchController = TextEditingController();
  Map<String, dynamic> _publiciteFilters = {'order': 'latest', 'status': 'active'};

  int _index = 0;
  bool _loadingConseils = false;
  bool _loadingMore = false;
  String? _conseilsError;
  List<Conseil> _conseils = [];
  final List<Conseil> _mySuggestions = [];
  PaginatedResponse<Conseil>? _pagination;
  Map<String, dynamic> _filters = {'order': 'latest', 'status': 'published'};

  bool _loadingPublicites = false;
  String? _publicitesError;
  List<Publicite> _publicites = [];
  int _carouselIndex = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _favoritesManager.addListener(_handleFavoritesChanged);
    _fetchConseils();
    _fetchPublicites();
    _conseilsScrollController.addListener(_onScroll);
    _scheduleCarouselTimer();
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_handleFavoritesChanged);
    _conseilsScrollController.dispose();
    _searchController.dispose();
    _publiciteSearchController.dispose(); // Dispose du nouveau controller
    _carouselController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchConseils({bool reset = true}) async {
    if (!mounted) return;
    if (reset) {
      setState(() {
        _loadingConseils = true;
        _conseilsError = null;
      });
    } else {
      setState(() {
        _loadingMore = true;
      });
    }

    try {
            final response = await _conseilService.fetchConseils(
              page: reset ? 1 : (_pagination?.nextPage ?? 1),
              limit: 10, // Changed from perPage to limit
              status: _filters['status'] as String?,
              author: _filters['author'] as String?,
              location: _filters['location'] as String?,
              search: _filters['search'] as String?,
              sortBy: 'created_at', // Added sortBy with default value
              order: (_filters['order'] as String?) ?? 'DESC', // Updated default order
            );
      
            if (!mounted) return;
            setState(() {
              _pagination = response;
              if (reset) {
                _conseils = response.items;
              } else {
                // Ensure response.items is not null before spreading, though PaginatedResponse should handle this
                _conseils = [..._conseils, ...response.items];
              }
            });
          } catch (error) {
            if (!mounted) return;
            setState(() {
              _conseilsError =
                  error is ApiException ? error.message : error.toString();
            });
          } finally {
            if (mounted) {
              if (reset) {
                setState(() => _loadingConseils = false);
              } else {
                setState(() => _loadingMore = false);
              }
            }
          }
        }
      
  Future<void> _fetchPublicites({bool reset = true}) async {
    if (!mounted) return;
    if (reset) {
      setState(() {
        _loadingPublicites = true;
        _publicitesError = null;
      });
    } else {
      // Publicites currently don't have infinite scrolling, so reset logic isn't strictly needed for loadingMore here.
      // Keeping consistent for future extensions.
      setState(() {
        _loadingMore = true; // This might not be entirely accurate for publicites if not paginated beyond first call.
      });
    }

    try {
      final response = await _publiciteService.fetchPublicites(
        page: 1, // Publicites usually fetched all at once or separate pagination for carousel
        limit: 15, // As per current usage in _buildCarouselSection
        search: _publiciteFilters['search'] as String?,
        sortBy: 'created_at', // Assuming 'created_at' as default sort for publicites as well
        order: (_publiciteFilters['order'] as String?) ?? 'DESC',
      );

      if (!mounted) return;
      setState(() {
        _publicites = response.items; // Corrected: assign items from PaginatedResponse
        _carouselIndex = 0;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _publicitesError =
            error is ApiException ? error.message : error.toString();
      });
    } finally {
      _scheduleCarouselTimer();
      if (mounted) {
        if (reset) {
          setState(() => _loadingPublicites = false);
        } else {
          setState(() => _loadingMore = false);
        }
      }
    }
  }
      
        void _onScroll() {
          final hasMore = _pagination?.hasMore ?? false;
          if (!hasMore) return;
          if (_loadingMore) return;
      
          if (_conseilsScrollController.position.pixels >
              _conseilsScrollController.position.maxScrollExtent - 200) {
            _fetchConseils(reset: false);
          }
        }
      
        void _restartCarouselTimer({required int itemCount}) {
          _carouselTimer?.cancel();
          if (itemCount < 2) {
            return;
          }
      
          _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
            if (!_carouselController.hasClients) return;
            final nextPage = (_carouselIndex + 1) % itemCount;
            _carouselController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        }
      
        void _scheduleCarouselTimer() {
          final length =
              _publicites.isEmpty ? _defaultCarouselItems.length : _publicites.length;
          if (_carouselIndex >= length) {
            _carouselIndex = 0;
          }
          _restartCarouselTimer(itemCount: length);
        }
      
        void _handleFavoritesChanged() {
          if (!mounted) return;
          setState(() {});
        }
      
        void _toggleFavorite(Conseil conseil) {
          _favoritesManager.toggle(conseil);
          final isNowFavorite = _favoritesManager.isFavorite(conseil);
          _showToast(
            isNowFavorite ? 'Ajouté aux favoris' : 'Retiré des favoris',
          );
          setState(() {});
        }
      
        Future<void> _openDetail(Conseil conseil) async {
          final changed = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ConseilDetailScreen(
                conseil: conseil,
                favorites: _favoritesManager,
              ),
            ),
          );
      
          if (changed == true && mounted) {
            setState(() {});
          }
        }
      
        void _shareConseil(Conseil conseil) {
          final content =
              '${conseil.title}\n${conseil.content}\nPartagé via ConseilBox';
          Share.share(content);
        }
      
        Future<void> _openSuggestions() async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MySuggestionsScreen(
                suggestions: _mySuggestions,
                favorites: _favoritesManager,
                onCreate: _handleSuggestionCreate,
              ),
            ),
          );
        }
      
        Future<void> _handleSuggestionCreate() async {
          final beforeCount = _mySuggestions.length;
          await _openCreateSheet();
          if (mounted && _mySuggestions.length > beforeCount) {
            setState(() {});
          }
        }
      
        void _openPubliciteDetail(Publicite publicite) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PubliciteDetailScreen(publicite: publicite),
            ),
          );
        }
      
        Future<void> _openCreateSheet() async {
          final Conseil? created = await showModalBottomSheet<Conseil>(
            context: context,
            isScrollControlled: true,
            builder: (_) => ConseilFormSheet(service: _conseilService),
          );
      
          if (created != null && mounted) {
            setState(() {
              _conseils = [created, ..._conseils];
              _mySuggestions.insert(0, created);
            });
      
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Conseil soumis ! Il apparaîtra après validation.',
                      ),
                    ),
                  );
                  _openSuggestions();          }
        }
      
        void _applySearch() {
          setState(() {
            _filters = {
              ..._filters,
              'search': _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
            };
          });
          _fetchConseils();
        }
      
        @override
        Widget build(BuildContext context) {
          return Scaffold(
            extendBody: true,
            appBar: AppBar(
              title: const Text('ConseilBox'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                const GeometricBackground(),
                Positioned.fill(
                  child: IndexedStack(
                    index: _index,
                    children: [
                      _buildConseilsFeed(),
                      _buildConseilsExplorer(),
                      _buildPublicitesTab(),
                      _buildFavoritesTab(),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: CustomNavbar(
              currentIndex: _index,
              onTap: (value) => setState(() => _index = value),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _openCreateSheet,
              backgroundColor: AppColors.chocolat,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                'Conseiller',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
      
        Widget _buildConseilsFeed({bool includeHeader = true}) {
          final bool showFallback = _conseils.isEmpty;
          final List<Conseil> displayedConseils =
              showFallback ? _fallbackConseils : _conseils;
          final bool showLoader = _loadingMore && !showFallback;
          final bool showNoticeWithoutHeader =
              !includeHeader && _conseilsError != null && showFallback;
          final int headerCount = includeHeader || showNoticeWithoutHeader ? 1 : 0;
          final int totalItems =
              headerCount + displayedConseils.length + (showLoader ? 1 : 0);
      
          return RefreshIndicator(
            onRefresh: () => _fetchConseils(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _conseilsScrollController,
              padding:
                  const EdgeInsets.only(bottom: 120, left: 16, right: 16, top: 16),
              itemCount: totalItems,
              itemBuilder: (context, index) {
                if (headerCount == 1 && index == 0) {
                  if (includeHeader) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHomeHeader(context),
                        if (_loadingConseils)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: LinearProgressIndicator(minHeight: 3),
                          ),
                        if (_conseilsError != null && showFallback)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Connexion instable. Nous partageons quelques conseils sélectionnés en attendant vos données.',
                              style: AppTextStyles.small
                                  .copyWith(color: Colors.red.shade700),
                            ),
                          ),
                      ],
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Connexion instable. Nous partageons quelques conseils sélectionnés en attendant vos données.',
                        style:
                            AppTextStyles.small.copyWith(color: Colors.red.shade700),
                      ),
                    );
                  }
                }
      
                final int dataIndex = index - headerCount;
      
                if (dataIndex < displayedConseils.length) {
                  final conseil = displayedConseils[dataIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CardConseil(
                      conseil: conseil,
                      onTap: () => _openDetail(conseil),
                      isFavorite: _favoritesManager.isFavorite(conseil),
                      onShare: () => _shareConseil(conseil),
                      onFavorite: () => _toggleFavorite(conseil),
                    ),
                  );
                }
      
                if (showLoader && dataIndex == displayedConseils.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
      
                return const SizedBox.shrink();
              },
            ),
          );
        }
      
        Widget _buildConseilsExplorer() {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _applySearch(),
                      decoration: InputDecoration(
                        hintText: 'Rechercher par auteur, lieu ou mot-clé',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _applySearch();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: (_filters['order'] as String?) ?? 'latest',
                      decoration: InputDecoration(
                        labelText: 'Tri',
                        prefixIcon: const Icon(Icons.sort_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'latest',
                          child: Text('Plus récents'),
                        ),
                        DropdownMenuItem(
                          value: 'oldest',
                          child: Text('Plus anciens'),
                        ),
                        DropdownMenuItem(
                          value: 'random',
                          child: Text('Aléatoires'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _filters = {..._filters, 'order': value};
                        });
                        _fetchConseils();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildConseilsFeed(includeHeader: false)),
            ],
          );
        }
      
        Widget _buildFavoritesTab() {
          final favorites = _favoritesManager.items;
          if (favorites.isEmpty) {
            return _buildPlaceholder(
              title: 'Aucun favori',
              message:
                  'Touchez le coeur d\'un conseil pour l\'enregistrer et le retrouver ici.',
            );
          }
      
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 120, left: 16, right: 16, top: 16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final conseil = favorites[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CardConseil(
                  conseil: conseil,
                  onTap: () => _openDetail(conseil),
                  onShare: () => _shareConseil(conseil),
                  onFavorite: () => _toggleFavorite(conseil),
                  isFavorite: true,
                ),
              );
            },
          );
        }
      
        List<Conseil> get _fallbackConseils {
          return [
            _buildFallbackConseil(
              id: '-1', // Changed id to String
              title: 'Oser partager',
              author: 'Irène Amedji',
              location: 'Lomé, Togo',
              content:
                  'Chaque expérience compte. Racontez comment vous avez surmonté un obstacle et inspirez la prochaine personne.',
              daysAgo: 1,
            ),
            _buildFallbackConseil(
              id: '-2', // Changed id to String
              title: 'Créer des ponts',
              author: 'Abdoulaye K.',
              location: 'Dakar, Sénégal',
              content:
                  'Envoyez un message à quelqu’un que vous admirez aujourd’hui. Un échange peut ouvrir une opportunité inattendue.',
              daysAgo: 3,
            ),
            _buildFallbackConseil(
              id: '-3', // Changed id to String
              title: 'Ralentir pour mieux agir',
              author: 'Nadia A.',
              location: 'Cotonou, Bénin',
              content:
                  'Prendre dix minutes pour respirer profondément avant une décision importante clarifie les priorités.',
              daysAgo: 5,
            ),
            _buildFallbackConseil(
              id: '-4', // Changed id to String
              title: 'Documenter ses victoires',
              author: 'Junior L.',
              location: 'Abidjan, Côte d’Ivoire',
              content:
                  'Notez vos petites réussites hebdomadaires. Elles deviendront un carburant quand la motivation faiblit.',
              daysAgo: 7,
            ),
          ];
        }
      
        Conseil _buildFallbackConseil({
          required String id, // Changed id to String
          required String title,
          required String author,
          required String location,
          required String content,
          required int daysAgo,
        }) {
          final date = DateTime.now().subtract(Duration(days: daysAgo));
          return Conseil(
            id: id,
            title: title,
            content: content,
            author: author,
            location: location,
            status: 'published',
            socialLink1: null, // Replaced socialLinks with individual links
            socialLink2: null,
            socialLink3: null,
            createdAt: date,
            updatedAt: date,
          );
        }
      
        Widget _buildHomeHeader(BuildContext context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCarouselSection(context),
              const SizedBox(height: 16),
              _buildStatsSection(), // Nouvelle section pour les stats
              const SizedBox(height: 16),
              _buildQuickActionsSection(context),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
            ],
          );
        }
      
        Widget _buildStatsSection() {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.lightbulb_outline,
                  label: 'Conseils',
                  value: _conseils.length, // Utiliser le nombre de conseils chargés
                ),
                _buildStatItem(
                  icon: Icons.campaign_outlined,
                  label: 'Publicités',
                  value: _publicites.length, // Utiliser le nombre de publicités chargées
                ),
                // Vous pouvez ajouter d'autres statistiques ici si disponibles
              ],
            ),
          );
        }
      
        Widget _buildStatItem({
          required IconData icon,
          required String label,
          required int value,
        }) {
          return Column(
            children: [
              Icon(icon, size: 28, color: AppColors.chocolat),
              const SizedBox(height: 4),
              Text('$value', style: AppTextStyles.title.copyWith(fontSize: 18)),
              Text(label, style: AppTextStyles.small),
            ],
          );
        }
      
        Widget _buildCarouselSection(BuildContext context) {
          final items = _buildCarouselItems();
          final showingDefaults = _publicites.isEmpty;
      
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      showingDefaults
                          ? 'Inspiration ConseilBox'
                          : 'Tech pubs en vedette',
                      style: AppTextStyles.title,
                    ),
                  ),
                  if (_loadingPublicites)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              if (_publicitesError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Espace pubs',
                    style: AppTextStyles.small.copyWith(color: Colors.red.shade700),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _carouselController,
                  itemCount: items.length,
                  onPageChanged: (value) => setState(() => _carouselIndex = value),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          if (item.publicite != null) {
                            _openPubliciteDetail(item.publicite!);
                          } else {
                            _showToast('Inspirations ConseilBox');
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildCarouselImage(item),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.6),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: AppTextStyles.title
                                          .copyWith(color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.body
                                          .copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(items.length, (index) {
                  final bool isActive = index == _carouselIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: isActive ? 24 : 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.chocolat
                          : AppColors.chocolat.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ],
          );
        }
      
        List<_CarouselItem> _buildCarouselItems() {
          if (_publicites.isEmpty) {
            return _defaultCarouselItems;
          }
      
          return _publicites
              .map(
                (pub) => _CarouselItem(
                  title: pub.title,
                  content: pub.content,
                  imageUrl: pub.imageUrl,
                  targetUrl: pub.targetUrl,
                  publicite: pub,
                  isDefault: false,
                ),
              )
              .toList(growable: false);
        }
      
        Widget _buildCarouselImage(_CarouselItem item) {
          if (item.assetPath != null) {
            return Image.asset(
              item.assetPath!,
              fit: BoxFit.cover,
            );
          }
      
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
            return Image.network(
              item.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.chocolat.withValues(alpha: 0.1),
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported),
              ),
            );
          }
      
          return Container(
            color: AppColors.chocolat.withValues(alpha: 0.1),
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined),
          );
        }
      
        Widget _buildQuickActionsSection(BuildContext context) {
          final double availableWidth =
              MediaQuery.of(context).size.width - 32 /* padding */;
          final double actionWidth =
              (availableWidth / 2 - 12).clamp(140, availableWidth).toDouble();
      
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Actions rapides', style: AppTextStyles.title),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _quickActionButton(
                    width: actionWidth,
                    icon: Icons.edit_outlined,
                    label: 'Partager',
                    onTap: _openCreateSheet,
                  ),
                  _quickActionButton(
                    width: actionWidth,
                    icon: Icons.explore_outlined,
                    label: 'Explorer',
                    onTap: () => _setTab(1),
                  ),
                  _quickActionButton(
                    width: actionWidth,
                    icon: Icons.public,
                    label: 'Tech pubs',
                    onTap: () => _setTab(2),
                  ),
                  _quickActionButton(
                    width: actionWidth,
                    icon: Icons.favorite_outline,
                    label: 'Favoris',
                    onTap: () => _setTab(3),
                  ),
                  _quickActionButton(
                    width: actionWidth,
                    icon: Icons.list_alt,
                    label: 'Mes suggestions',
                    onTap: _openSuggestions,
                  ),
                ],
              ),
            ],
          );
        }
      
        Widget _quickActionButton({
          required double width,
          required IconData icon,
          required String label,
          required VoidCallback onTap,
        }) {
          return SizedBox(
            width: width,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: AppColors.chocolat),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                side: BorderSide(color: AppColors.chocolat.withValues(alpha: 0.5)),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          );
        }
      
        void _setTab(int value) {
          setState(() => _index = value);
        }
      
        Widget _buildPublicitesTab() {
          if (_loadingPublicites) {
            return const Center(child: CircularProgressIndicator());
          }
      
          if (_publicitesError != null) {
            return _buildErrorState(_publicitesError!, onRetry: _fetchPublicites);
          }
      
          if (_publicites.isEmpty) {
            return _buildPlaceholder(
              title: 'Aucune publicité active',
              message: 'Ajoutez une pub dans le back-office pour la voir ici.',
            );
          }
      
          return RefreshIndicator(
            onRefresh: _fetchPublicites,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _publiciteSearchController,
                        onSubmitted: (_) => _applyPubliciteSearch(),
                        decoration: InputDecoration(
                          hintText: 'Rechercher des publicités...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _publiciteSearchController.clear();
                              _applyPubliciteSearch();
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: (_publiciteFilters['order'] as String?) ?? 'latest',
                        decoration: InputDecoration(
                          labelText: 'Tri des publicités',
                          prefixIcon: const Icon(Icons.sort_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'latest',
                            child: Text('Les plus récentes'),
                          ),
                          DropdownMenuItem(
                            value: 'oldest',
                            child: Text('Les plus anciennes'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _publiciteFilters = {..._publiciteFilters, 'order': value};
                          });
                          _fetchPublicites();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 120, top: 0),
                    itemCount: _publicites.length,
                    itemBuilder: (context, index) {
                      final pub = _publicites[index];
                      return PubliciteCard(
                        publicite: pub,
                        onTap: () => _openPubliciteDetail(pub),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      
        void _applyPubliciteSearch() {
          setState(() {
            _publiciteFilters = {
              ..._publiciteFilters,
              'search': _publiciteSearchController.text.trim().isEmpty
                  ? null
                  : _publiciteSearchController.text.trim(),
            };
          });
          _fetchPublicites();
        }
      
        Widget _buildPlaceholder({required String title, required String message}) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: AppTextStyles.title, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
      
        Widget _buildErrorState(String error,
            {required Future<void> Function() onRetry}) {
          debugPrint('Home feed error: $error');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Oups...',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nous n’avons pas réussi à charger les derniers conseils.\nVérifiez votre connexion ou réessayez dans un instant.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => onRetry(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }
      
        void _showToast(String message) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
      
      class _CarouselItem {
        const _CarouselItem({
          required this.title,
          required this.content,
          this.imageUrl,
          this.assetPath,
          this.targetUrl,
          this.publicite,
          this.isDefault = true,
        });
      
        final String title;
        final String content;
        final String? imageUrl;
        final String? assetPath;
        final String? targetUrl;
        final Publicite? publicite;
        final bool isDefault;
      }
      
      const List<_CarouselItem> _defaultCarouselItems = [
        _CarouselItem(
          title: 'ConseilBox Stories',
          content: 'Les voix qui inspirent toute l\'Afrique creative.',
          assetPath: 'assets/images/kaizen.png',
        ),
        _CarouselItem(
          title: 'Capsules communautaires',
          content: 'Partagez vos astuces et boostez la prochaine generation.',
          assetPath: 'assets/images/logo.png',
        ),
        _CarouselItem(
          title: 'Portraits Kaizen',
          content: 'Rencontrez celles et ceux qui construisent le futur.',
          assetPath: 'assets/images/irokou.png',
        ),
      ];
      
