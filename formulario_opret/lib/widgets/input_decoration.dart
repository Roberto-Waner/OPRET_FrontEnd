import 'package:flutter/material.dart';
class InputDecorations {
  static InputDecoration inputDecoration({
    String? hintext,
    required String labeltext,
    Widget? icono,
    double labelFrontSize = 16.0, // Tamaño de letra por defecto
    double hintFrontSize = 16.0, // Tamaño de letra por defecto
    String? prefixText, // Añadir prefixText
    double? errorSize = 16.0,
    Widget? suffIcon,
  }) {
    return InputDecoration(
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 39, 99, 41)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 23, 164, 28),
          width: 2
        ),
      ),
      hintText: hintext,
      labelText: labeltext,
      prefixIcon: icono,
      prefixText: prefixText, // Añadir prefixText aquí
      labelStyle: TextStyle(fontSize: labelFrontSize), // Cambiar tamaño de letra
      hintStyle: TextStyle(fontSize: hintFrontSize), // Cambiar tamaño de letra
      errorStyle: TextStyle(fontSize: errorSize),
      suffixIcon: suffIcon,
    );
  }
}