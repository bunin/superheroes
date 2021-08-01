import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:superheroes/exceptions/api_exception.dart';
import 'package:superheroes/model/superhero.dart';

class MainBloc {
  static const minSymbols = 3;

  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  final favoriteSuperheroesSubject =
      BehaviorSubject<List<SuperheroInfo>>.seeded(SuperheroInfo.mocked);
  final searchedSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded("");

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;

  http.Client? client;

  MainBloc({this.client}) {
    stateSubject.add(MainPageState.noFavorites);
    textSubscription =
        Rx.combineLatest2<String, List<SuperheroInfo>, MainPageStateInfo>(
      currentTextSubject.distinct().debounceTime(Duration(milliseconds: 500)),
      favoriteSuperheroesSubject,
      (searchedText, favorites) => MainPageStateInfo(
          searchText: searchedText, haveFavorites: favorites.isNotEmpty),
    ).listen((value) {
      print("CHANGED $value");
      searchSubscription?.cancel();
      if (value.searchText.isEmpty) {
        if (value.haveFavorites) {
          stateSubject.add(MainPageState.favorites);
          return;
        }
        stateSubject.add(MainPageState.noFavorites);
        return;
      }
      if (value.searchText.length < minSymbols) {
        stateSubject.add(MainPageState.minSymbols);
        return;
      }
      searchForSuperheroes(value.searchText);
    });
  }

  Stream<MainPageState> observeMainPageState() => stateSubject;

  void searchForSuperheroes(final String q) {
    stateSubject.add(MainPageState.loading);
    searchSubscription = search(q).asStream().listen(
      (searchResults) {
        if (searchResults.isEmpty) {
          stateSubject.add(MainPageState.nothingFound);
          return;
        }
        searchedSuperheroesSubject.add(searchResults);
        stateSubject.add(MainPageState.searchResults);
      },
      onError: (error, stackTrace) {
        stateSubject.add(MainPageState.loadingError);
      },
    );
  }

  Stream<List<SuperheroInfo>> observeFavoriteSuperheroes() =>
      favoriteSuperheroesSubject;

  Stream<List<SuperheroInfo>> observeSearchedSuperheroes() =>
      searchedSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    final token = dotenv.env["SUPERHERO_TOKEN"];
    final response = await (client ??= http.Client()).get(
      Uri.parse("https://superheroapi.com/api/$token/search/$text"),
    );
    final decoded = json.decode(response.body);
    if (decoded['response'] == 'success') {
      final List<dynamic> results = decoded['results'];
      final List<Superhero> superheroes =
          results.map((e) => Superhero.fromJson(e)).toList();
      final List<SuperheroInfo> found = superheroes
          .map((e) => SuperheroInfo(
                name: e.name,
                realName: e.biography.fullName,
                imageUrl: e.image.url,
              ))
          .toList();
      return found;
    }
    if (decoded['response'] == 'error') {
      if (decoded['error'] == 'character with given name not found') {
        return [];
      }
      throw ApiException.fromCode(
        code: response.statusCode,
        message: decoded['error'],
      );
    }

    throw ApiException.fromCode(
      code: response.statusCode,
      message: decoded['error'],
    );
  }

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState
        .values[(currentState.index + 1) % MainPageState.values.length];
    stateSubject.add(nextState);
  }

  void updateText(final String? text) {
    currentTextSubject.add(text ?? "");
  }

  void removeFavorite() {
    final currentFavorites =
        List<SuperheroInfo>.from(favoriteSuperheroesSubject.value);
    if (currentFavorites.isEmpty) {
      favoriteSuperheroesSubject.add(SuperheroInfo.mocked);
      return;
    }
    currentFavorites.removeLast();
    favoriteSuperheroesSubject.add(currentFavorites);
  }

  void dispose() {
    stateSubject.close();
    favoriteSuperheroesSubject.close();
    searchedSuperheroesSubject.close();
    currentTextSubject.close();
    textSubscription?.cancel();
    client?.close();
  }

  void retry() {
    searchForSuperheroes(currentTextSubject.valueOrNull ?? '');
  }
}

enum MainPageState {
  noFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResults,
  favorites,
}

class SuperheroInfo {
  final String name;
  final String realName;
  final String imageUrl;

  const SuperheroInfo({
    required this.name,
    required this.realName,
    required this.imageUrl,
  });

  @override
  String toString() {
    return 'SuperheroInfo{name: $name, realName: $realName, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuperheroInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          realName == other.realName &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;

  static const mocked = [
    SuperheroInfo(
      name: 'Batman',
      realName: 'Bruce Wayne',
      imageUrl:
          'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg',
    ),
    SuperheroInfo(
      name: 'Ironman',
      realName: 'Tony Stark',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/85.jpg',
    ),
    SuperheroInfo(
      name: 'Venom',
      realName: 'Eddie Brock',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/22.jpg',
    ),
  ];
}

class MainPageStateInfo {
  final String searchText;
  final bool haveFavorites;

  const MainPageStateInfo({
    required this.searchText,
    required this.haveFavorites,
  });

  @override
  String toString() {
    return 'MainPageStateInfo{searchText: $searchText, haveFavorites: $haveFavorites}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainPageStateInfo &&
          runtimeType == other.runtimeType &&
          searchText == other.searchText &&
          haveFavorites == other.haveFavorites;

  @override
  int get hashCode => searchText.hashCode ^ haveFavorites.hashCode;
}
