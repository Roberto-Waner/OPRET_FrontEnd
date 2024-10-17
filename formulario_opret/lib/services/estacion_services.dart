import 'package:formulario_opret/models/Stored%20Procedure/sp_ObtenerEstacionPorLinea.dart';
import 'package:formulario_opret/models/formulario_Registro.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiServiceEstacion {
  final String baseUrl;

  ApiServiceEstacion(this.baseUrl);

  Future<List<Estacion>> getEstacion() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/api/Estacions')).timeout(const Duration(seconds: 20));

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

  // Método para obtener estaciones por línea
  Future<List<EstacionPorLinea>> getEstacionesPorLinea(String idLinea) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/Estacions/linea/$idLinea'))
        .timeout(const Duration(seconds: 20));

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
}