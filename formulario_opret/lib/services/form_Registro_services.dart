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

  /*
  Future<List<SpFiltrarFormRegistro>> getByIdFiltrarForm(String filtrar) async {
    final isCheckOk = await service.check();
    if(isCheckOk) {
      try{
        final response = await service.getOneData('Formularios/filtrarForm', filtrar);
        return response.map<SpFiltrarFormRegistro>((json) => SpFiltrarFormRegistro.fromJson(json)).toList();
      } catch (e) { 
        print('Error al filtrar los formularios: $e'); 
        rethrow; 
      }
    } else {
      throw Exception('No se pudo conectar a la API');
    }
  }
  */
}

/*
class ApiServiceFormRegistro {
  final String baseUrl;

  ApiServiceFormRegistro(this.baseUrl);

  // GET: api/RegistroForms
  Future<List<FormularioRegistro>> getFormRegistro() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/api/Formularios')).timeout(const Duration(seconds: 20));

      if(response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => FormularioRegistro.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar el Registro de los formularios: ${response.statusCode}');
      }

    } catch(e){
      print('Error al cargar los Registro: $e');
      rethrow;
    }
  }

  // POST: api/RegistroForms
  Future<http.Response> postFormRegistro(FormularioRegistro formReg) async {
    try{
      final response = await http.post(
        Uri.parse('$baseUrl/api/Formularios'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(formReg.toJson())
      ).timeout(const Duration(seconds: 20));

      if(response.statusCode == 201){
        print('Registro creada con éxito');
      }else {
        print('Error al crear los registro: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch(e){
      print('Error al cargar los Registro: $e');
      rethrow;
    }
  }

  // PUT: api/RegistroForms/5
  Future<http.Response> putFormRegistro(String noEncuesta, FormularioRegistro formReg) async {
    try{
      final response = await http.put(
        Uri.parse('$baseUrl/api/Formularios/$noEncuesta'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(formReg.toJson())
      ).timeout(const Duration(seconds: 20));

      if(response.statusCode == 204){
        print('Registro actualizado con éxito');
      }else {
        print('Error al actualizado los registro: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch(e){
      print('Error al actualizado los Registro: $e');
      rethrow;
    }
  }

  // DELETE: api/RegistroForms/5
  Future<http.Response> deleteFormRegistro(String noEncuesta) async {
    try{
      final response = await http.delete(
        Uri.parse('$baseUrl/api/Formularios/$noEncuesta'),
      ).timeout(const Duration(seconds: 20));

      if(response.statusCode == 204){
        print('Registro elimidano con éxito');
      }else {
        print('Error al elimidano los registro: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
      }

      return response;
    } catch(e){
      print('Error al elimidar los Registro: $e');
      rethrow;
    }
  }
}
*/