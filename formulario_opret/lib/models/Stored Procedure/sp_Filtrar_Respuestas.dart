class SpFiltrarRespuestas {
  String? sp_IdUsuarios;
  String? sp_Cedula;
  String? sp_NombreApellido;
  String? sp_Usuarios;
  String? sp_NoEncuesta;
  int? sp_IdSesion;
  int? sp_CodPreguntas;
  String? sp_Preguntas;
  String? sp_CodSupPreguntas;
  String? sp_SupPreguntas;
  String? sp_Respuestas;
  String? sp_Comentarios;
  String? sp_Justificacion;

  SpFiltrarRespuestas({
    this.sp_IdUsuarios,
    this.sp_Cedula,
    this.sp_NombreApellido,
    this.sp_Usuarios,
    this.sp_NoEncuesta,
    this.sp_IdSesion,
    this.sp_CodPreguntas,
    this.sp_Preguntas,
    this.sp_CodSupPreguntas,
    this.sp_SupPreguntas,
    this.sp_Respuestas,
    this.sp_Comentarios,
    this.sp_Justificacion
  });

  factory SpFiltrarRespuestas.fromJson(Map<String, dynamic> json) {
    return SpFiltrarRespuestas(
      sp_IdUsuarios: json['idUsuarios'],
      sp_Cedula: json['cedula'],
      sp_NombreApellido: json['nombreApellido'],
      sp_Usuarios: json['usuarios'],
      sp_NoEncuesta: json['noEncuesta'],
      sp_IdSesion: json['idSesion'],
      sp_CodPreguntas: json['codPreguntas'],
      sp_Preguntas: json['preguntas'],
      sp_CodSupPreguntas: json['codSupPreguntas'],
      sp_SupPreguntas: json['subPreguntas'],
      sp_Respuestas: json['respuestas'],
      sp_Comentarios: json['comentarios'],
      sp_Justificacion: json['justificacion']
    );
  }
}