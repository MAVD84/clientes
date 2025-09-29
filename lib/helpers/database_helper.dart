import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/client_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'iptv_clients.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        lastName TEXT,
        username TEXT,
        password TEXT,
        phone TEXT,
        startDate TEXT,
        endDate TEXT,
        months INTEGER,
        price REAL,
        referredBy TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE clients ADD COLUMN referredBy TEXT');
    }
  }

  Future<int> addClient(Client client) async {
    Database db = await database;
    return await db.insert('clients', client.toMap());
  }

  Future<List<Client>> getClients() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clients');
    return List.generate(maps.length, (i) {
      return Client.fromMap(maps[i]);
    });
  }

  Future<int> updateClient(Client client) async {
    Database db = await database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    Database db = await database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
