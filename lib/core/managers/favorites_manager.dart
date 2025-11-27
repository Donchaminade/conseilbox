import 'package:flutter/material.dart';

import '../models/conseil.dart';

class FavoritesManager extends ChangeNotifier {
  final Map<int, Conseil> _favorites = {};

  List<Conseil> get items => _favorites.values.toList(growable: false);

  bool isFavorite(Conseil conseil) => _favorites.containsKey(conseil.id);

  void toggle(Conseil conseil) {
    if (isFavorite(conseil)) {
      _favorites.remove(conseil.id);
    } else {
      _favorites[conseil.id] = conseil;
    }
    notifyListeners();
  }
}
