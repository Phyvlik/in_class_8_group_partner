import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        // 🔥 Enables foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Folders table
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Cards table with foreign key
    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders (id)
          ON DELETE CASCADE
      )
    ''');

    await _prepopulateFolders(db);
    await _prepopulateCards(db);
  }

  Future<void> _prepopulateFolders(Database db) async {
    final folders = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];

    for (var folder in folders) {
      await db.insert('folders', {
        'folder_name': folder,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _prepopulateCards(Database db) async {
    final suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    final cards = [
      'Ace','2','3','4','5','6','7',
      '8','9','10','Jack','Queen','King'
    ];

    for (int folderId = 1; folderId <= suits.length; folderId++) {
      for (var card in cards) {
        await db.insert('cards', {
          'card_name': card,
          'suit': suits[folderId - 1],
          'image_url': '',
          'folder_id': folderId,
        });
      }
    }
  }
}