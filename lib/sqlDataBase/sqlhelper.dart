import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sql.dart';

class SqlHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
  title TEXT,
  description TEXT,
  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
)
""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase('my_dataBase.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<int> createItem(String title, String? description) async {
    final db = await SqlHelper.db();

    final data = {'title': title, 'description': description};

    final id = await db.insert('items', data, 
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SqlHelper.db();
    return db.query('items', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SqlHelper.db();
    return db.query('items', where: 'id=?', limit: 1, whereArgs: [id]);
  }

  static Future<int> updateItem(
      int id, String title, String? description) async {
    final db = await SqlHelper.db();

    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString()
    };
    final result = db.update('items', where: "id=?", data,whereArgs: [id]);
    return result;
  }

  static Future<void>deleteItem(int id) async{
    final db=await SqlHelper.db();
    try{
        await db.delete('items', where: 'id=?', whereArgs: [id]);
    }catch(e){
      debugPrint(e.toString());
    }
  }
}
