import 'dart:convert';
import 'dart:io';
import 'package:formulario_opret/models/formulario_Registro.dart';
import 'package:http/http.dart' as http;

class ApiServiceLineas {
  final String baseUrl;

  ApiServiceLineas(this.baseUrl);

  Future<List<Linea>> getLinea() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/api/Lineas')).timeout(const Duration(seconds: 30));

      if(response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => Linea.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar la Linea: ${response.statusCode}');
      }
      
    }catch(e){
      print('Error al cargar la Linea: $e');
      rethrow;
    }
  }

  Future<http.Response> postLinea(Linea linea) async {
    try{
      final response = await http.post(
        Uri.parse('$baseUrl/api/Lineas'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(linea.toJson()),
      ).timeout(const Duration(seconds: 30));

      if(response.statusCode == 201){
        print('Linea creada con éxito');
      }else {
        print('Error al crear la Linea: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    }catch (e) {
      // Manejo de excepciones generales, como problemas de red
      print('Error al crear la Linea: $e');
      rethrow; // Lanza de nuevo la excepción si se desea manejar más arriba
    }
  }

  Future<http.Response> putLinea(String id, Linea linea) async {
    try{
      final response = await http.put(
        Uri.parse('$baseUrl/api/Lineas/$id'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(linea.toJson()),
      ).timeout(const Duration(seconds: 30));

      if(response.statusCode == 204) {
        print('Linea actualizada con éxito');
      }else{
        print('Error al actualizar la Linea: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch (e) {
      print('Error al actualizar la Linea: $e');
      rethrow;
    }
  }

  Future<http.Response> deleteLineas(String id) async {
    try{
      final response = await http.delete(
        Uri.parse('$baseUrl/api/Lineas/$id'),
      ).timeout(const Duration(seconds: 30));

      if(response.statusCode == 204) {
        print('Linea eliminada con éxito');
        return response;
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        print('Error del backend: ${responseBody['message']}');
        return response;
      }/* else {
        print('Error al eliminar la Linea: ${response.statusCode}');
        return response;
        // print('Cuerpo de la respuesta: ${response.body}');
      }*/

      return response;
    }catch (e) {
      print('Error al eliminar la Linea: $e');
      rethrow;
    }
  }
}