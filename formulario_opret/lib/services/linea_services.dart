import 'dart:convert';
import 'package:formulario_opret/models/formulario_Registro.dart';
import 'package:http/http.dart' as http;

class ApiServiceLineas {
  final String baseUrl;

  ApiServiceLineas(this.baseUrl);

  Future<List<Linea>> getLinea() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/api/Lineas')).timeout(const Duration(seconds: 20));

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
}