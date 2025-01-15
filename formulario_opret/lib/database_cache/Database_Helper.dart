import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  final _databaseName = "database_FormOpret.db";
  // final _databaseName = "database_FormOpret_Cache.db";
  final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  // Indicador para eliminar la base de datos, puedes cambiarlo a 'true' solo si necesitas limpiar la base de datos
  final bool _shouldDeleteDatabase = true;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_shouldDeleteDatabase) await _deleteDatabase(); // Elimina la base de datos solo si es necesario
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> _deleteDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    await deleteDatabase(path); // Elimina la base de datos
  }

  Future<void> resetDatabase() async {
    await DatabaseHelper.instance._deleteDatabase(); // Elimina la base de datos
    await DatabaseHelper.instance.database; // Recrea la base de datos
    print('Base de datos formateada y recreada');
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), _databaseName);
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
      );
    } catch (e) {
      print('Error al inicializar la base de datos: $e');
      rethrow;
    }
  }

  // creacion de las tabla para la cache
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE localRespuestas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idUsuarios TEXT NULL,
        idSesion INTEGER NULL,
        respuesta TEXT NULL,
        comentarios TEXT NULL,
        justificacion TEXT NULL,
        finalizarSesion INTEGER DEFAULT 0,
        isUpdated INTEGER DEFAULT 0,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE SeccionPreguntas (
        codPregunta integer null,
        tipoRespuesta text null,
        noIdentifEncuesta text null,
        pregunta text null,
        subPregunta text null,
        estado INTEGER NULL,
        rango text null,
        isUpdated INTEGER DEFAULT 0,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
  }
}