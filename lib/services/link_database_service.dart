import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/models/link.dart';
import '../data/models/tag.dart';

class DatabaseService {
  static const String linksTable = 'links';
  static const String tagsTable = 'tags';
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
        // Create tags table first
        await db.execute('''
          CREATE TABLE $tagsTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tagName TEXT NOT NULL,
            tagDescription TEXT NOT NULL,
            createdDate TEXT NOT NULL,
            updatedDate TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');

        // Create links table with tagId as foreign key
        await db.execute('''
          CREATE TABLE $linksTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            link TEXT NOT NULL,
            createdDate TEXT NOT NULL,
            updatedDate TEXT NOT NULL,
            status TEXT NOT NULL,
            tagId INTEGER,
            FOREIGN KEY (tagId) REFERENCES $tagsTable (id) ON DELETE SET NULL
          )
        ''');
      },
    );
  }

  // Tag operations
  Future<Tag> insertTag(Tag tag) async {
    final db = await database;
    final id = await db.rawInsert('''
      INSERT OR REPLACE INTO $tagsTable 
      (id, tagName, tagDescription, createdDate, updatedDate, status)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      tag.id,
      tag.tagName,
      tag.tagDescription,
      dateTimeToSqlite(tag.createdDate),
      dateTimeToSqlite(tag.updatedDate),
      tag.status,
    ]);
    return tag.copyWith(id: id);
  }

  Future<List<Tag>> getAllTags() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tagsTable);
    return maps
        .map((map) => Tag.fromMap(map))
        .toList()
        .where((tag) => tag.status == 'active')
        .toList();
  }

  Future<int> updateTag(Tag tag) async {
    final db = await database;
    return await db.update(
      tagsTable,
      tag.toMap(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  Future<int> deleteTag(int id) async {
    final db = await database;
    return await db.delete(
      tagsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // getTagById
  Future<Tag?> getTagById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> tagMaps = await db.query(
      tagsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (tagMaps.isEmpty) {
      return null;
    }

    return Tag.fromMap(tagMaps.first);
  }

  // Link operations with tag
  Future<UnfurlLink> insertLink(UnfurlLink link) async {
    final db = await database;
    final id = await db.rawInsert('''
      INSERT OR REPLACE INTO $linksTable 
      (id, title, description, link, createdDate, updatedDate, status, tagId)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      link.id,
      link.title,
      link.description,
      link.link,
      dateTimeToSqlite(link.createdDate),
      dateTimeToSqlite(link.updatedDate),
      link.status,
      link.tagId,
    ]);
    return link.copyWith(id: id);
  }

  Future<UnfurlLink> getLinkWithTag(int linkId) async {
    final db = await database;
    final List<Map<String, dynamic>> linkMaps = await db.rawQuery('''
      SELECT l.*, t.*
      FROM $linksTable l
      LEFT JOIN $tagsTable t ON l.tagId = t.id
      WHERE l.id = ?
    ''', [linkId]);

    if (linkMaps.isEmpty) {
      throw Exception('Link not found');
    }

    final map = linkMaps.first;
    final link = UnfurlLink.fromMap(map);

    // If there's a tag, create the Tag object
    Tag? tag;
    if (map['tagId'] != null) {
      tag = Tag(
        id: map['tagId'],
        tagName: map['tagName'],
        tagDescription: map['tagDescription'],
        createdDate: DateTime.parse(map['createdDate']),
        updatedDate: DateTime.parse(map['updatedDate']),
        status: map['status'],
      );
    }

    return link.copyWith(tag: tag);
  }

  // getTagByName
  Future<Tag?> getTagByName(String tagName) async {
    final db = await database;
    final List<Map<String, dynamic>> tagMaps = await db.query(
      tagsTable,
      where: 'tagName = ?',
      whereArgs: [tagName],
    );

    if (tagMaps.isEmpty) {
      return null;
    }

    return Tag.fromMap(tagMaps.first);
  }

  Future<List<UnfurlLink>> getAllLinksWithTags() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT 
      l.id ,
      l.createdDate,
      l.updatedDate,
      l.status,
      l.title,
      l.description,
      l.link,
      t.id AS tagId,
      t.tagName,
      t.tagDescription,
      t.createdDate AS tagCreatedDate,
      t.updatedDate AS tagUpdatedDate,
      t.status AS tagStatus
    FROM $linksTable l
    LEFT JOIN $tagsTable t ON l.tagId = t.id
    ORDER BY l.updatedDate DESC, l.createdDate DESC
  ''');

    return maps.map((map) {
      final link = UnfurlLink.fromMap(map);
      Tag? tag;
      if (map['tagId'] != null) {
        tag = Tag(
          id: map['tagId'],
          tagName: map['tagName'],
          tagDescription: map['tagDescription'],
          createdDate: DateTime.parse(map['tagCreatedDate']),
          updatedDate: DateTime.parse(map['tagUpdatedDate']),
          status: map['tagStatus'],
        );
      }
      return link.copyWith(tag: tag);
    }).toList();
  }

  Future<List<UnfurlLink>> getLinksForTag(int tagId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      linksTable,
      where: 'tagId = ?',
      whereArgs: [tagId],
      orderBy: 'updatedDate DESC, createdDate DESC',
    );
    return maps.map((map) => UnfurlLink.fromMap(map)).toList();
  }

  Future<int> updateLink(UnfurlLink link) async {
    final db = await database;
    return await db.update(
      linksTable,
      link.toMap(),
      where: 'id = ?',
      whereArgs: [link.id],
    );
  }

  Future<int> deleteLink(int id) async {
    final db = await database;
    return await db.delete(
      linksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // getLinkById
  Future<UnfurlLink?> getLinkById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> linkMaps = await db.query(
      linksTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (linkMaps.isEmpty) {
      return null;
    }

    return UnfurlLink.fromMap(linkMaps.first);
  }

  // Helper methods
  String dateTimeToSqlite(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  DateTime sqliteToDateTime(String dateTimeString) {
    return DateTime.parse(dateTimeString);
  }
}
