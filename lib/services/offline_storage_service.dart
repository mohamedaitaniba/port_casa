import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/anomaly.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance = OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  Database? _database;
  static const String _tableName = 'pending_anomalies';
  static const String _draftsTableName = 'drafts';
  static const String _dbName = 'port_casa_offline.db';
  static const int _dbVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    try {
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      // If upgrade fails, delete and recreate
      await deleteDatabase(path);
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        image_path TEXT,
        created_at INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE $_draftsTableName (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        image_path TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_draftsTableName (
          id TEXT PRIMARY KEY,
          data TEXT NOT NULL,
          image_path TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
    }
  }

  // Save anomaly locally
  Future<void> saveAnomalyLocally({
    required Anomaly anomaly,
    String? localImagePath,
  }) async {
    final db = await database;
    final data = jsonEncode({
      'id': anomaly.id,
      'title': anomaly.title,
      'description': anomaly.description,
      'date': anomaly.date.toIso8601String(),
      'location': anomaly.location,
      'category': anomaly.category.label,
      'priority': anomaly.priority.value,
      'status': anomaly.status.labelFr,
      'createdBy': anomaly.createdBy,
      'createdAt': anomaly.createdAt.toIso8601String(),
      'department': anomaly.department,
    });

    await db.insert(
      _tableName,
      {
        'id': anomaly.id,
        'data': data,
        'image_path': localImagePath,
        'created_at': anomaly.createdAt.millisecondsSinceEpoch,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all pending anomalies
  Future<List<Map<String, dynamic>>> getPendingAnomalies() async {
    final db = await database;
    return await db.query(
      _tableName,
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  // Mark anomaly as synced
  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      _tableName,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete synced anomalies (cleanup)
  Future<void> deleteSyncedAnomalies() async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'synced = ?',
      whereArgs: [1],
    );
  }

  // Get count of pending anomalies
  Future<int> getPendingCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE synced = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Delete anomaly by id
  Future<void> deleteAnomaly(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DRAFT METHODS
  
  // Save draft
  Future<void> saveDraft({
    required Anomaly anomaly,
    String? localImagePath,
  }) async {
    try {
      final db = await database;
      
      // Ensure drafts table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_draftsTableName (
          id TEXT PRIMARY KEY,
          data TEXT NOT NULL,
          image_path TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      final data = jsonEncode({
        'id': anomaly.id,
        'title': anomaly.title,
        'description': anomaly.description,
        'date': anomaly.date.toIso8601String(),
        'location': anomaly.location,
        'category': anomaly.category.label,
        'priority': anomaly.priority.value,
        'status': anomaly.status.labelFr,
        'createdBy': anomaly.createdBy,
        'createdAt': anomaly.createdAt.toIso8601String(),
        'department': anomaly.department,
      });

      await db.insert(
        _draftsTableName,
        {
          'id': anomaly.id,
          'data': data,
          'image_path': localImagePath,
          'created_at': anomaly.createdAt.millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement du brouillon: $e');
    }
  }

  // Get all drafts
  Future<List<Map<String, dynamic>>> getDrafts() async {
    final db = await database;
    return await db.query(
      _draftsTableName,
      orderBy: 'updated_at DESC',
    );
  }

  // Get single draft
  Future<Map<String, dynamic>?> getDraft(String id) async {
    final db = await database;
    final result = await db.query(
      _draftsTableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Delete draft
  Future<void> deleteDraft(String id) async {
    final db = await database;
    await db.delete(
      _draftsTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get draft count
  Future<int> getDraftCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_draftsTableName',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

