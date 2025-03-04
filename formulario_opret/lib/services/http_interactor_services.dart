import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  //para verificar si hay conexión a internet
  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Método para consultar el endpoint 'check'
  Future<bool> check() async {
    final url = Uri.parse('$baseUrl/api/Check');
    final response = await http.get(url);

    // Suponiendo que el endpoint 'check' devuelve un 200 si está disponible
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // Método GET
  Future<List<dynamic>> getAllData(String endpoint) async {
    final isCheckOk = await check();

    final hasConnection = await _hasInternetConnection();
    if (!hasConnection) {
      throw Exception('No hay conexión a internet');
    }

    if (isCheckOk) {
      try {
        final url = Uri.parse('$baseUrl/api/$endpoint');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Error al obtener datos');
        }
      } catch (e) {
        // print('Error en getAllData: $e');
        throw Exception('Error en getAllData: $e');
      }

    } else {
      throw Exception('La API no está disponible');
    }
  }

  // Método para obtener un único elemento por ID (getOne)
  Future<dynamic> getOneData(String endpoint, String id) async {
    final hasConnection = await _hasInternetConnection();
    if (!hasConnection) {
      throw Exception('No hay conexión a internet');
    }

    // Verifica el endpoint 'check' antes de continuar
    final isCheckOk = await check();
    if (!isCheckOk) throw Exception('El endpoint check getOneData falló');

    try {
      final url = Uri.parse('$baseUrl/api/$endpoint/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body); // Devolver JSON decodificado
      } else if (response.statusCode == 404) {
        return {}; // Si no se encuentra, devolver un mapa vacío
      } else {
        throw Exception('La API no está disponible');
      }

    } catch (e) {
      // print('Error en getAllData: $e');
      throw Exception('Error en getOneData: $e');
    }
  }

  // Método POST
  Future<http.Response> postData(String endpoint, Map<String, dynamic> data) async {
    final isCheckOk = await check();
    final hasConnection = await _hasInternetConnection();

    if (!hasConnection) {
      throw Exception('No hay conexión a internet');
    }

    try {
      if (isCheckOk) {
        final url = Uri.parse('$baseUrl/api/$endpoint');
        return await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
      } else {
        // Guardar en SQLite (esto debería ser manejado por el controlador correspondiente)
        throw Exception('La API no está disponible');
      }
    } catch (e) {
      // print('Error en getAllData: $e');
      throw Exception('Error en postData: $e');
    }
  }

  Future<http.Response> postDataList(String endpoint, List<Map<String, dynamic>> data) async {
    print('Enviando datos a la API: $data');

    final hasConnection = await _hasInternetConnection();

    if (!hasConnection) {
      throw Exception('No hay conexión a internet');
    }

    final isCheckOk = await check();
    if (!isCheckOk) {
      throw Exception('La API no está disponible');
    }

    final url = Uri.parse('$baseUrl/api/$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      )/*.timeout(const Duration(seconds: 30))*/;

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Respuesta recibida: ${response.body}');
      } else {
        print('❌ Error en la respuesta: ${response.statusCode} - ${response.body}');
      }

      return response;
    } catch (e) {
      print('❌ Error al enviar la solicitud: $e');
      throw Exception('Error en postDataList: $e');
    }
  }

  // Método PUT
  Future<http.Response> putData(String endpoint, Map<String, dynamic> data, String id) async {
    final isCheckOk = await check();
    final hasConnection = await _hasInternetConnection();

    if (!hasConnection) {
      throw Exception('No hay conexión a internet');
    }

    try {
      if (isCheckOk) {
        final url = Uri.parse('$baseUrl/api/$endpoint/$id');
        return await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
      } else {
        throw Exception('La API no está disponible');
      }
    } catch (e) {
      // print('Error en getAllData: $e');
      throw Exception('Error en putData: $e');
    }
  }

  Future<http.Response> putDataInt(String endpoint, Map<String, dynamic> data, int id) async {
    final isCheckOk = await check();
    final hasConnection = await _hasInternetConnection();

    if (!hasConnection) {
      throw Exception('No hay conexión a internet');
    }

    try {
      if (isCheckOk) {
        final url = Uri.parse('$baseUrl/api/$endpoint/$id');
        return await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
      } else {
        throw Exception('La API no está disponible');
      }
    } catch (e) {
      // print('Error en getAllData: $e');
      throw Exception('Error en putDataInt: $e');
    }
  }

  // Método DELETE
  Future<http.Response> deleteData(String endpoint, String id) async {
    final isCheckOk = await check();
    final hasConnection = await _hasInternetConnection();

    if (!hasConnection) {
      throw Exception('No hay conexión a internet');
    }

    try {
      if (isCheckOk) {
        final url = Uri.parse('$baseUrl/api/$endpoint/$id');
        return await http.delete(url);
      } else {
        throw Exception('La API no está disponible');
      }
    } catch (e) {
      // print('Error en getAllData: $e');
      throw Exception('Error en deleteData: $e');
    }
  }
}

// Método POST en listados
// Future<http.Response> postDataList(String endpoint, List<Map<String, dynamic>> data) async {
//
//   print('data: $data');
//   final isCheckOk = await check();
//   if (isCheckOk) {
//     final url = Uri.parse('$baseUrl/api/$endpoint');
//     return await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(data),
//     )/*.timeout(const Duration(seconds: 30))*/;
//   } else {
//     throw Exception('La API no está disponible');
//   }
// }