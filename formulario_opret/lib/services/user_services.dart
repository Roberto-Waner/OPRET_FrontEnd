import 'dart:convert';
import 'dart:io';
import 'package:formulario_opret/models/usuarios.dart';
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  // POST: api/Usuarios
  Future<http.Response> createUsuarios(Usuarios user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/RegistroUsuarios'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(user.toJson()),
      ).timeout(const Duration(seconds: 20)); // Timeout de 10 segundos

      if (response.statusCode == 201) {
        print('Usuario creado con éxito');
      } else {
        print('Error al crear el Usuario: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch (e) {
      // Manejo de excepciones generales, como problemas de red
      print('Error al crear Usuario: $e');
      rethrow; // Lanza de nuevo la excepción si se desea manejar más arriba
    }
  }

  // GET: api/Usuarios
  Future<List<ObtenerEmpleados>> getUsuarios() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/RegistroUsuarios/ObtenerEmpl'))
        .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => ObtenerEmpleados.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar usuarios: $e');
      rethrow;
    }
  }

  Future<Usuarios?> getOneUsuarios(String id) async {
    try{
      final response = await http.get(
        Uri.parse('$baseUrl/api/RegistroUsuarios/$id'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        return Usuarios.fromJson(body);
      } else if (response.statusCode == 404) {
        print('Usuarios no encontrada');
        return null;
      } else {
        throw Exception('Error al obtener la Usuarios. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      rethrow;
    }
  }

  // PUT: api/Usuarios/{id}
  Future<http.Response> updateUsuario(String id, Usuarios user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/RegistroUsuarios/$id'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(user.toJson()),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 204) {
        print('Usuario actualizado con éxito');
      } else {
        print('Error al actualizar usuario: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch (e) {
      print('Error al actualizar Usuario: $e');
      rethrow;
    }
  }

  // DELETE: api/Usuarios/{id}
  Future<http.Response> deleteUsuario(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/RegistroUsuarios/$id'),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 204) {
        print('Usuario eliminado con éxito');
      } else {
        print('Error al eliminar usuario: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch (e) {
      print('Error al eliminar Usuario: $e');
      rethrow;
    }
  }
}