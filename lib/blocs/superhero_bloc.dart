import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/favorite_superheroes_storage.dart';
import 'package:superheroes/model/superhero.dart';

class SuperheroBloc {
  http.Client? client;
  final String id;

  final superheroSubject = BehaviorSubject<Superhero>();
  final BehaviorSubject<SuperheroPageState> stateSubject =
      BehaviorSubject<SuperheroPageState>();

  StreamSubscription? requestSubscription;
  StreamSubscription? getFromFavoritesSubscription;
  StreamSubscription? addToFavoriteSubscription;
  StreamSubscription? removeFromFavoritesSubscription;

  SuperheroBloc({this.client, required this.id}) {
    getFromFavorites();
  }

  Stream<bool> observeIsFavorite() =>
      FavoriteSuperheroesStorage.getInstance().observeIsFavorite(id);

  Stream<Superhero> observeSuperhero() => superheroSubject.distinct();

  Stream<SuperheroPageState> observeSuperheroPageState() =>
      stateSubject.distinct();

  void getFromFavorites() {
    getFromFavoritesSubscription?.cancel();
    getFromFavoritesSubscription = FavoriteSuperheroesStorage.getInstance()
        .getSuperhero(id)
        .asStream()
        .listen(
      (superhero) {
        if (superhero != null) {
          print("getFromFavoritesSubscription $superhero");
          superheroSubject.add(superhero);
          stateSubject.add(SuperheroPageState.loaded);
        }
        stateSubject.add(SuperheroPageState.loading);
        try {
          requestSuperhero();
          stateSubject.add(SuperheroPageState.loaded);
        } catch (e) {
          stateSubject.add(SuperheroPageState.error);
        }
      },
      onError: (error, stackTrace) {
        if (stateSubject.value != SuperheroPageState.loaded) {
          stateSubject.add(SuperheroPageState.error);
        }
        print("error happened in getFromFavorites: $error, $stackTrace");
      },
    );
  }

  void requestSuperhero() {
    requestSubscription?.cancel();
    requestSubscription = request().asStream().listen(
      (superhero) {
        superheroSubject.add(superhero);
      },
      onError: (error, stackTrace) {
        print("error happened in requestSuperhero: $error, $stackTrace");
        throw error;
      },
    );
  }

  Future<Superhero> request() async {
    final token = dotenv.env["SUPERHERO_TOKEN"];
    final response = await (client ??= http.Client()).get(
      Uri.parse("https://superheroapi.com/api/$token/$id"),
    );
    final decoded = json.decode(response.body);
    if (decoded['response'] == 'success') {
      final sh = Superhero.fromJson(decoded);
      final storage = FavoriteSuperheroesStorage.getInstance();
      final favList = await storage.getSuperheroes();
      for (int i = 0; i < favList.length; i++) {
        if (favList[i].id == sh.id) {
          favList[i] = sh;
          await storage.setSuperheroes(favList);
          break;
        }
      }
      return sh;
    }
    if (decoded['response'] == 'error') {
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

  void addToFavorite() {
    final superhero = superheroSubject.valueOrNull;
    if (superhero == null) {
      return;
    }
    addToFavoriteSubscription?.cancel();
    addToFavoriteSubscription = FavoriteSuperheroesStorage.getInstance()
        .addToFavorites(superhero)
        .asStream()
        .listen(
      (event) {
        print("Added to favorites: $event");
      },
      onError: (error, stackTrace) {
        print("error happened in addToFavorite: $error, $stackTrace");
      },
    );
  }

  void removeFromFavorites() {
    removeFromFavoritesSubscription?.cancel();
    removeFromFavoritesSubscription = FavoriteSuperheroesStorage.getInstance()
        .removeFromFavorites(id)
        .asStream()
        .listen(
      (event) {
        print("Removed from favorites: $event");
      },
      onError: (error, stackTrace) {
        print("error happened in removeFromFavorites: $error, $stackTrace");
      },
    );
  }

  void retry() {
    stateSubject.add(SuperheroPageState.loading);
    try {
      requestSuperhero();
      stateSubject.add(SuperheroPageState.loaded);
    } catch (e) {
      stateSubject.add(SuperheroPageState.error);
    }
  }

  void dispose() {
    client?.close();
    stateSubject.close();
    superheroSubject.close();
    requestSubscription?.cancel();
    getFromFavoritesSubscription?.cancel();
    addToFavoriteSubscription?.cancel();
    removeFromFavoritesSubscription?.cancel();
  }
}

enum SuperheroPageState {
  loading,
  loaded,
  error,
}
