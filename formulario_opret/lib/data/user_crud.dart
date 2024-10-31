import 'package:formulario_opret/database_cache/Database_Helper.dart';
import 'package:formulario_opret/models/usuarios.dart';
import 'package:sqflite/sqflite.dart';

class UserCrud {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  // para interactual en la base de datos local Sqflite
  Future<int> insertUserCrud(Usuarios user) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'RegistroUsuarios', 
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Usuarios>> getUsersCrud() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('RegistroUsuarios');
    return List.generate(maps.length, (i) {
      return Usuarios.fromJson(maps[i]);
    });
  }

  Future<Usuarios?> getOneUserCrud(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RegistroUsuarios',
      where: 'idUsuarios = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Usuarios.fromJson(maps.first);
    } else {
      print('Usuario no encontrado');
      return null;
    }
  }

  Future<int> updateUserCrud(String id, Usuarios user) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'RegistroUsuarios',
      user.toJson(),
      where: 'idUsuarios = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUserCrud(String id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'RegistroUsuarios',
      where: 'idUsuarios = ?',
      whereArgs: [id],
    );
  }

  // Limpiar las marcas de sincronización para los usuarios
  Future<void> clearSyncFlags(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'RegistroUsuarios',
      {'isUpdated': 0, 'isDeleted': 0},
      where: 'idUsuarios = ?',
      whereArgs: [id],
    );
    print("Marcas de sincronización limpiadas para el usuario con ID: $id");
  }
}

  /*
  Future<void> insertUserCrud(Usuarios user) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'RegistroUsuarios',
      {
        ...user.toJson(),
        'isUpdated': 1, // Marca como pendiente de sincronización si es un nuevo registro
        'isDeleted': 0, // Asegura que no esté marcado como eliminado
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Usuario guardado en SQLite.");
  }

  Future<List<Usuarios>>  getUsersCrud() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('RegistroUsuarios', where: 'isDeleted = 0');
    return List.generate(maps.length, (i) => Usuarios.fromJson(maps[i]));
  }

  Future<Usuarios?> getOneUserCrud(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RegistroUsuarios',
      where: 'idUsuarios = ? AND isDeleted = 0',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Usuarios.fromJson(maps.first);
    } else {
      print('Usuario no encontrado');
      return null;
    }
  }

  Future<void> updateUserCrud(String id, Usuarios user) async {
    final db = await _databaseHelper.database;
    await db.update(
      'RegistroUsuarios',
      {
        ...user.toJson(),
        'isUpdated': 1, // Marca el usuario como actualizado y pendiente de sincronización
      },
      where: 'idUsuarios = ?',
      whereArgs: [id],
    );
    print("Usuario actualizado en SQLite.");
  }

  Future<void> markUserAsDeleted(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'RegistroUsuarios',
      {'isDeleted': 1}, // Marca el usuario como eliminado
      where: 'idUsuarios = ?',
      whereArgs: [id],
    );
    print("Usuario marcado como eliminado en SQLite.");
  }

  // Obtener usuarios pendientes de sincronización con "isUpdated = 1"
  Future<List<Usuarios>> getUpdatedUsersCrud() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RegistroUsuarios',
      where: 'isUpdated = 1 AND isDeleted = 0',
    );
    return List.generate(maps.length, (i) => Usuarios.fromJson(maps[i]));
  }

  // Obtener los IDs de los usuarios marcados como eliminados con "isDeleted = 1"
  Future<List<String>> getDeletedUserIdsCrud() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RegistroUsuarios',
      columns: ['idUsuarios'],
      where: 'isDeleted = 1',
    );
    return maps.map((map) => map['idUsuarios'] as String).toList();
  }

  // Limpiar las marcas de sincronización para los usuarios
  Future<void> clearSyncFlags(String id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'RegistroUsuarios',
      {'isUpdated': 0, 'isDeleted': 0},
      where: 'idUsuarios = ?',
      whereArgs: [id],
    );
    print("Marcas de sincronización limpiadas para el usuario con ID: $id");
  }

  // Método para obtener todos los usuarios que han sido modificados
  Future<List<Usuarios>> getUpdatedUsersCrud() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RegistroUsuarios',
      where: 'isUpdated = ?',  // Suponiendo que "isUpdated" marca los usuarios modificados
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      return Usuarios.fromJson(maps[i]);
    });
  }

  // Método para obtener IDs de usuarios eliminados
  Future<List<String>> getDeletedUserIdsCrud() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RegistroUsuarios',
      columns: ['idUsuarios'],
      where: 'isDeleted = ?',  // Suponiendo que "isDeleted" marca los usuarios eliminados
      whereArgs: [1],
    );

    return maps.map((map) => map['idUsuarios'] as String).toList();
  }
  */