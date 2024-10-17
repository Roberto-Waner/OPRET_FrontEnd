// import 'package:flutter/material.dart';

class FormularioRegistro {
  String noEncuesta;
  String idUsuarios;
  String cedula;
  String? fecha;
  String? hora;
  int? idEstacion;
  String? idLinea;

  FormularioRegistro({
    required this.noEncuesta,
    required this.idUsuarios,
    required this.cedula,
    this.fecha,
    this.hora,
    this.idEstacion,
    this.idLinea
  });

  factory FormularioRegistro.fromJson(Map<String, dynamic> json) {
    return FormularioRegistro(
      noEncuesta: json['noEncuesta'],
      idUsuarios: json['idUsuarios'],
      cedula: json['cedula'],
      fecha: json['fecha'],
      hora: json['hora'],
      idEstacion: json['idEstacion'],
      idLinea: json['idLinea'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['noEncuesta'] = noEncuesta;
    data['idUsuarios'] = idUsuarios;
    data['cedula'] = cedula;
    data['fecha'] = fecha;
    data['hora'] = hora;
    data['idEstacion'] = idEstacion;
    data['idLinea'] = idLinea;
    return data;
  }
}

class Linea {
  String idLinea;
  String tipo;
  String nombreLinea;

  Linea({
    required this.idLinea,
    required this.tipo,
    required this.nombreLinea
  });

  factory Linea.fromJson(Map<String, dynamic> json) {
    return Linea(
      idLinea: json['idLinea'],
      tipo: json['tipoLinea'],
      nombreLinea: json['nombreLinea'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idLinea'] = idLinea;
    data['tipoLinea'] = tipo;
    data['nombreLinea'] = nombreLinea;
    return data;
  }
}

class Estacion {
  int idEstacion;
  String idLinea;
  String nombreEstacion;

  Estacion({
    required this.idEstacion,
    required this.idLinea,
    required this.nombreEstacion
  });

  factory Estacion.fromJson(Map<String, dynamic> json) {
    return Estacion(
      idEstacion: json['idEstacion'],
      idLinea: json['idLinea'],
      nombreEstacion: json['nombreEstacion'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idEstacion'] = idEstacion;
    data['idLinea'] = idLinea;
    data['nombreEstacion'] = nombreEstacion;
    return data;
  }
}