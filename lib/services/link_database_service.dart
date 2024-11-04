import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/models/link.dart';

class DatabaseService {
  static const String tableName = 'links';
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'links.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            link TEXT NOT NULL,
            createdDate TEXT NOT NULL,
            updatedDate TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<UnfurlLink>> getAllLinks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName,
        orderBy: 'updatedDate DESC, createdDate DESC');
    return maps.map((map) => UnfurlLink.fromMap(map)).toList();
  }

  Future<UnfurlLink> insertLink(UnfurlLink link) async {
    final db = await database;
    final id = await db.insert(tableName, link.toMap());
    return link.copyWith(id: id);
  }

  Future<int> updateLink(UnfurlLink link) async {
    final db = await database;
    return await db.update(
      tableName,
      link.toMap(),
      where: 'id = ?',
      whereArgs: [link.id],
    );
  }

  Future<int> deleteLink(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Stream<UnfurlLink?> watchLatestLink() {
    return database.asStream().asyncMap((db) async {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'updatedDate DESC, createdDate DESC',
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return UnfurlLink.fromMap(maps.first);
      } else {
        return null;
      }
    });
  }
}
