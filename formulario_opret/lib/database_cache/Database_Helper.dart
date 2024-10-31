import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  final _databaseName = "database_FormOpret.db";
  final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  // Indicador para eliminar la base de datos, puedes cambiarlo a 'true' solo si necesitas limpiar la base de datos
  final bool _shouldDeleteDatabase = false;

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
      create table RegistroUsuarios (
        idUsuarios TEXT primary key not null,
        cedula TEXT unique not null,
        nombreApellido  TEXT not null,
        usuario TEXT unique not null,
        email TEXT unique not null,
        passwords TEXT unique not null,
        fechaCreacion  TEXT,
        rol TEXT
      )
    ''');
    await db.execute('''
      create table Sesion(
        idSesion INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        tipoRespuesta TEXT NOT NULL,
        grupoTema TEXT NULL,
        codPregunta INTEGER NOT NULL,
        codSubPregunta TEXT NULL,
        rango TEXT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE Pregunta (
        codPregunta INTEGER PRIMARY KEY NOT NULL,
        pregunta1 TEXT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE SubPreguntas (
        codSubPregunta TEXT PRIMARY KEY NOT NULL,
        subPreguntas TEXT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE Respuestas (
        idRespuestas INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        idUsuarios TEXT NOT NULL,
        noEncuesta TEXT NOT NULL,
        codPregunta INTEGER NOT NULL,
        respuesta1 TEXT NULL,
        valoracion TEXT NULL,
        comentarios TEXT NULL,
        justificacion TEXT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE Formulario (
        identifacadorForm INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        noEncuesta TEXT NOT NULL,
        idUsuarios TEXT NOT NULL,
        cedula TEXT NOT NULL,
        fecha TEXT NULL,
        hora TEXT NULL,
        idEstacion INTEGER NULL,
        idLinea TEXT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE Linea (
        idLinea TEXT PRIMARY KEY NOT NULL,
        tipoLinea TEXT NOT NULL,
        nombreLinea TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE Estacion (
        idEstacion INTEGER PRIMARY KEY NOT NULL,
        idLinea TEXT NOT NULL,
        nombreEstacion TEXT
      )
    ''');
  }

  /*
  // Método genérico para insertar datos
  Future<int> insert(String table, Map<String, dynamic> values) async {
    Database db = await instance.database;
    return await db.insert(table, values);
  }

  // Método genérico para actualizar datos
  Future<int> update(String table, Map<String, dynamic> values, String whereClause, List<dynamic> whereArgs) async {
    Database db = await instance.database;
    return await db.update(table, values, where: whereClause, whereArgs: whereArgs);
  }

  // Método genérico para eliminar datos
  Future<int> delete(String table, String whereClause, List<dynamic> whereArgs) async {
    Database db = await instance.database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }

  // Método genérico para obtener todos los datos de una tabla
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Método genérico para obtener una fila con condiciones
  Future<List<Map<String, dynamic>>> queryRows(String table, String whereClause, List<dynamic> whereArgs) async {
    Database db = await instance.database;
    return await db.query(table, where: whereClause, whereArgs: whereArgs);
  }
  */
}