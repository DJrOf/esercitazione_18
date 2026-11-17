import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/database_service.dart';

class MovieViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _error;

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMovies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _movies = await _databaseService.getMovies();
    } catch (e) {
      _error = 'Errore nel caricamento dei film: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMovie(Movie movie) async {
    try {
      await _databaseService.insertMovie(movie);
      await loadMovies();
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
      await loadMovies();
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
      await loadMovies();
      return true;
    } catch (e) {
      _error = 'Errore durante l\'eliminazione: $e';
      notifyListeners();
      return false;
    }
  }
}
