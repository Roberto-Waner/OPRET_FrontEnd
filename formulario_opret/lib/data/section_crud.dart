import 'package:formulario_opret/database_cache/Database_Helper.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_preguntasCompleta.dart';

class SectionCrud {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> insertSectionCrud(List<SpPreguntascompleta> questions) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      for (var question in questions) {
        await txn.insert('SeccionPreguntas', question.toJson());
      }
    });
  }

  Future<List<SpPreguntascompleta>> querySectionCrud() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'SeccionPreguntas',
      where: 'estado = ?',
      whereArgs: [1]
    );
    return List.generate(maps.length, (i) {
      return SpPreguntascompleta.fromJson(maps[i]);
    });
  }

  // Método para truncar la tabla SeccionPreguntas
  Future<void> truncateSectionCrud() async {
    final db = await _databaseHelper.database;
    await db.execute('DELETE FROM SeccionPreguntas');
    print('Tabla SeccionPreguntas truncada.');
  }
}

/*Future<int> insertSectionCrud(SpPreguntascompleta question) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'SeccionPreguntas',
      question.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }*/

/*Future<void> insertSectionCrud(SpPreguntascompleta question) async {
    final db = await _databaseHelper.database;
    try {
      await db.insert(
        'SeccionPreguntas',
        question.toJson(), // Convierte el objeto a un mapa
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("✅ Pregunta insertada: ${question.sp_Pregunta}");
    } catch (e) {
      print("⚠️ Error al insertar pregunta: $e");
    }
  }*/