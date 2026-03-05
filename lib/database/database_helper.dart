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
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

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
    // Deck of Cards API suit codes
    final suitCodes = {'Hearts': 'H', 'Diamonds': 'D', 'Clubs': 'C', 'Spades': 'S'};
    final suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    final cardNames = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'];
    // API value codes: A, 2-9, 0 (ten), J, Q, K
    final valueCodes = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'J', 'Q', 'K'];

    for (int folderId = 1; folderId <= suits.length; folderId++) {
      final suit = suits[folderId - 1];
      final suitCode = suitCodes[suit]!;
      for (int i = 0; i < cardNames.length; i++) {
        await db.insert('cards', {
          'card_name': cardNames[i],
          'suit': suit,
          'image_url': 'https://deckofcardsapi.com/static/img/${valueCodes[i]}$suitCode.png',
          'folder_id': folderId,
        });
      }
    }
  }
}
