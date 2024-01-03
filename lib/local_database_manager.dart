// local_database_manager.dart
import 'package:flutter_offline/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseManager {
  static const String dbName = 'local_database.db';
  static const String userTable = 'user_table';

  Future<Database> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);
    return openDatabase(path, onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE $userTable (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        password TEXT,
        avatar TEXT
      )
    ''');
    }, version: 1);
  }

  Future<void> insertUser(User user) async {
    final database = await initializeDatabase();
    await database.insert(userTable, user.toMap());
  }

  Future<List<User>> getUsers() async {
    final database = await initializeDatabase();
    final List<Map<String, dynamic>> maps = await database.query(userTable);
    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'],
        name: maps[i]['name'],
        email: maps[i]['email'],
        password: maps[i]['password'],
        avatar: maps[i]['avatar'],
      );
    });
  }

  Future<void> deleteSyncedUsers(List<User> syncedUsers) async {
    final database = await initializeDatabase();
    for (User user in syncedUsers) {
      await database.delete(
        userTable,
        where: 'id = ?',
        whereArgs: [user.id],
      );
    }
  }
}
