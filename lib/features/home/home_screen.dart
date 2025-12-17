import 'dart:async';
import 'dart:math'; // For min function

import 'package:conseilbox/core/network/api_exception.dart';
import 'package:conseilbox/features/conseils/conseil_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Ajouté pour SystemNavigator.pop()
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart'; // Import pour Provider

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
import '../conseils/conseillist.dart';
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
  static const int _stackCardCount =
      5; // Number of conseils to display in the stacked card animation
  final ConseilService _conseilService = ConseilService();
  final PubliciteService _publiciteService = PubliciteService();
  // final FavoritesManager _favoritesManager = FavoritesManager(); // Supprimé
  final ScrollController _conseilsScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final PageController _carouselController =
      PageController(viewportFraction: 0.9);
  final TextEditingController _publiciteSearchController =
      TextEditingController();
  final PageController _infoCarouselController = PageController();
  int _infoCarouselIndex = 0;
  Timer? _infoCarouselTimer;
  Map<String, dynamic> _publiciteFilters = {
    'order': 'latest',
    'status': 'active'
  };

  int _index = 0;
  bool _loadingConseils = false;
  bool _loadingMore = false;
  String? _conseilsError;
  List<Conseil> _conseils = [];
  final List<Conseil> _mySuggestions = [];
  PaginatedResponse<Conseil>? _pagination;
  Map<String, dynamic> _filters = {
    'order': 'latest',
    'status': 'published,active'
  };

  bool _loadingPublicites = false;
  String? _publicitesError;
  List<Publicite> _publicites = [];
  int _carouselIndex = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _fetchConseils();
    _fetchPublicites();
    // _conseilsScrollController.addListener(_onScroll);
    _scheduleCarouselTimer();
  }

  @override
  void dispose() {
    // _favoritesManager.removeListener(_handleFavoritesChanged); // Supprimé
    _conseilsScrollController.dispose();
    _searchController.dispose();
    _publiciteSearchController.dispose(); // Dispose du nouveau controller
    _carouselController.dispose();
    _carouselTimer?.cancel();
    _infoCarouselTimer?.cancel();
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
        limit: 4, // Changed from perPage to limit
        status: _filters['status'] as String?,
        author: _filters['author'] as String?,
        location: _filters['location'] as String?,
        search: _filters['search'] as String?,
        sortBy: _filters['sortBy'] as String? ?? 'created_at',
        order: _filters['order'] as String? ?? 'DESC',
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
        _loadingMore =
            true; // This might not be entirely accurate for publicites if not paginated beyond first call.
      });
    }

    try {
      final response = await _publiciteService.fetchPublicites(
        page:
            1, // Publicites usually fetched all at once or separate pagination for carousel
        limit: 15, // As per current usage in _buildCarouselSection
        search: _publiciteFilters['search'] as String?,
        sortBy:
            'created_at', // Assuming 'created_at' as default sort for publicites as well
        order: (_publiciteFilters['order'] as String?) ?? 'DESC',
      );

      if (!mounted) return;
      setState(() {
        _publicites =
            response.items; // Corrected: assign items from PaginatedResponse
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
      _scheduleInfoCarouselTimer();
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

  void _restartInfoCarouselTimer({required int itemCount}) {
    _infoCarouselTimer?.cancel();
    if (itemCount < 2) {
      return;
    }

    _infoCarouselTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      // Slower scroll for info carousel
      if (!_infoCarouselController.hasClients) return;
      final nextPage = (_infoCarouselIndex + 1) % itemCount;
      _infoCarouselController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _scheduleInfoCarouselTimer() {
    final length = _infoCarouselItems.length;
    if (_infoCarouselIndex >= length) {
      _infoCarouselIndex = 0;
    }
    _restartInfoCarouselTimer(itemCount: length);
  }

  void _toggleFavorite(Conseil conseil) {
    context.read<FavoritesManager>().toggle(conseil);
    final isNowFavorite = context.read<FavoritesManager>().isFavorite(conseil);
    _showToast(
      isNowFavorite ? 'Ajouté aux favoris' : 'Retiré des favoris',
    );
  }

  Future<void> _openDetail(Conseil conseil) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConseilDetailScreen(
          conseil: conseil,
          favorites: context.read<FavoritesManager>(),
        ),
      ),
    );
  }

  void _shareConseil(Conseil conseil) {
    final content =
        '${conseil.title}\n${conseil.content}\nPartagé via ConseilBox';
    Share.share(content);
  }

  void _sharePublicite(Publicite publicite) {
    final content =
        '${publicite.title}\n${publicite.content}\nPartagé via ConseilBox';
    Share.share(content);
  }

  Future<void> _openSuggestions() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MySuggestionsScreen(
          suggestions: _mySuggestions,
          favorites: context.read<FavoritesManager>(),
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
      _openSuggestions();
    }
  }

  void _applySearch() {
    // No-op
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // Empêche l'application de se fermer immédiatement
        onPopInvoked: (bool didPop) {
          if (didPop) return;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Quitter l\'application ?'),
                content:
                    const Text('Voulez-vous vraiment quitter ConseilBox ?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Non'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Oui'),
                  ),
                ],
              );
            },
          ).then((value) {
            if (value == true) {
              SystemNavigator.pop();
            }
          });
        },
        child: Scaffold(
          extendBody: true,
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
        ));
  }

  Widget _buildConseilsFeed({bool includeHeader = true}) {
    final bool showFallback = _conseils.isEmpty;
    List<Conseil> allConseils = showFallback ? _fallbackConseils : _conseils;

    // Split conseils for stack and list
    List<Conseil> stackedConseils = [];
    List<Conseil> remainingConseils = [];

    if (allConseils.isNotEmpty) {
      // Ensure we don't try to take more than available
      stackedConseils =
          allConseils.take(min(_stackCardCount, allConseils.length)).toList();
      remainingConseils = allConseils.skip(_stackCardCount).toList();
    }

    final bool showLoader =
        _loadingMore && !showFallback; // Re-added definition

    return RefreshIndicator(
      onRefresh: () async {
        await _fetchConseils(reset: true);
      },
      child: CustomScrollView(
        controller: _conseilsScrollController,
        slivers: <Widget>[
          SliverAppBar(
            title: const Text('ConseilBox', style: TextStyle(fontSize: 25)),
            floating: true,
            pinned: true,
            snap: true, // Optional: Makes the app bar snap into view faster
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                iconSize: 28,
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
          if (includeHeader) ...[
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverPersistentHeaderDelegate(
                minHeight: 50.0, // Adjust min/max height as needed
                maxHeight: 70.0,
                child: Container(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor, // Background color for the sticky header
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _publicites.isEmpty
                        ? 'Inspiration ConseilBox'
                        : 'Tech pubs en vedette',
                    style: AppTextStyles.title,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0), // Removed top padding as header has it
                child: _buildCarouselSection(context),
              ),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 16),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildStatsSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 16),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverPersistentHeaderDelegate(
                minHeight: 50.0,
                maxHeight: 70.0,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Actions rapides',
                    style: AppTextStyles.title,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0), // No top padding needed here
                child: _buildQuickActionsSection(context),
              ),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 8),
            ),
            SliverToBoxAdapter(
              child: const Divider(),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: 8),
            ),
            if (_loadingConseils)
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              ),
            if (_conseilsError != null && showFallback)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                  child: Text(
                    'Connexion instable. Nous partageons quelques conseils sélectionnés en attendant vos données.',
                    style: AppTextStyles.small
                        .copyWith(color: Colors.red.shade700),
                  ),
                ),
              ),
          ],
          // Header for "Nouveaux Conseils"
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverPersistentHeaderDelegate(
              minHeight: 50.0,
              maxHeight: 70.0,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Nouveaux Conseils',
                  style: AppTextStyles.title,
                ),
              ),
            ),
          ),
          // Stacked Conseils Cards
          if (stackedConseils.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _CardStackConseils(
                  // Pass a copy of the list, as the internal widget will modify it
                  conseils: List<Conseil>.from(stackedConseils),
                  onSwipe: (swipedConseil) {
                    // This callback is called when a card is effectively swiped.
                    // For now, _CardStackConseils handles internal reordering.
                    // If we need to perform actions or update the main _conseils list
                    // in HomeScreenState, this is where we would do it.
                    // For example, if we want to show a toast or log the swiped conseil.
                    debugPrint('Conseil swiped: ${swipedConseil.title}');
                  },
                ),
              ),
            ),
          // Remaining Conseils in a regular list
          if (remainingConseils.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(
                  bottom: 120, left: 16, right: 16, top: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final conseil =
                        remainingConseils[index]; // Use remainingConseils
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CardConseil(
                        conseil: conseil,
                        onTap: () => _openDetail(conseil),
                        isFavorite: context
                            .watch<FavoritesManager>()
                            .isFavorite(conseil),
                        onShare: () => _shareConseil(conseil),
                        onFavorite: () => _toggleFavorite(conseil),
                      ),
                    );
                  },
                  childCount:
                      remainingConseils.length, // Use remainingConseils length
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom:
                      120.0), // Add extra space at the bottom of the info carousel
              child: _buildInfoCarousel(),
            ),
          ),
          if (showLoader)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConseilsExplorer() {
    return const ConseilListScreen();
  }

  Widget _buildFavoritesTab() {
    final favoritesManager = context.watch<FavoritesManager>();
    final favorites = favoritesManager.items;
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

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.lightbulb_outline,
            label: 'Conseils',
            value: _pagination?.total ??
                0, // Utiliser le nombre total de conseils disponibles          ),
          ),
          _buildStatItem(
            icon: Icons.campaign_outlined,
            label: 'Publicités',
            value:
                _publicites.length, // Utiliser le nombre de publicités chargées
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
        if (_loadingPublicites) // Keep loading indicator if it's there
          Row(
            children: [
              Expanded(
                  child:
                      Container()), // Empty expanded to push indicator to right
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
        // Added missing children array
        // Title moved to SliverPersistentHeader
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
            child: Row(
              // Changed from Column to Row
              children: [
                Expanded(
                  child: TextField(
                    controller: _publiciteSearchController,
                    onSubmitted: (_) => _applyPubliciteSearch(),
                    decoration: InputDecoration(
                      hintText: 'Rechercher des publicités...',
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.chocolat),
                      suffixIcon: IconButton(
                        icon:
                            const Icon(Icons.clear, color: AppColors.chocolat),
                        onPressed: () {
                          _publiciteSearchController.clear();
                          _applyPubliciteSearch();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: AppColors.chocolat.withOpacity(0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: AppColors.chocolat.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppColors.chocolat, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                    style: AppTextStyles.body,
                  ),
                ),
                const SizedBox(width: 12), // Spacing between search and filter
                // Placeholder for sort button - will replace DropdownButtonFormField
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == null) return;
                    setState(() {
                      _publiciteFilters = {
                        ..._publiciteFilters,
                        'order': value
                      };
                    });
                    _fetchPublicites();
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'latest',
                      child: Text('Les plus récentes'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'oldest',
                      child: Text('Les plus anciennes'),
                    ),
                  ],
                  child: Container(
                    width: 48, // Fixed width for a square button
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.chocolat,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.sort_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                  bottom: 120,
                  left: 16,
                  right: 16,
                  top: 0), // Add horizontal padding
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 2, // Spacing between columns
                mainAxisSpacing: 4, // Spacing between rows
                childAspectRatio: 0.80, // Increased height for publicite cards
              ),
              itemCount: _publicites.length,
              itemBuilder: (context, index) {
                final pub = _publicites[index];
                return PubliciteCard(
                  publicite: pub,
                  onTap: () => _openPubliciteDetail(pub),
                  onShare: () =>
                      _sharePublicite(pub), // Pass the share callback
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

  Widget _buildInfoCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('À propos de l\'application', style: AppTextStyles.title),
        ),
        SizedBox(
          height: 140, // Adjusted height for no images
          child: PageView.builder(
            controller: _infoCarouselController,
            itemCount: _infoCarouselItems.length,
            onPageChanged: (value) =>
                setState(() => _infoCarouselIndex = value),
            itemBuilder: (context, index) {
              final item = _infoCarouselItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Card(
                  elevation: 4, // Increased elevation
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20)), // Increased border radius
                  color:
                      AppColors.chocolat.withOpacity(0.15), // Adjusted opacity
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.title.copyWith(
                              fontSize: 18,
                              color: AppColors
                                  .chocolat), // Larger font size for title
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.content,
                          style: AppTextStyles.body.copyWith(
                              fontSize: 14,
                              color: AppColors.chocolat
                                  .withOpacity(0.8)), // Darker content text
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
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
          children: List.generate(_infoCarouselItems.length, (i) {
            final bool isActive = i == _infoCarouselIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: isActive ? 24 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.chocolat
                    : AppColors.chocolat.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
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

class _InfoCarouselItem {
  const _InfoCarouselItem({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;
}

const List<_InfoCarouselItem> _infoCarouselItems = [
  _InfoCarouselItem(
    title: 'Bienvenue sur ConseilBox',
    content:
        'La plateforme de partage de connaissances et d\'expériences pour la communauté.',
  ),
  _InfoCarouselItem(
    title: 'Partagez un Conseil',
    content:
        'Utilisez le bouton "Conseiller" pour soumettre vos propres conseils et aider les autres.',
  ),
  _InfoCarouselItem(
    title: 'Découvrez & Grandissez',
    content:
        'Explorez les conseils des autres, sauvegardez vos favoris et continuez d\'apprendre.',
  ),
  _InfoCarouselItem(
    title: 'Restez Inspiré',
    content:
        'Chaque jour, de nouveaux conseils pour booster votre créativité et votre productivité.',
  ),
  _InfoCarouselItem(
    title: 'Contribuez à la Communauté',
    content:
        'Vos expériences sont précieuses. Partagez-les pour enrichir notre base de connaissances.',
  ),
  _InfoCarouselItem(
    title: 'Vos Favoris, Toujours à Portée',
    content:
        'Enregistrez les conseils qui vous parlent le plus pour les retrouver facilement.',
  ),
  _InfoCarouselItem(
    title: 'Actualités & Publicités',
    content:
        'Restez informé des dernières tendances et découvrez des opportunités via nos publicités.',
  ),
  _InfoCarouselItem(
    title: 'Sécurité et Confidentialité',
    content:
        'Vos données sont protégées. ConseilBox s\'engage pour la sécurité de ses utilisateurs.',
  ),
];

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _SliverPersistentHeaderDelegate({
    required this.child,
    this.minHeight = 40.0,
    this.maxHeight = 60.0,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}

// New Widget for Stacked Conseils Cards
class _CardStackConseils extends StatefulWidget {
  final List<Conseil> conseils;
  final Function(Conseil) onSwipe; // Callback when a card is swiped

  const _CardStackConseils({
    super.key,
    required this.conseils,
    required this.onSwipe,
  });

  @override
  State<_CardStackConseils> createState() => _CardStackConseilsState();
}

class _CardStackConseilsState extends State<_CardStackConseils>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<Offset> _slideAnimation;

  late Animation<double> _rotationAnimation;

  late Animation<double> _flipAnimation; // New animation for the 3D flip

  int _currentIndex = 0;

  List<Conseil> _currentConseils = [];

  double _swipeDirection = 0.0; // -1.0 for left, 1.0 for right

  @override
  void initState() {
    super.initState();

    _currentConseils =
        List.from(widget.conseils); // Initialize with provided conseils

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Slightly longer for flip

      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,

      end: const Offset(1.0, 0.0), // Swipe right
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // New flip animation

    _flipAnimation = Tween<double>(begin: 0.0, end: 0.5 * pi).animate(
      CurvedAnimation(
        parent: _controller,

        curve: Curves.easeIn, // EaseIn feels more natural for a departure
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex += _swipeDirection.toInt();

          _controller.reset();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant _CardStackConseils oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.conseils != oldWidget.conseils) {
      _currentConseils = List.from(widget.conseils);

      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _handleSwipe(double direction) {
    // direction: -1 for left, 1 for right

    if (_controller.isAnimating) return;

    // Boundary checks for non-circular deck

    if (direction > 0 && _currentIndex >= _currentConseils.length - 1) {
      return; // At the end, can't go next
    }

    if (direction < 0 && _currentIndex <= 0) {
      return; // At the start, can't go previous
    }

    setState(() {
      _swipeDirection = direction;
    });

    _controller.forward();
  }

  // Define 5 distinct colors for the card borders

  static const List<Color> _borderColors = [
    AppColors.chocolat,

    AppColors.cafe,

    Colors.brown, // Darker brown

    Colors.blueGrey, // A neutral color

    Colors.orange, // A vibrant accent color
  ];

  @override
  Widget build(BuildContext context) {
    if (_currentConseils.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 350,
      child: Stack(
        children: _currentConseils
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;

              final conseil = entry.value;

              if (index < _currentIndex) {
                return const SizedBox.shrink();
              }

              final isTopCard = index == _currentIndex;

              final borderColor = _borderColors[index % _borderColors.length];

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final matrix = Matrix4.identity();

                  if (isTopCard) {
                    final offsetX =
                        _slideAnimation.value.dx * 300 * _swipeDirection;

                    final rotationZ =
                        _rotationAnimation.value * _swipeDirection;

                    final rotationY = _flipAnimation.value * _swipeDirection;

                    matrix.translate(offsetX, 0.0);

                    matrix.rotateZ(rotationZ);

                    matrix.rotateY(rotationY);
                  } else {
                    final stackIndex = index - _currentIndex;

                    final topPadding = stackIndex * 10.0;

                    final scale = 1.0 - (stackIndex * 0.05);

                    matrix
                      ..translate(0.0, topPadding)
                      ..scale(scale);
                  }

                  return Transform(
                    transform: matrix,
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onHorizontalDragEnd: isTopCard
                      ? (details) {
                          if (details.primaryVelocity == null ||
                              details.primaryVelocity!.abs() < 200) {
                            return; // Insufficient velocity
                          }

                          if (details.primaryVelocity! > 0) {
                            // Dragged Right -> Go to Previous Card

                            _handleSwipe(-1.0);
                          } else {
                            // Dragged Left -> Go to Next Card

                            _handleSwipe(1.0);
                          }
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: borderColor, width: 4.0),
                        bottom: BorderSide(color: borderColor, width: 4.0),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CardConseil(
                      conseil: conseil,
                      onTap: isTopCard ? () => widget.onSwipe(conseil) : null,
                      isFavorite:
                          context.watch<FavoritesManager>().isFavorite(conseil),
                      onShare: isTopCard ? () => widget.onSwipe(conseil) : null,
                      onFavorite: isTopCard
                          ? () =>
                              context.read<FavoritesManager>().toggle(conseil)
                          : null,
                    ),
                  ),
                ),
              );
            })
            .toList()
            .reversed
            .toList(),
      ),
    );
  }
}
