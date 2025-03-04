import 'package:formulario_opret/models/resertPassword.dart';
import 'package:formulario_opret/services/http_interactor_services.dart';
import 'package:http/http.dart' as http;

class ApiResertPasswordServices {
  final String baseUrl;
  final ApiService service;

  ApiResertPasswordServices(this.baseUrl) : service = ApiService(baseUrl);

  Future<http.Response> postEmail(Request request) async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.postData('PasswordRecovery/request', request.toJson());
        if (response.statusCode == 200) {
          print('✔️ Email enviado correctamente');
        } else {
          print('❌ Error al enviar el email: ${response.statusCode}');
        }
        return response;
      } catch (e) {
        print('❌ Error en la solicitud POST: $e');
        throw Exception('Error en la solicitud POST: $e');
      }
    } else {
      throw Exception('No hay conexión con la API.');
    }
  }

  Future<http.Response> postResertPassword(Resertpassword resert) async {
    final isCheckOk = await service.check();
    if (isCheckOk) {
      try {
        final response = await service.postData('PasswordRecovery/reset', resert.toJson());
        if (response.statusCode == 200) {
          print('✔️ Token y nueva contraseña enviados correctamente');
        } else {
          print('❌ Error al enviar el token y la nueva contraseña: ${response.statusCode}');
        }
        return response;
      } catch (e) {
        print('❌ Token inválido o expirado: $e');
        throw Exception('Error en la solicitud POST: $e');
      }
    } else {
      throw Exception('No hay conexión con la API.');
    }
  }
}