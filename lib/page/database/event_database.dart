import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class EventDatabase {
  static final EventDatabase instance = EventDatabase._init();
  static Database? _database;

  EventDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('events.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';

    await db.execute('''
      CREATE TABLE events (
        id $idType,
        date $textType,
        time $textType,
        endTime $textType,
        title $textType,
        category $textType,
        presenter $textType,
        organizer $textType,
        location $textType,
        content $textType,
        participantLimit INTEGER,
        imageUrl TEXT,
        videoUrl TEXT,
        currentParticipants INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertEvent(Map<String, dynamic> event) async {
    Database db = await instance.database;
    return await db.insert('events', event);
  }

  Future<List<Map<String, dynamic>>> getEventsByDate(String date) async {
    Database db = await instance.database;
    return await db.query('events', where: 'date = ?', whereArgs: [date]);
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    Database db = await instance.database;
    return await db.query('events');
  }

  Future<int> updateEvent(Map<String, dynamic> event) async {
    Database db = await instance.database;
    return await db.update(
      'events',
      event,
      where: 'id = ?',
      whereArgs: [event['id']],
    );
  }

  Future<int> deleteEvent(int id) async {
    Database db = await instance.database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // 新增方法：检查是否可以报名
  Future<bool> canRegisterForEvent(int eventId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'events',
      columns: ['participantLimit', 'currentParticipants'],
      where: 'id = ?',
      whereArgs: [eventId],
    );

    if (result.isNotEmpty) {
      int participantLimit = result[0]['participantLimit'] as int;
      int currentParticipants = result[0]['currentParticipants'] as int;
      return currentParticipants < participantLimit;
    }

    return false;
  }

  // 新增方法：增加已报名人数
  Future<void> incrementParticipantCount(int eventId) async {
    Database db = await instance.database;
    await db.rawUpdate(
      'UPDATE events SET currentParticipants = currentParticipants + 1 WHERE id = ?',
      [eventId],
    );
  }

  Future close() async {
    Database db = await instance.database;
    db.close();
  }
}
