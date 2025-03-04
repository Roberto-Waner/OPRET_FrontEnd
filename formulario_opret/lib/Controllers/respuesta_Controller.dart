import 'package:formulario_opret/data/respuesta_crud.dart';
import 'package:formulario_opret/data/stored_Respuestas_crud.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Insertar_Respuestas.dart';
import 'package:formulario_opret/services/Stream/stream_services.dart';
import 'package:formulario_opret/services/respuestas_services.dart';

class RespuestaController {
  final RespuestaCrud _respuestaCrud = RespuestaCrud();
  final StoredRespuestasCrud _storedRespuestasCrud = StoredRespuestasCrud();
  final ApiServiceRespuesta _apiServiceRespuesta = ApiServiceRespuesta('https://10.0.2.2:7190');
  final StreamServices _streamServices = StreamServices('https://10.0.2.2:7190');

  RespuestaController() {
    _streamServices.backendAvailabilityStream.listen((isAvailable) {
      if (isAvailable) {
        // syncDataResp();
        syncDataStoredResp();
        print('API disponible: Se pudo sincronizar los datos.');
      } else {
        print('API no disponible: Guardando los datos localmente.');
      }
    });
  }

  /*Future<void> syncDataResp() async {
    try{
      List<SpInsertarRespuestas> respuestasPendientes = await _respuestaCrud.getAnswerCrud();

      if (respuestasPendientes.isNotEmpty) {
        // Envía las respuestas al backend
        final postResponse = await _apiServiceRespuesta.postRespuesta(respuestasPendientes);
        print(postResponse);

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
  }*/

  Future<void> syncDataResp() async {
    try{
      List<SpInsertarRespuestas> respuestasPendientes = await _respuestaCrud.getAnswerCrud();

      if (respuestasPendientes.isNotEmpty) {
        // Envía las respuestas al backend
        final insertStored = await _storedRespuestasCrud.insertStoredRespCrud(respuestasPendientes);
        print(insertStored);
        // Si la inserción en la segunda tabla es exitosa, vacía la tabla original
        if (insertStored) {
          await _respuestaCrud.vaciarTable();
          print('La tabla localRespuestas ha sido formateada');
        }

        if (respuestasPendientes.isEmpty) {
          await syncDataStoredResp();
        }
      } else {
        print('No hay respuestas pendientes para sincronizar');
      }
    } catch (e) {
      print('Error al sincronizar la respuesta: $e');
    }
  }

  Future<void> syncDataStoredResp() async {
    try{
      List<SpInsertarRespuestas> storedRespPendientes = await _storedRespuestasCrud.queryStoredRespCrud();

      if (storedRespPendientes.isNotEmpty) {
        // Envía las respuestas al backend
        final postResponseApi = await _apiServiceRespuesta.postRespuesta(storedRespPendientes);

        // Si la sincronización es exitosa, vacía la tabla local
        if (postResponseApi.statusCode == 200 || postResponseApi.statusCode == 201) {
          await _storedRespuestasCrud.deleteAllStoredRespCrud();
          print('Respuestas sincronizadas con la API y tabla del almacenamiento local vaciada');
        } else {
          print('Error al sincronizar las respuestas: ${postResponseApi.statusCode}');
          print('Cuerpo de la respuesta: ${postResponseApi.body}');
        }
      } else {
        print('No hay respuestas pendientes para sincronizar');
      }
    } catch (e) {
      print('Error al sincronizar el almacenamiento storedRespuestas con la api: $e');
    }
  }
}