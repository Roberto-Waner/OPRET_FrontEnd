import 'package:formulario_opret/database_cache/Database_Helper.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_preguntasCompleta.dart';
import 'package:sqflite/sqflite.dart';

class SectionCrud {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertSectionCrud(SpPreguntascompleta question) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'SeccionPreguntas', 
      question.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SpPreguntascompleta>> querySectionCrud() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('SeccionPreguntas').timeout(const Duration(seconds: 5));
    return List.generate(maps.length, (i) {
      return SpPreguntascompleta.fromJson(maps[i]);
    });
  }

  Future<int> updateSectionCrud(int id, SpPreguntascompleta question) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'SeccionPreguntas',
      question.toJson(),
      where: 'codPregunta = ?',
      whereArgs: [id]
    );
  }

  // Método para obtener una pregunta específica por ID
  Future<SpPreguntascompleta?> getOneSectionCrud(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'SeccionPreguntas',
      where: 'codPregunta = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SpPreguntascompleta.fromJson(maps.first);
    } else {
      print('Pregunta no encontrada');
      return null;
    }
  }
}