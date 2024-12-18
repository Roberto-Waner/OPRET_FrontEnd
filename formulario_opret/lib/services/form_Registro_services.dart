import 'package:formulario_opret/models/Stored%20Procedure/sp_Filtrar_FormRegistro.dart';
import 'package:formulario_opret/models/formulario_Registro.dart';
import 'package:formulario_opret/services/http_interactor_services.dart';
import 'package:http/http.dart' as http;

class ApiServiceFormRegistro {
  final String baseUrl;
  final ApiService service;
  
  ApiServiceFormRegistro(this.baseUrl) : service = ApiService(baseUrl);

  Future<List<SpFiltrarFormRegistro>> getFormRegistro() async {
    final isCheckOk = await service.check();

    if(isCheckOk) {
      try{
        final response = await service.getAllData('Formularios/ObtenerForm');
        return response.map((json) => SpFiltrarFormRegistro.fromJson(json)).toList();
      } catch(e) {
        print('Error al cargar los Registro: $e');
        rethrow;
      }
    } else {
      throw Exception('No se pudo conectar a la API');
    }
  }

  Future<http.Response> postFormRegistro(FormularioRegistro formReg) async {
    final isCheckOk = await service.check();

    if(isCheckOk) {
      try{
        return await service.postData('Formularios', formReg.toJson());
      } catch(e){
        print('Error al cargar los Registro: $e');
        rethrow;
      }
    } else {
      throw Exception('No se pudo conectar a la API');
    }
  }
}