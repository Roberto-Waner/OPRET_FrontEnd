import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  // Método para consultar el endpoint 'check'
  Future<bool> check() async {
    final url = Uri.parse('$baseUrl/api/Check');
    final response = await http.get(url).timeout(const Duration(seconds: 30));

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
    if (isCheckOk) {
      final url = Uri.parse(endpoint);
      final response = await http.get(url).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener datos');
      }
    } else {
      throw Exception('La API no está disponible');
    }
  }

  // Método para obtener un único elemento por ID (getOne)
  Future<dynamic> getOneData(String endpoint, String id) async {
    // Verifica el endpoint 'check' antes de continuar
    final isCheckOk = await check();
    if (!isCheckOk) throw Exception('El endpoint check getOneData falló');

    final url = Uri.parse('$baseUrl/$endpoint/$id');
    final response = await http.get(url).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener el elemento');
    }
  }

  // Método POST
  Future<http.Response> postData(String endpoint, Map<String, dynamic> data) async {
    final isCheckOk = await check();
    if (isCheckOk) {
      final url = Uri.parse(endpoint);
      return await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));
    } else {
      // Guardar en SQLite (esto debería ser manejado por el controlador correspondiente)
      return http.Response('Creado en SQLite', 201);
    }
  }

  // Método PUT
  Future<http.Response> putData(String endpoint, Map<String, dynamic> data) async {
    final isCheckOk = await check();
    if (!isCheckOk) throw Exception('El endpoint check de putData falló');

    final url = Uri.parse(endpoint);
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    ).timeout(const Duration(seconds: 30));

    return response; // Retorna el response completo
  }

  // Método DELETE
  Future<http.Response> deleteData(String endpoint) async {
    final isCheckOk = await check();
    if (!isCheckOk) throw Exception('El endpoint check falló');

    final url = Uri.parse(endpoint);
    final response = await http.delete(url).timeout(const Duration(seconds: 30));

    return response; // Retorna el response completo
  }
}