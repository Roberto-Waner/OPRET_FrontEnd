class SpRespuestasExport {
  String? rp_IdUsuarios;
  String? rp_NombreApellido;
  String? rp_Usuarios;
  String? rp_Email;
  int? rp_IdFormulario;
  String? rp_FechaInicioEncuesta;
  String? rp_HoraInicioEncuesta;
  String? rp_NombreLinea;
  String? rp_NombreEstacion;
  int? rp_IdSesion;
  int? rp_CodPreg;
  String? rp_Pregunta;
  String? rp_CodSubPreg;
  String? rp_SubPregunta;
  String? rp_NoEncuestas;
  String? rp_TipoResp;
  String? rp_HoraRespondida;
  String? rp_Respuestas;
  String? rp_Comentarios;
  String? rp_Justificacion;

  SpRespuestasExport({
    this.rp_IdUsuarios,
    this.rp_NombreApellido,
    this.rp_Usuarios,
    this.rp_Email,
    this.rp_IdFormulario,
    this.rp_FechaInicioEncuesta,
    this.rp_HoraInicioEncuesta,
    this.rp_NombreLinea,
    this.rp_NombreEstacion,
    this.rp_IdSesion,
    this.rp_CodPreg,
    this.rp_Pregunta,
    this.rp_CodSubPreg,
    this.rp_SubPregunta,
    this.rp_NoEncuestas,
    this.rp_TipoResp,
    this.rp_HoraRespondida,
    this.rp_Respuestas,
    this.rp_Comentarios,
    this.rp_Justificacion
  });

  factory SpRespuestasExport.fromJson(Map<String, dynamic> json) {
    return SpRespuestasExport(
      rp_IdUsuarios: json["rp_IdUsuarios"],
      rp_NombreApellido: json["rp_NombreApellido"],
      rp_Usuarios: json["rp_Usuarios"],
      rp_Email: json["rp_Email"],
      rp_IdFormulario: json["rp_IdFormulario"],
      rp_FechaInicioEncuesta: json["rp_FechaInicioEncuesta"],
      rp_HoraInicioEncuesta: json["rp_HoraInicioEncuesta"],
      rp_NombreLinea: json["rp_NombreLinea"],
      rp_NombreEstacion: json["rp_NombreEstacion"],
      rp_IdSesion: json["rp_IdSesion"],
      rp_CodPreg: json["rp_CodPreg"],
      rp_Pregunta: json["rp_Pregunta"],
      rp_CodSubPreg: json["rp_CodSubPreg"],
      rp_SubPregunta: json["rp_SubPregunta"],
      rp_NoEncuestas: json["rp_NoEncuestas"],
      rp_TipoResp: json["rp_TipoResp"],
      rp_HoraRespondida: json["rp_HoraRespondida"],
      rp_Respuestas: json["rp_Respuestas"],
      rp_Comentarios: json["rp_Comentarios"],
      rp_Justificacion: json["rp_Justificacion"]
    );
  }
}