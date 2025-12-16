import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

import '../../core/managers/favorites_manager.dart';
import '../../core/models/conseil.dart';
import '../../core/models/paginated_response.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/conseil_service.dart';
import '../../core/widgets/card_conseil.dart';
import 'conseil_detail_screen.dart';

class ConseilListScreen extends StatefulWidget {
  const ConseilListScreen({super.key});

  @override
  State<ConseilListScreen> createState() => _ConseilListScreenState();
}

class _ConseilListScreenState extends State<ConseilListScreen> {
  final ConseilService _conseilService = ConseilService();

  final ScrollController _scrollController = ScrollController();

  List<Conseil> _conseils = [];
  PaginatedResponse<Conseil>? _pagination;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    context.read<FavoritesManager>().addListener(_onFavoritesChanged);
    _scrollController.addListener(_onScroll);
    _fetchConseils(reset: true);
  }

  @override
  void dispose() {
    context.read<FavoritesManager>().removeListener(_onFavoritesChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetchConseils({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() {
        _loadingMore = true;
      });
    }

    try {
      final response = await _conseilService.fetchConseils(
        page: reset ? 1 : (_pagination?.nextPage ?? 1),
        limit: 20,
        status: 'published,active', // Fetch all published and active
      );

      if (!mounted) return;
      setState(() {
        _pagination = response;
        if (reset) {
          _conseils = response.items;
        } else {
          _conseils.addAll(response.items);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : 'Une erreur est survenue.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_loadingMore && (_pagination?.hasMore ?? false)) {
      _fetchConseils();
    }
  }
  
  void _shareConseil(Conseil conseil) {
    final content = '${conseil.title}\n${conseil.content}\nPartagé via ConseilBox';
    Share.share(content);
  }

  void _toggleFavorite(Conseil conseil) {
    context.read<FavoritesManager>().toggle(conseil);
  }

  Future<void> _openDetail(Conseil conseil) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ConseilDetailScreen(
          conseil: conseil,
          favorites: context.read<FavoritesManager>(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchConseils(reset: true),
                child: const Text('Réessayer'),
              )
            ],
          ),
        ),
      );
    }

    if (_conseils.isEmpty) {
      return Center(
        child: RefreshIndicator(
          onRefresh: () => _fetchConseils(reset: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Aucun conseil à afficher pour le moment.'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchConseils(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 120, left: 16, right: 16, top: 16),
        itemCount: _conseils.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _conseils.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final conseil = _conseils[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CardConseil(
              conseil: conseil,
              onTap: () => _openDetail(conseil),
              isFavorite: context.watch<FavoritesManager>().isFavorite(conseil),
              onShare: () => _shareConseil(conseil),
              onFavorite: () => _toggleFavorite(conseil),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tous les conseils'),
      ),
      body: _buildBody(),
    );
  }
}
