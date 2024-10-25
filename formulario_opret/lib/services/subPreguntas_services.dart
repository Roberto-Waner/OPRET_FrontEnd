import 'dart:convert';
import 'dart:io';
import 'package:formulario_opret/models/pregunta.dart';
import 'package:http/http.dart' as http;

class ApiServiceSubPreguntas {
  final String baseUrl;

  ApiServiceSubPreguntas(this.baseUrl);

  Future<List<SubPregunta>> getSubPreg() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/api/SubPreguntas')).timeout(const Duration(seconds: 20));

      if(response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => SubPregunta.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar las sub-Preguntas: ${response.statusCode}');
      }

    }catch(e){
      print('Error al cargar las sub-Preguntas: $e');
      rethrow;
    }
  }

  Future<SubPregunta?> getOneSubPreg(String id) async {
    try{
      final response = await http.get(
        Uri.parse('$baseUrl/api/SubPreguntas/$id'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        return SubPregunta.fromJson(body);
      } else if (response.statusCode == 404) {
        print('SubPregunta no encontrada');
        return null;
      } else {
        throw Exception('Error al obtener la SubPregunta. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      rethrow;
    }
  }

  Future<http.Response> postSubPreg (SubPregunta subPreg) async {
    try{
      final response = await http.post(
        Uri.parse('$baseUrl/api/SubPreguntas'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(subPreg.toJson()),
      ).timeout(const Duration(seconds: 20));

      if(response.statusCode == 201){
        print('Sub-pregunta creada con éxito');
      }else {
        print('Error al crear las sub-Preguntas: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    }catch (e) {
      // Manejo de excepciones generales, como problemas de red
      print('Error al crear las sub-Preguntas: $e');
      rethrow; // Lanza de nuevo la excepción si se desea manejar más arriba
    }
  }

  Future<http.Response> putSubPreg (String cod, SubPregunta subPreg) async {
    try{
      final response = await http.put(
        Uri.parse('$baseUrl/api/SubPreguntas/$cod'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(subPreg.toJson()),
      ).timeout(const Duration(seconds: 20));

      if(response.statusCode == 204) {
        print('Sub-pregunta actualizada con éxito');
      }else{
        print('Error al actualizar las sub-Preguntas: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch (e) {
      print('Error al actualizar las sub-Preguntas: $e');
      rethrow;
    }
  }

  Future<http.Response> deleteSubPreg(String cod) async {
    try{
      final response = await http.delete(
        Uri.parse('$baseUrl/api/SubPreguntas/$cod'),
      ).timeout(const Duration(seconds: 20));

      if(response.statusCode == 204) {
        print('Sub-pregunta eliminada con éxito');
      }else{
        print('Error al eliminar las sub-Preguntas: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    }catch (e) {
      print('Error al eliminar las sub-Preguntas: $e');
      rethrow;
    }
  }
}