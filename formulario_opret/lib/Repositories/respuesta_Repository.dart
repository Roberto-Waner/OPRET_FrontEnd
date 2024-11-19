// import 'package:formulario_opret/database_cache/Database_Helper.dart';
// import 'package:formulario_opret/models/Stored%20Procedure/sp_Insertar_Respuestas.dart';
// import 'package:sqflite/sqflite.dart';

// class RespuestaRepository {
//   Future<void> insertarRespuesta(SpInsertarRespuestas respuesta) async {
//     final db = await DatabaseHelper.instance.database;

//     // Verificar si finalizarSesion es true para incrementar el id
//     if(respuesta.finalizarSesion) {
//       // Obtener el último ID utilizado y sumarle 1
//       List<Map<String, dynamic>> result = await db.rawQuery('SELECT IFNULL(MAX(id), 0) + 1 AS id FROM RespuestasLocal');
//       int id = result.first['id'];

//       // Insertar la nueva respuesta con el nuevo ID 
//       await db.insert( 
//         'RespuestasLocal', 
//         respuesta.toJson()..['id'] = id, 
//         conflictAlgorithm: ConflictAlgorithm.replace, 
//       );

//       print('Sesión finalizada. Respuesta con ID $id insertada.');
//     } else {
//       // Mantener el mismo id para respuestas de la misma sesión
//       List<Map<String, dynamic>> result = await db.rawQuery('SELECT IFNULL(MAX(id), 1) AS id FROM RespuestasLocal');
//       int id = result.first['id'];

//       // Insertar la nueva respuesta con el nuevo ID 
//       await db.insert( 
//         'RespuestasLocal', 
//         respuesta.toJson()..['id'] = id, 
//         conflictAlgorithm: ConflictAlgorithm.replace, 
//       );

//       print('Respuesta añadida a la sesión con ID $id.');
//     }
//   }
// }

// // class RespuestaRepository {
// //   Future<void> insertarRespuesta(Respuesta respuesta, {required bool finalizarSesion}) async {
// //     final db = await DatabaseHelper.instance.database; 
// //     final year = DateFormat('yyyy').format(DateTime.now());

// //     // Verificar si el noEncuesta ya existe en la base de datos
// //     if(respuesta.noEncuesta != null) {
// //       List<Map<String, dynamic>> existingRespuesta = await db.query(
// //         'RespuestasLocal',
// //         where: 'noEncuesta = ?', 
// //         whereArgs: [respuesta.noEncuesta]
// //       );

// //       if (existingRespuesta.isNotEmpty) {
// //         // Si ya existe, actualizamos la respuesta
// //         await db.update( 
// //           'RespuestasLocal', 
// //           respuesta.toJson(), 
// //           where: 'noEncuesta = ?', 
// //           whereArgs: [respuesta.noEncuesta] 
// //         ); 
// //         print('Respuesta actualizada: ${respuesta.noEncuesta}');
// //       } else {
// //         // Si no existe, insertamos una nueva respuesta
// //         await db.insert('RespuestasLocal', respuesta.toJson());
// //       }
// //     }else { 
// //       // Si noEncuesta es null, simplemente insertamos la nueva respuesta 
// //       await db.insert('RespuestasLocal', respuesta.toJson()); 
// //     }

// //     // Generar el noEncuesta y actualizarlo solo si se finaliza la sesión
// //     if(finalizarSesion) {
// //       // Obtener el número de orden global para el año actual
// //       List<Map<String, dynamic>> ordenResult = await db.rawQuery(
// //         '''
// //           SELECT IFNULL(MAX(CAST(SUBSTR(noEncuesta, -2) AS INTEGER)), 0) + 1 AS orden
// //           FROM RespuestasLocal
// //           WHERE noEncuesta IS NOT NULL AND strftime('%Y', datetime('now')) = ?
// //         ''', [year]);
      
// //       int orden = ordenResult.first['orden'] ?? 0;
// //       String noEncuesta = '$year - ${orden.toString().padLeft(2, '0')}';

// //       // Actualizar el noEncuesta en la tabla RespuestasLocal para el conjunto de preguntas
// //       await db.rawUpdate(
// //         '''
// //           UPDATE RespuestasLocal
// //           SET noEncuesta = ?
// //           WHERE noEncuesta is null
// //         ''', [noEncuesta]);
      
// //       print('NoEncuesta generado: $noEncuesta');
// //     }
// //   }
// // }