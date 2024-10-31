import 'dart:convert';
import 'package:formulario_opret/data/user_crud.dart';
import 'package:formulario_opret/models/usuarios.dart';
import 'package:formulario_opret/services/http_interactor_services.dart';
import 'package:http/http.dart' as http;

class ApiServiceUser {
  final String baseUrl;
  final ApiService service;
  final UserCrud _usuariosCRUD = UserCrud();

  ApiServiceUser(this.baseUrl) : service = ApiService(baseUrl);

  // Método para crear un usuario (POST: api/Usuarios)
  Future<http.Response> createUsuario(Usuarios user) async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.postData('$baseUrl/api/RegistroUsuarios', user.toJson()).timeout(const Duration(seconds: 30));
        if (response.statusCode == 201) {
          print('Usuario creado con éxito');
        } else {
          print('Error al crear el usuario: ${response.statusCode}');
          print('Cuerpo de la respuesta: ${response.body}');
        }
        return response;
      } catch (e) {
        print('Error al crear Usuario: $e');
        rethrow;
      }
    } else {
      // Guardar en SQLite
      await _usuariosCRUD.insertUserCrud(user).timeout(const Duration(seconds: 30));
      return http.Response('Creado en SQLite', 201);
    }
  }

  // GET: api/Usuarios
  Future<List<Usuarios>> getUsuarios() async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.getAllData('$baseUrl/api/RegistroUsuarios').timeout(const Duration(seconds: 30));
        return response.map((json) => Usuarios.fromJson(json)).toList();
      } catch (e) {
        print('Error al cargar usuarios: $e');
        rethrow;
      }
    } else {
      // Leer desde SQLite
      return await _usuariosCRUD.getUsersCrud().timeout(const Duration(seconds: 30));
    }
  }

  // Método para obtener un usuario por ID (GET: api/Usuarios/{id})
  Future<Usuarios?> getOneUsuario(String id) async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.getOneData('$baseUrl/api/RegistroUsuarios', id).timeout(const Duration(seconds: 30));
        if (response.statusCode == 200) {
          return Usuarios.fromJson(jsonDecode(response.body));
        } else if (response.statusCode == 404) {
          print('Usuario no encontrado');
          return null;
        } else {
          throw Exception('Error al obtener el usuario. Código de estado: ${response.statusCode}');
        }
      } catch (e) {
        print('Error en la solicitud HTTP: $e');
        rethrow;
      }
    } else {
      // Leer desde SQLite
      return await _usuariosCRUD.getOneUserCrud(id).timeout(const Duration(seconds: 30));
    }
  }

  // Método para actualizar un usuario (PUT: api/Usuarios/{id})
  Future<http.Response> updateUsuario(String id, Usuarios user) async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.putData('$baseUrl/api/RegistroUsuarios/$id', user.toJson()).timeout(const Duration(seconds: 30));
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
    } else {
      // Actualizar en SQLite
      await _usuariosCRUD.updateUserCrud(id, user).timeout(const Duration(seconds: 30));
      return http.Response('Actualizado en SQLite', 204);
    }
  }

  // Método para eliminar un usuario (DELETE: api/Usuarios/{id})
  Future<http.Response> deleteUsuario(String id) async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.deleteData('$baseUrl/api/RegistroUsuarios/$id').timeout(const Duration(seconds: 30));
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
    } else {
      // Marcar como eliminado en SQLite
      await _usuariosCRUD.deleteUserCrud(id).timeout(const Duration(seconds: 30));
      return http.Response('Eliminado en SQLite', 204);
    }
  }
}