import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/models/tag.dart';

class TagDatabaseService {
  static const String tableName = 'tags';
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tags.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tagName TEXT NOT NULL,
            tagDescription TEXT NOT NULL,
            createdDate TEXT NOT NULL,
            updatedDate TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Tag>> getAllTags() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'updatedDate DESC, createdDate DESC',
    );
    return maps.map((map) => Tag.fromMap(map)).toList();
  }

  Future<Tag> insertTag(Tag tag) async {
    final db = await database;
    // Use INSERT OR REPLACE to insert or update the record if it already exists
    final id = await db.rawInsert('''
    INSERT OR REPLACE INTO ${tableName} (id, tagName, tagDescription, createdDate, updatedDate, status)
    VALUES (?, ?, ?, ?, ?, ?)
  ''', [
      tag.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      tag.tagName,
      tag.tagDescription,
      dateTimeToSqlite(tag.createdDate),
      dateTimeToSqlite(tag.updatedDate),
      tag.status,
    ]);
    return tag.copyWith(id: id);
  }

  Future<int> updateTag(Tag tag) async {
    final db = await database;
    return await db.update(
      tableName,
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  Future<int> deleteTag(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Stream<List<Tag>> watchLatestTags() {
    return database.asStream().asyncMap((db) async {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'updatedDate DESC, createdDate DESC',
        limit: 3,
      );
      return maps.map((map) => Tag.fromMap(map)).toList();
    });
  }
}

String dateTimeToSqlite(DateTime dateTime) {
  return dateTime.toIso8601String(); // Returns 'YYYY-MM-DDTHH:MM:SS.sss'
}

DateTime sqliteToDateTime(String dateTimeString) {
  return DateTime.parse(
      dateTimeString); // Converts 'YYYY-MM-DDTHH:MM:SS.sss' back to DateTime
}
