class SpPreguntascompleta {
  int? sp_CodPregunta;
  String? sp_TipoRespuesta;
  String? sp_Pregunta;
  String? sp_SubPregunta;
  String? sp_Rango;

  SpPreguntascompleta({
    this.sp_CodPregunta,
    this.sp_TipoRespuesta,
    this.sp_Pregunta,
    this.sp_SubPregunta,
    this.sp_Rango,
  });

  // para estraer informacion desde el json "fromJson"
  factory SpPreguntascompleta.fromJson(Map<String, dynamic> json) {
    return SpPreguntascompleta(
      sp_CodPregunta: json['codPregunta'],
      sp_TipoRespuesta: json['tipoRespuesta'],
      sp_Pregunta: json['pregunta'],
      sp_SubPregunta: json['subPregunta'],
      sp_Rango: json['rango']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['codPregunta'] = sp_CodPregunta;
    data['tipoRespuesta'] = sp_TipoRespuesta;
    data['pregunta'] = sp_Pregunta;
    data['subPregunta'] = sp_SubPregunta;
    data['rango'] = sp_Rango;
    return data;
  }
}