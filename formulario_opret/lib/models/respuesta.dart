// class Respuesta {
//   // int idRespuesta;
//   String idUsuarios;
//   String? noEncuesta;
//   int? idSesion;
//   String? respuestas;
//   String? comentarios;
//   String? justificacion;
//
//   Respuesta({
//     // required this.idRespuesta,
//     required this.idUsuarios,
//     this.noEncuesta,
//     required this.idSesion,
//     this.respuestas,
//     this.comentarios,
//     this.justificacion,
//   });
//
//   factory Respuesta.fromJson(Map<String, dynamic> json) {
//     return Respuesta(
//       // idRespuesta: json['idRespuesta'],
//       idUsuarios: json['idUsuarios'],
//       noEncuesta: json['noEncuesta'],
//       idSesion: json['idSesion'],
//       respuestas: json['respuesta1'],
//       comentarios: json['comentarios'],
//       justificacion: json['justificacion']
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     // data['idRespuesta'] = idRespuesta;
//     data['idUsuarios'] = idUsuarios;
//     data['noEncuesta'] = noEncuesta;
//     data['idSesion'] = idSesion;
//     data['respuesta1'] = respuestas;
//     data['comentarios'] = comentarios;
//     data['justificacion'] = justificacion;
//     return data;
//   }
// }
// // hay que determinar la relacion foreign key ya que
// //no deja mostrar los datos de la tabla respuesta