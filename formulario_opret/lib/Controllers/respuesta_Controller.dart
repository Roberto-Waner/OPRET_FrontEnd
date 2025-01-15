import 'package:formulario_opret/data/respuesta_crud.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Insertar_Respuestas.dart';
import 'package:formulario_opret/services/Stream/stream_services.dart';
import 'package:formulario_opret/services/respuestas_services.dart';

class RespuestaController {
  final RespuestaCrud _respuestaCrud = RespuestaCrud();
  // final RespuestaRepository _respuestaRepository = RespuestaRepository();
  final ApiServiceRespuesta _apiServiceRespuesta = ApiServiceRespuesta('http://wepapi.somee.com');
  final StreamServices _streamServices = StreamServices('http://wepapi.somee.com');

  RespuestaController() {
    _streamServices.backendAvailabilityStream.listen((isAvailable) {
      if (isAvailable) {
        syncDataResp();
        print('API disponible: Se pudo sincronizar los datos.');
      } else {
        print('API no disponible: Guardando los datos localmente.');
      }
    });
  }

  //para sincronizar los datos de
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
}