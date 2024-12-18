class SpFiltrarFormRegistro {
  String? sp_IdUsuarios ;
  // String? sp_Cedula;
  String? sp_Usuarios;
  String? sp_NombreApellido;
  String? sp_FechaEncuesta;
  String? sp_HoraEncuesta;
  String? sp_NombreLinea;
  String? sp_NombrEstacion;

  SpFiltrarFormRegistro({
    this.sp_IdUsuarios,
    // this.sp_Cedula,
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
      // sp_Cedula: json['cedula'],
      sp_Usuarios: json['usuarios'],
      sp_NombreApellido: json['nombreApellido'],
      sp_FechaEncuesta: json['fechaEncuesta'],
      sp_HoraEncuesta: json['horaEncuesta'],
      sp_NombreLinea: json['nombreLinea'],
      sp_NombrEstacion: json['nombrEstacion'],
    );
  }
}