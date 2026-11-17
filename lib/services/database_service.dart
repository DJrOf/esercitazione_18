import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/movie.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'movies.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE film (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        duration INTEGER NOT NULL,
        plot TEXT NOT NULL,
        year INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertMovie(Movie movie) async {
    final db = await database;
    return db.insert('film', movie.toMap());
  }

  Future<List<Movie>> getMovies() async {
    final db = await database;
    final maps = await db.query('film', orderBy: 'title ASC');
    return maps.map((map) => Movie.fromMap(map)).toList();
  }

  Future<Movie?> getMovieById(int id) async {
    final db = await database;
    final maps = await db.query(
      'film',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Movie.fromMap(maps.first);
  }

  Future<int> updateMovie(Movie movie) async {
    final db = await database;
    return db.update(
      'film',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<int> deleteMovie(int id) async {
    final db = await database;
    return db.delete(
      'film',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
