import 'package:formulario_opret/models/Stored%20Procedure/Exportados/sp_Respuestas_Export.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Filtrar_Respuestas.dart';
import 'package:formulario_opret/models/Stored%20Procedure/sp_Insertar_Respuestas.dart';
import 'package:formulario_opret/services/http_interactor_services.dart';
import 'package:http/http.dart' as http;

class ApiServiceRespuesta {
  final String baseUrl;
  final ApiService service;

  ApiServiceRespuesta(this.baseUrl) : service = ApiService(baseUrl);

  Future<http.Response> postRespuesta(List<SpInsertarRespuestas> respuestas) async {
    if (respuestas.isEmpty) {
      throw Exception('No hay respuestas para enviar.');
    }

    final isCheckOk = await service.check();
    if (!isCheckOk) {
      throw Exception('No hay conexión con la API.');
    }

    try {
      // Convertir la lista de respuestas a JSON
      List<Map<String, dynamic>> respuestasJson = respuestas.map((r) => r.toJson()).toList();

      // Enviar el array de respuestas a la API
      final response = await service.postDataList('Respuestas/insertar', respuestasJson);

      print('✅ Respuesta enviada correctamente: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Error al enviar respuestas: $e');
      throw Exception('Error en la solicitud POST: $e');
    }
  }
  
  Future<List<SpFiltrarRespuestas>> getRespuestas() async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try{
        final response = await service.getAllData('Respuestas/ObtenerResp');
        return response.map((json) => SpFiltrarRespuestas.fromJson(json)).toList();
      } catch(e) {
        print('Error al cargar las Respuestas: $e');
        rethrow;
      }
    } else {
      throw Exception('No se pudo conectar a la API');
    }
  }

  Future<List<SpRespuestasExport>> getExportReporte() async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try{
        final response = await service.getAllData('Report/ExportReporte');
        return response.map((json) => SpRespuestasExport.fromJson(json)).toList();
      } catch(e) {
        print('Error al cargar el reporte: $e');
        rethrow;
      }
    } else {
      throw Exception('No se pudo conectar a la API');
    }
  }
}