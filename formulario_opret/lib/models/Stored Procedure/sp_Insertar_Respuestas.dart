class SpInsertarRespuestas {
  String idUsuarios;
  int idSesion;
  String respuesta;
  String? comentarios;
  String? justificacion;
  String? horaResp;
  String? fechaResp;
  int finalizarSesion;

  SpInsertarRespuestas({
    required this.idUsuarios,
    required this.idSesion,
    required this.respuesta,
    this.comentarios,
    this.justificacion,
    this.horaResp,
    this.fechaResp,
    required this.finalizarSesion
  });

  // Conversión desde JSON (cuando se recibe datos del backend)
  factory SpInsertarRespuestas.fromJson(Map<String, dynamic> json) {
    return SpInsertarRespuestas(
      idUsuarios: json['idUsuarios'],
      idSesion: json['idSesion'],
      respuesta: json['respuesta'],
      comentarios: json['comentarios'],
      justificacion: json['justificacion'],
      horaResp: json['horaResp'],
        fechaResp: json['fechaResp'],
      finalizarSesion: json['finalizarSesion'] // El backend ya devuelve bool
    );
  }

  // Conversión a JSON (cuando se envía datos al backend)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idUsuarios'] = idUsuarios;
    data['idSesion'] = idSesion;
    data['respuesta'] = respuesta;
    data['comentarios'] = comentarios;
    data['justificacion'] = justificacion;
    data['horaResp'] = horaResp;
    data['fechaResp'] = fechaResp;
    data['finalizarSesion'] = finalizarSesion;
    return data;
  }
}