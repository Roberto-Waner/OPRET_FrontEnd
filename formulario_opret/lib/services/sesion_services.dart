import 'dart:convert';
import 'dart:io';
import 'package:formulario_opret/models/Stored%20Procedure/sp_preguntasCompleta.dart';
import 'package:formulario_opret/models/pregunta.dart';
import 'package:formulario_opret/services/http_interactor_services.dart';
import 'package:http/http.dart' as http;

class ApiServiceSesion2 {
  final String baseUrl;
  final ApiService service;

  ApiServiceSesion2(this.baseUrl) : service = ApiService(baseUrl);

  Future<List<SpPreguntascompleta>> getSpPreguntascompletaListada() async {
    List<SpPreguntascompleta> dataQuestion = [];
    final isCheckOk = await service.check();

    if (isCheckOk) {
      try {
        final response = await service.getAllData('PreguntasCompletas/obtenerQuestion');
        if (response.isNotEmpty) {
          dataQuestion = response.map<SpPreguntascompleta>((json) => SpPreguntascompleta.fromJson(json)).toList();
          return dataQuestion;
        } else {
          throw Exception('API response is empty.');
        }
      } catch (e) {
        print('Excepción durante la solicitud a la API: $e'); 
        rethrow;
      }
    } else {
      throw Exception('La API no está disponible.');
    }
  }
}

class ApiServiceSesion {
  final String baseUrl;

  ApiServiceSesion(this.baseUrl);

  Future<List<Sesion>> getSesion() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/api/Sesions')).timeout(const Duration(seconds: 30));

      if(response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => Sesion.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar la sesion: ${response.statusCode}');
      }

    }catch(e){
      print('Error al cargar la sesion: $e');
      rethrow;
    }
  }

  Future<http.Response> postSesion (Sesion sesion) async {
    try{
      final response = await http.post(
        Uri.parse('$baseUrl/api/Sesions'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(sesion.toJson()),
      ).timeout(const Duration(seconds: 30));

      if(response.statusCode == 201){
        print('Sesion creada con éxito');
      }else {
        print('Error al crear la sesion: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    }catch (e) {
      // Manejo de excepciones generales, como problemas de red
      print('Error al crear la sesion: $e');
      rethrow; // Lanza de nuevo la excepción si se desea manejar más arriba
    }
  }

  Future<http.Response> putSesion (int id, Sesion sesion) async {
    try{
      final response = await http.put(
        Uri.parse('$baseUrl/api/Sesions/$id'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(sesion.toJson()),
      ).timeout(const Duration(seconds: 30));

      if(response.statusCode == 204) {
        print('Sesion actualizada con éxito');
      }else{
        print('Error al actualizar la sesion: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch (e) {
      print('Error al actualizar la sesion: $e');
      rethrow;
    }
  }

  Future<http.Response> deleteSesion(int id) async {
    try{
      final response = await http.delete(
        Uri.parse('$baseUrl/api/Sesions/$id'),
      ).timeout(const Duration(seconds: 30));

      if(response.statusCode == 204) {
        print('Sesion eliminada con éxito');
      }else{
        print('Error al eliminar la sesion: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    }catch (e) {
      print('Error al eliminar la Sesion: $e');
      rethrow;
    }
  }
}