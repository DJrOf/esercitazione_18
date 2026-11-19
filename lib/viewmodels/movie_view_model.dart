import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/database_service.dart';

class MovieViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Movie> _movies = [];
  List<Movie> _filteredMovies = [];
  bool _isLoading = false;
  String? _error;

  List<Movie> get movies => _movies;
  List<Movie> get filteredMovies => _filteredMovies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fecthMovies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _movies = await _databaseService.getMovies();
      _filteredMovies = List.from(_movies);
    } catch (e) {
      _error = 'Errore nel caricamento dei film: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterMovies(String query) {
    if (query.isEmpty) {
      _filteredMovies = List.from(_movies);
    } else {
      _filteredMovies = _movies
          .where(
            (movie) =>
                movie.title.toLowerCase().contains(query.toLowerCase()) ||
                movie.plot.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  Future<bool> addMovie(Movie movie) async {
    try {
      await _databaseService.insertMovie(movie);
      await fecthMovies();
      return true;
    } catch (e) {
      _error = 'Errore durante l\'inserimento: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMovie(Movie movie) async {
    try {
      await _databaseService.updateMovie(movie);
      await fecthMovies();
      return true;
    } catch (e) {
      _error = 'Errore durante l\'aggiornamento: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMovie(int id) async {
    try {
      await _databaseService.deleteMovie(id);
      await fecthMovies();
      return true;
    } catch (e) {
      _error = 'Errore durante l\'eliminazione: $e';
      notifyListeners();
      return false;
    }
  }
}
