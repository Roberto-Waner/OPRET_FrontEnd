import 'package:formulario_opret/data/respuesta_crud.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Insertar_Respuestas.dart';
import 'package:formulario_opret/services/Stream/stream_services.dart';
import 'package:formulario_opret/services/respuestas_services.dart';

class RespuestaController {
  final RespuestaCrud _respuestaCrud = RespuestaCrud();
  // final RespuestaRepository _respuestaRepository = RespuestaRepository();
  final ApiServiceRespuesta _apiServiceRespuesta = ApiServiceRespuesta('https://10.0.2.2:7190');
  final StreamServices _streamServices = StreamServices('https://10.0.2.2:7190');

  RespuestaController() {
    _streamServices.backendAvailabilityStream.listen((isAvailable) {
      if (isAvailable) {
        syncDataResp();
        print('API disponible: puedes sincronizar datos.');
      } else {
        print('API no disponible: guarda datos localmente.');
      }
    });
  }

  Future<void> saveRespuesta(List<SpInsertarRespuestas> respuesta) async {
    try{
      final remoteResponse = await _apiServiceRespuesta.postRespuesta(respuesta);

      if(remoteResponse.statusCode == 201) {
        print('Respuesta guardado en servidor');
      } else {
        await _respuestaCrud.insertRespuestas(respuesta);
      }
    } catch (e) {
      print('Error al enviar respuesta a la api: $e');
      await _respuestaCrud.insertRespuestas(respuesta);
      print('Respuesta guardado en base de datos local SQLite con éxito');
    }
  }

  Future<void> syncDataResp() async {
    try{
      List<SpInsertarRespuestas> respuestasPendientes = await _respuestaCrud.getAnswerCrud();

      if (respuestasPendientes.isNotEmpty) {
        // Envía las respuestas al backend
        final postResponse = await _apiServiceRespuesta.postRespuesta(respuestasPendientes);

        // Si la sincronización es exitosa, vacía la tabla local
        if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
          await _respuestaCrud.vaciarTable();
          print('Respuestas sincronizadas con la API y tabla local vaciada');
        } else {
          print('Error al sincronizar las respuestas: ${postResponse.statusCode}');
          print('Cuerpo de la respuesta: ${postResponse.body}');
        }
      } else {
        print('No hay respuestas pendientes para sincronizar');
      }
    } catch (e) {
      print('Error al sincronizar la respuesta: $e');
    }
  }

  // Liberar recursos cuando el controlador no se necesite más
  // void dispose() {
  //   _streamServices.dispose();
  // }
}

// await _respuestaCrud.insertRespuesta(respuesta);
// try{
//   final localResponse = await _respuestaCrud.insertRespuesta(respuesta);
//   if(localResponse == 201) {
//     print('Respuesta guardado localmente');
//   } else {
//     final remoteResponse = await _apiServiceRespuesta.postRespuesta(respuesta);
//     if(remoteResponse.statusCode == 201) {
//       print('Respuesta guardado en servidor');
//     } else {
//       localResponse;
//     }
//   }
// } catch (e) {
//   rethrow;
// }

/*
Future<void> syncDataResp() async {
  try{
    List<SpInsertarRespuestas> respuestasPendientes = await _respuestaCrud.getAnswerCrud();

    if(respuestasPendientes.isNotEmpty) {
      for (var answer in respuestasPendientes) {
        final isCheckOk = await _apiServiceRespuesta.service.check();
        if (isCheckOk) {
          final postResponse = await _apiServiceRespuesta.postRespuesta([answer]);
          if (postResponse.statusCode == 201) {
            await _respuestaCrud.marcarRespuestaSincronizada(answer.idSesion); // usamos idSesion para identificar
            print('Respuesta sincronizada con la api');
          }else {
            print('Error al sincronizar la respuesta: ${postResponse.statusCode}');
          }
        } else {
          print('No hay conexión a la API para sincronizar la respuesta.');
        }
      }
    }
  } catch (e) {
    print('Error al sincronizar la respuesta: $e');
  }
}
*/