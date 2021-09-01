import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superheroes/model/superhero.dart';

class FavoriteSuperheroesStorage {
  static const _key = "favorite_superheroes";
  final updater = PublishSubject<Null>();

  static FavoriteSuperheroesStorage? _instance;

  factory FavoriteSuperheroesStorage.getInstance() =>
      _instance ??= FavoriteSuperheroesStorage._internal();

  FavoriteSuperheroesStorage._internal();

  Future<bool> addToFavorites(final Superhero superhero) async {
    final rawData = await _getRawSuperheroes();
    rawData.add(json.encode(superhero.toJson()));
    return _setRawSuperheroes(rawData);
  }

  Future<bool> removeFromFavorites(final String id) async {
    final rawData = await _getRawSuperheroes();
    rawData.removeWhere((e) => Superhero.fromJson(json.decode(e)).id == id);
    return _setRawSuperheroes(rawData);
  }

  Future<List<String>> _getRawSuperheroes() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_key) ?? [];
  }

  Future<bool> _setRawSuperheroes(final List<String> rawSuperheroes) async {
    final sp = await SharedPreferences.getInstance();
    final result = await sp.setStringList(_key, rawSuperheroes);
    updater.add(null);
    return result;
  }

  Future<List<Superhero>> getSuperheroes() async {
    return (await _getRawSuperheroes())
        .map((e) => Superhero.fromJson(json.decode(e)))
        .toList(growable: false);
  }

  Future<bool> setSuperheroes(final List<Superhero> superheroes) async {
    return _setRawSuperheroes(
      superheroes.map((e) => json.encode(e.toJson())).toList(growable: false),
    );
  }

  Future<Superhero?> getSuperhero(final String id) async {
    for (final superhero in (await getSuperheroes())) {
      if (superhero.id == id) {
        return superhero;
      }
    }
    return null;
  }

  Stream<List<Superhero>> observeFavoriteSuperheroes() async* {
    yield await getSuperheroes();
    await for (final _ in updater) {
      yield await getSuperheroes();
    }
  }

  Stream<bool> observeIsFavorite(final String id) =>
      observeFavoriteSuperheroes().map((list) => list.any((e) => e.id == id));
}
