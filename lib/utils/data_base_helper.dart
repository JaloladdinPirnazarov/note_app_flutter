import 'dart:io';

import 'package:note_app_flutter/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  late String tableName;
  var colId = "id";
  var colTitle = "title";
  var colDescription = "description";
  var colDate = "date";
  late String createTable;

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
      _databaseHelper!.initializeDatabase();
    }
    return _databaseHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  DatabaseHelper._createInstance() {
    tableName = "note_table";
    createTable =
    'CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colDate TEXT)';
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}notes.db";
    var notesDatabase =
    await openDatabase(path, version: 1, onCreate: createDb);
    return notesDatabase;
  }

  void createDb(Database db, int newVersion) async {
    await db.execute(createTable);
  }

  getNoteMapList() async {
    Database db = await this.database;
    List<Map<String, Object?>> notes = await db.query(tableName);
    return notes;
  }


  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(tableName, note.toMap(note));
    return result;
  }

  Future<int> updateNote(Note note) async{
    var db = await this.database;
    var result  = await db.update(tableName, note.toMap(note), where: "$colId = ?", whereArgs: [note.id]);
    return result;
  }

  Future<int> deleteNote(int id) async{
    var db = await this.database;
    int result = await  db.delete('$tableName WHERE $colId = $id');
    return result;
  }

  Future<int> getCount() async{
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.query("SELECT COUNT (*) from $tableName");
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;
    List<Note> noteList = <Note>[];
    for(int i = 0;i < count; i++){
      noteList.add(Note.fromMap(noteMapList[i]));
    }
    return noteList;
  }

}
