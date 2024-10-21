import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:formulario_opret/models/login.dart';
import 'package:formulario_opret/screens/login_Screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceToken {
  final String baseUrl;
  bool isLogged;

  ApiServiceToken(this.baseUrl, this.isLogged);

  //-------------------------------------Login------------------------------------------
  Future<String> loginUser(Login login) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/Login/User'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(login.toJson()),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        String token = jsonResponse['result'];
        isLogged = true;
        // Guardar el token en SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return token; // Devuelve el JWT
      } else {
        print('Error al iniciar sesión: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        return '';
      }
    } catch (e) {
      // Manejo de excepciones
      print('Error al iniciar sesión: $e');
      rethrow;
    }
  }

  // crear una funcion que permita retornar el estado de la session

  bool isLoggedFuncion(){
    return isLogged;
  }

  // Función para cerrar sesión

  Future<void> logout(BuildContext context) async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/api/Login/Logout'),
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
          }
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          await prefs.remove('token');
          isLogged = false;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()), // Redirige al login
            (Route<dynamic> route) => false,
          );

        } else {
          print('Error al cerrar sesión: ${response.statusCode}');
        }
      }

    } catch (e) {
      print('Error al cerrar sesión: $e');
      rethrow;
    }
  }

   // funcion logout(){
  //   isLogged = false;
  //   redireccionar al login page 
  //}
}