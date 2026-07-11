import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/scan_document.dart';

/// Local SQLite persistence for scan history & favorites.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final docsDir = await getApplicationDocumentsDirectory();
    final path = p.join(docsDir.path, 'hanan_scanner.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE scans (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            created_at TEXT NOT NULL,
            page_paths TEXT NOT NULL,
            pdf_path TEXT,
            thumbnail_path TEXT,
            scanned_value TEXT,
            color_mode TEXT NOT NULL DEFAULT 'original',
            is_favorite INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_scans_created ON scans(created_at DESC)',
        );
        await db.execute(
          'CREATE INDEX idx_scans_favorite ON scans(is_favorite)',
        );
      },
    );
    return _db!;
  }

  Future<void> insert(ScanDocument doc) async {
    final db = await database;
    await db.insert('scans', doc.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(ScanDocument doc) async {
    final db = await database;
    await db.update('scans', doc.toMap(), where: 'id = ?', whereArgs: [doc.id]);
  }

  Future<void> delete(String id) async {
    final db = await database;
    await db.delete('scans', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ScanDocument>> getAll() async {
    final db = await database;
    final rows = await db.query('scans', orderBy: 'created_at DESC');
    return rows.map(ScanDocument.fromMap).toList();
  }

  Future<List<ScanDocument>> getFavorites() async {
    final db = await database;
    final rows = await db.query('scans',
        where: 'is_favorite = 1', orderBy: 'created_at DESC');
    return rows.map(ScanDocument.fromMap).toList();
  }

  Future<List<ScanDocument>> search(String query) async {
    final db = await database;
    final rows = await db.query(
      'scans',
      where: 'title LIKE ? OR scanned_value LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return rows.map(ScanDocument.fromMap).toList();
  }

  Future<void> toggleFavorite(String id, bool favorite) async {
    final db = await database;
    await db.update('scans', {'is_favorite': favorite ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }
}
