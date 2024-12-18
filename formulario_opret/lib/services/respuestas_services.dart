import 'package:formulario_opret/models/Stored%20Procedure/sp_Filtrar_Respuestas.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Insertar_Respuestas.dart';
import 'package:formulario_opret/models/respuesta.dart';
import 'package:formulario_opret/services/http_interactor_services.dart';
import 'package:http/http.dart' as http;

import '../data/respuesta_crud.dart';

class ApiServiceRespuesta {
  final String baseUrl;
  final ApiService service;
  final RespuestaCrud _respuestaCrud = RespuestaCrud();

  ApiServiceRespuesta(this.baseUrl) : service = ApiService(baseUrl);

  Future<http.Response> postRespuesta(List<SpInsertarRespuestas> respuestas) async {
    // Intenta realizar una verificación de conexión antes de hacer la solicitud.
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        // Convertir la lista de respuestas a JSON 
        List<Map<String, dynamic>> respuestasJson = respuestas.map((r) => r.toJson()).toList();

        // Enviar el array de respuestas a la API
        final response = await service.postDataList('Respuestas/insertar', respuestasJson);

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Respuesta enviada a la API HTTP correctamente');
          await _respuestaCrud.vaciarTable();
        } else {
          print('Error al enviar respuesta a la API HTTP: ${response.statusCode}');
          print('Cuerpo de la respuesta: ${response.body}');
        }

        // print('Respuesta $response');
        return response;
      } catch (e) {
        print('Error al enviar respuesta a la API: $e');
        rethrow;
      }
    } else {
      throw Exception('No hay conexión con la API.');
    }
  }

  Future<http.Response> putRespuesta (String noEncuesta, Respuesta respuesta) async {
    final isCheckOk = await service.check();
    if(isCheckOk) {
      return await service.putData('Respuestas', respuesta.toJson(), noEncuesta);
    } else {
      return http.Response('Actualizado en SQLite', 204);
    }
  }

  Future<List<SpFiltrarRespuestas>> getRespuestas() async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try{
        final response = await service.getAllData('Respuestas/ObtenerResp');
        return response.map((json) => SpFiltrarRespuestas.fromJson(json)).toList();
      } catch(e) {
        print('Error al cargar las Respuestas: $e');
        rethrow;
      }
    } else {
      throw Exception('No se pudo conectar a la API');
    }
  }
}