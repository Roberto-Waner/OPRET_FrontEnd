import 'package:formulario_opret/models/usuarios.dart';
import 'package:formulario_opret/services/http_interactor_services.dart';
import 'package:http/http.dart' as http;

class ApiServiceUser {
  final String baseUrl;
  final ApiService service;

  ApiServiceUser(this.baseUrl) : service = ApiService(baseUrl);

  // Método para crear un usuario (POST: api/Usuarios)
  Future<http.Response> createUsuario(Usuarios user) async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.postData('RegistroUsuarios', user.toJson()).timeout(const Duration(seconds: 30));
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
      throw Exception('No hay conexión con la API.');
    }
  }

  // GET: api/Usuarios
  Future<List<Usuarios>> getUsuarios() async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.getAllData('RegistroUsuarios').timeout(const Duration(seconds: 30));
        return response.map((json) => Usuarios.fromJson(json)).toList();
      } catch (e) {
        print('Error al cargar usuarios: $e');
        rethrow;
      }
    } else {
      // Leer desde SQLite
      throw Exception('No hay conexión con la API.');
    }
  }

  // Método para obtener un usuario por ID (GET: api/Usuarios/{id})
  Future<Usuarios?> getOneUsuario(String id) async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.getOneData('RegistroUsuarios', id).timeout(const Duration(seconds: 30));

        if (response.isNotEmpty) { // Verificar que response no está vacío 
          return Usuarios.fromJson(response); 
        } else { 
          print('Usuario no encontrado'); 
          return null; 
        }
      } catch (e) {
        print('Error en la solicitud HTTP: $e');
        rethrow;
      }
    } else {
      // Leer desde SQLite
      throw Exception('No hay conexión con la API.');
    }
  }

  // Método para actualizar un usuario (PUT: api/Usuarios/{id})
  Future<http.Response> updateUsuario(String id, Usuarios user) async {
    // var cache = await _usuariosCRUD.updateUserCrud(id, user).timeout(const Duration(seconds: 30));
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.putData('RegistroUsuarios', user.toJson(), id).timeout(const Duration(seconds: 30));
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
      throw Exception('No hay conexión con la API.');
    }
  }

  // Método para eliminar un usuario (DELETE: api/Usuarios/{id})
  Future<http.Response> deleteUsuario(String id) async {
    // var cache = await _usuariosCRUD.deleteUserCrud(id).timeout(const Duration(seconds: 30));
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.deleteData('RegistroUsuarios', id).timeout(const Duration(seconds: 30));
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
      throw Exception('No hay conexión con la API.');
    }
  }
}