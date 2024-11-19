class SpFiltrarFormRegistro {
  String? sp_IdUsuarios ;
  String? sp_Cedula;
  String? sp_Usuarios;
  String? sp_NombreApellido;
  String? sp_FechaEncuesta;
  String? sp_HoraEncuesta;
  String? sp_NombreLinea;
  String? sp_NombrEstacion;

  SpFiltrarFormRegistro({
    this.sp_IdUsuarios,
    this.sp_Cedula,
    this.sp_Usuarios,
    this.sp_NombreApellido,
    this.sp_FechaEncuesta,
    this.sp_HoraEncuesta,
    this.sp_NombreLinea,
    this.sp_NombrEstacion
  });

  factory SpFiltrarFormRegistro.fromJson(Map<String, dynamic> json) {
    return SpFiltrarFormRegistro(
      sp_IdUsuarios: json['idUsuarios'],
      sp_Cedula: json['cedula'],
      sp_Usuarios: json['usuarios'],
      sp_NombreApellido: json['nombreApellido'],
      sp_FechaEncuesta: json['fechaEncuesta'],
      sp_HoraEncuesta: json['horaEncuesta'],
      sp_NombreLinea: json['nombreLinea'],
      sp_NombrEstacion: json['nombrEstacion'],
    );
  }
}

// class SpFiltrarFormRegistro {
//   String sp_idUsuarios;
//   String sp_Cedula;
//   String sp_NombreApellido;
//   String sp_Usuario;
//   String sp_Email;
//   String sp_Fecha;
//   String sp_Hora;
//   int sp_Estacion;
//   String sp_Linea;

//   SpFiltrarFormRegistro({
//     required this.sp_idUsuarios,
//     required this.sp_Cedula,
//     required this.sp_NombreApellido,
//     required this.sp_Usuario,
//     required this.sp_Email,
//     required this.sp_Fecha,
//     required this.sp_Hora,
//     required this.sp_Estacion,
//     required this.sp_Linea
//   });

//   factory SpFiltrarFormRegistro.fromJson(Map<String, dynamic> json) {
//     return SpFiltrarFormRegistro(
//       sp_idUsuarios: json['idUsuarios'],
//       sp_Cedula: json['cedula'],
//       sp_NombreApellido: json['nombreApellido'],
//       sp_Usuario: json['usuario'],
//       sp_Email: json['email'],
//       sp_Fecha: json['fechEncuestas'],
//       sp_Hora: json['horaEncuestas'],
//       sp_Estacion: json['idEstacion'],
//       sp_Linea: json['idLinea'],
//     );
//   }
// }

/*
no se podra aplicar este stored procedure debido aqui tambien se tendria que hacer otro para filtrar 
String sp_idUsuarios;
  String sp_Cedula;
  String sp_NombreApellido;
  String sp_Usuario;
  String sp_Email;
  String sp_Fecha;
  String sp_Hora;
  int sp_Estacion;
  String sp_Linea;

  todos estos campos por lo que se deja en obsolecto en esta parte 
*/