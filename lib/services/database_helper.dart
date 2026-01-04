import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:restaurant_app/model/restaurant.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  DatabaseHelper._internal() {
    _databaseHelper = this;
  }

  factory DatabaseHelper() => _databaseHelper ?? DatabaseHelper._internal();

  static const String _tableName = 'favorites';

  Future<Database> get database async {
    _database ??= await _initializeDb();
    return _database!;
  }

  Future<Database> _initializeDb() async {
    var path = await getDatabasesPath();
    var db = openDatabase(
      join(path, 'restaurant_db.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE $_tableName(
               id TEXT PRIMARY KEY,
               name TEXT,
               description TEXT,
               city TEXT,
               rating REAL,
               pictureId TEXT
             )''',
        );
      },
      version: 1,
    );
    return db;
  }

  Future<void> insertFavorite(Restaurant restaurant) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        'id': restaurant.id,
        'name': restaurant.name,
        'description': restaurant.description,
        'city': restaurant.city,
        'rating': restaurant.rating,
        'pictureId': restaurant.pictureId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Restaurant>> getFavorites() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(_tableName);

    return results.map((res) {
      return Restaurant(
        id: res['id'],
        name: res['name'],
        description: res['description'],
        city: res['city'],
        rating: res['rating'],
        pictureId: res['pictureId'],
      );
    }).toList();
  }

  Future<Map<String, dynamic>?> getFavoriteById(String id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
