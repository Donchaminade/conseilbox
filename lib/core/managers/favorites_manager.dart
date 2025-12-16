import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conseil.dart';

class FavoritesManager extends ChangeNotifier {
  static const _kFavoritesKey = 'favorites';

  FavoritesManager() {
    _loadFavorites();
  }

  final Map<String, Conseil> _favorites = {};

  List<Conseil> get items => _favorites.values.toList(growable: false);

  bool isFavorite(Conseil conseil) => _favorites.containsKey(conseil.id);

  void toggle(Conseil conseil) {
    if (isFavorite(conseil)) {
      _favorites.remove(conseil.id);
    } else {
      _favorites[conseil.id] = conseil;
    }
    _saveFavorites();
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJson = prefs.getStringList(_kFavoritesKey) ?? [];
    for (final jsonString in favoriteJson) {
      try {
        final conseil = Conseil.fromJson(json.decode(jsonString) as Map<String, dynamic>);
        _favorites[conseil.id] = conseil;
      } catch (e) {
        // Handle potential parsing errors if the stored JSON is invalid
        debugPrint('Error loading favorite conseil: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJson =
        _favorites.values.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList(_kFavoritesKey, favoriteJson);
  }
}