import 'dart:io';
import 'package:formulario_opret/models/Stored%20Procedure/sp_ObtenerEstacionPorLinea.dart';
import 'package:formulario_opret/models/formulario_Registro.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiServiceEstacion {
  final String baseUrl;

  ApiServiceEstacion(this.baseUrl);

  Future<List<Estacion>> getEstacion() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/api/Estacions')).timeout(const Duration(seconds: 30));

      if(response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => Estacion.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar la Estacions: ${response.statusCode}');
      }
      
    }catch(e){
      print('Error al cargar la Estacions: $e');
      rethrow;
    }
  }

  Future<Estacion?> getOneEstacion(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Estacions/$id'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      ).timeout(const Duration(seconds: 30)); // Limitar el tiempo de espera

      if (response.statusCode == 200) {
        // Si la respuesta es correcta, decodificamos y devolvemos la estación
        var body = jsonDecode(response.body);
        return Estacion.fromJson(body);
      } else if (response.statusCode == 404) {
        // Si la estación no se encuentra, devolvemos null
        print('Estación no encontrada');
        return null;
      } else {
        throw Exception('Error al obtener la estación. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      rethrow;
    }
  }

  // Método para obtener estaciones por línea
  Future<List<EstacionPorLinea>> getEstacionesPorLinea(String idLinea) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/Estacions/linea/$idLinea'))
        .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body)['result'];
        return body.map((json) => EstacionPorLinea.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar las estaciones por línea: ${response.statusCode}');
      }
      
    } catch (e) {
      print('Error al cargar las estaciones por línea: $e');
      rethrow;
    }
  }

  Future<http.Response> postEstacion(Estacion station) async {
    try{
      final response = await http.post(
        Uri.parse('$baseUrl/api/Estacions'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(station.toJson()),
      ).timeout(const Duration(seconds: 30));

      if(response.statusCode == 201){
        print('Estacion creada con éxito');
      }else {
        print('Error al crear la Estacion: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    }catch (e) {
      // Manejo de excepciones generales, como problemas de red
      print('Error al crear la Estacion: $e');
      rethrow; // Lanza de nuevo la excepción si se desea manejar más arriba
    }
  }

  Future<http.Response> putEstacion(int id, Estacion station) async {
    try{
      final response = await http.put(
        Uri.parse('$baseUrl/api/Estacions/$id'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(station.toJson()),
      ).timeout(const Duration(seconds: 30));

      if(response.statusCode == 204) {
        print('Estacion actualizada con éxito');
      }else{
        print('Error al actualizar la Estacion: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch (e) {
      print('Error al actualizar la Estacion: $e');
      rethrow;
    }
  }

  Future<http.Response> deleteEstacion(int id) async {
    try{
      final response = await http.delete(
        Uri.parse('$baseUrl/api/Estacions/$id'),
      ).timeout(const Duration(seconds: 30));

      if(response.statusCode == 204) {
        print('Estacion eliminada con éxito');
      }else{
        print('Error al eliminar la Estacion: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    }catch (e) {
      print('Error al eliminar la Estacion: $e');
      rethrow;
    }
  }
}