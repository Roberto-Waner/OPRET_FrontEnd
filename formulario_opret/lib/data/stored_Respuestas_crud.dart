import 'package:formulario_opret/database_cache/Database_Helper.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Insertar_Respuestas.dart';
import 'package:sqflite/sqflite.dart';

class StoredRespuestasCrud {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<bool> insertStoredRespCrud(List<SpInsertarRespuestas> respuestas) async {
    try {
      final db = await _databaseHelper.database;

      Batch batch = db.batch();
      for (var item in respuestas) {
        batch.insert(
          'storedResponses',
          item.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      print('Respuestas almacenadas en storedRespuestas');
      return true; // Indica que la operación fue exitosa
    } catch (e) {
      print('Error al insertar respuestas en storedRespuestas: $e');
      return false; // Indica que hubo un error
    }
  }

  Future<List<SpInsertarRespuestas>> queryStoredRespCrud() async {
    final db = await _databaseHelper.database;

    final stored = await db.query('storedResponses');
    return List.generate(stored.length, (i) {
      return SpInsertarRespuestas.fromJson(stored[i]);
    });
  }

  Future<bool> deleteAllStoredRespCrud() async {
    try {
      final db = await _databaseHelper.database;
      await db.delete('storedResponses');

      print('Todas las respuesta que se encontraban en el stored han sido eliminados de la tabla storedResponses');
      return true; 
    } catch (e) {
      print('Error al vaciar el storedRespuestas');
      return false;
    }
  }
}