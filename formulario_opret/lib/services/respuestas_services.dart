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


/*
class ApiServiceRespuesta {
  final String baseUrl;

  ApiServiceRespuesta(this.baseUrl);

  // GET: api/Respuestas
  Future<List<Respuesta>> getRespuestas() async {
    try{
      final response = await http.get(
        Uri.parse('$baseUrl/api/Respuestas')
      ).timeout(const Duration(seconds: 20));

      if(response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => Respuesta.fromJson(json)).toList();
      }else {
        throw Exception('Error al cargar las Respuestas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar las respuestas: $e');
      rethrow;
    }
  }

  // POST: api/Respuestas
  Future<http.Response> postRespuesta(Respuesta respuesta) async {
    try{
      final response = await http.post(
        Uri.parse('$baseUrl/api/Respuestas'),
        headers: {
          HttpHeaders.contentTypeHeader:  'application/json',
        },
        body: jsonEncode(respuesta.toJson())
      ).timeout(const Duration(seconds: 20));

      if(response.statusCode == 201) {
        print('Respuesta enviada con exito');
      }else {
        print('Error al enviar la respuesta: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch (e) {
      print('Error al cargar las respuestas: $e');
      rethrow;
    }
  }

  // PUT: api/Respuestas/5
  Future<http.Response> putRespuesta (int id, Respuesta respuesta) async {
    try{
      final response = await http.put(
        Uri.parse('$baseUrl/api/Respuestas/$id'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(respuesta.toJson()),
      ).timeout(const Duration(seconds: 20));

      if(response.statusCode == 204) {
        print('Respuesta actualizada con exito');
      }else {
        print('Error al actualizar la Respuesta: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch (e) {
      print('Error al actualizar la respuesta $e');
      rethrow;
    }
  }

  // DELETE: api/Respuestas/5
  Future<http.Response> deleteRespuestas(int id) async {
    try{
      final response = await http.delete(
        Uri.parse('$baseUrl/api/Respuestas/$id'),
      ).timeout(const Duration(seconds: 20));

      if(response.statusCode == 204) {
        print('Respuesta eliminada con exito');
      }else{
        print('Error al eliminar la respuesta: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    }catch (e) {
      print('Error al eliminar la respuestas: $e');
      rethrow;
    }
  }
}
*/