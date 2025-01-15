class Sesion {
  int? idSesion;
  String tipoRespuesta;
  String? identifEncuesta;
  int codPregunta;
  String? codSubPregunta;
  bool estado;
  String? rango;
  Preguntas? preguntas_;
  SubPregunta? subPregunta_;

  Sesion({
    this.idSesion,
    required this.tipoRespuesta,
    this.identifEncuesta,
    required this.codPregunta,
    this.codSubPregunta,
    this.rango,
    required this.estado,
    this.preguntas_,
    this.subPregunta_
  });

  factory Sesion.fromJson(Map<String, dynamic> json) {
    return Sesion(
      idSesion: json['idSesion'],
      tipoRespuesta: json['tipoRespuesta'],
        identifEncuesta: json['grupoTema'],
      codPregunta: json['codPregunta'],
      codSubPregunta: json['codSubPregunta'],
      rango: json['rango'],
      estado: json['estado'],
      preguntas_: json['preguntas_'] != null
          ? Preguntas.fromJson(json['preguntas_']) : null,
      subPregunta_: json['subPregunta_']  != null
          ? SubPregunta.fromJson(json['subPregunta_']) : null
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (idSesion != null) { data['idSesion'] = idSesion; }
    data['tipoRespuesta'] = tipoRespuesta;
    data['grupoTema'] = identifEncuesta;
    data['codPregunta'] = codPregunta;
    data['codSubPregunta'] = codSubPregunta;
    data['rango'] = rango;
    data['estado'] = estado;
    if(preguntas_ != null) {data['preguntas_'] = preguntas_!.toJson();}
    if(subPregunta_ != null) {data['subPregunta_'] = subPregunta_!.toJson();}
    print(data);
    return data;
  }
}

//                                                    Preguntas

class Preguntas {
  int codPregunta;
  String pregunta;

  Preguntas({
    required this.codPregunta,
    required this.pregunta
  });

  factory Preguntas.fromJson(Map<String, dynamic> json) {
    return Preguntas(
      codPregunta: json['codPregunta'],
      pregunta: json['pregunta1'],
    );
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['codPregunta'] = codPregunta;
    data['pregunta1'] = pregunta;
    return data;
  }
}

//                                                    class SubPregunta 

class SubPregunta {
  String codSubPregunta;
  String? subPreguntas;

  SubPregunta({
    required this.codSubPregunta,
    this.subPreguntas
  });

  factory SubPregunta.fromJson(Map<String, dynamic> json) {
    return SubPregunta(
      codSubPregunta: json['codSubPregunta'],
      subPreguntas: json['subPreguntas']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['codSubPregunta'] = codSubPregunta;
    data['subPreguntas'] = subPreguntas;
    return data;
  }
}