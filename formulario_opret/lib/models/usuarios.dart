class Usuarios {
  String idUsuarios;
  String cedula;
  String nombreApellido;
  String usuario1;
  String email;
  String passwords;
  String fechaCreacion;
  String rol;

  Usuarios({
    required this.idUsuarios,
    required this.cedula,
    required this.nombreApellido,
    required this.usuario1,
    required this.email,
    required this.passwords,
    required this.fechaCreacion,
    required this.rol,
  });

  // Constructor para crear una instancia desde JSON
  factory Usuarios.fromJson(Map<String, dynamic> json) {
    return Usuarios(
      idUsuarios: json['idUsuarios'], 
      cedula: json['cedula'], 
      nombreApellido: json['nombreApellido'], 
      usuario1: json['usuario'], 
      email: json['email'], 
      passwords: json['passwords'],
      fechaCreacion: json['fechaCreacion'],
      rol: json['rol']
    );
  }

  // Método para convertir una instancia a JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idUsuarios'] = idUsuarios;
    data['cedula'] = cedula;
    data['nombreApellido'] = nombreApellido;
    data['usuario'] = usuario1;
    data['email'] = email;
    data['passwords'] = passwords;
    data['fechaCreacion'] = fechaCreacion;
    data['rol'] = rol;
    return data;
  }
}

/*
class ObtenerEmpleados {
  String idUsuarios$;
  String cedula$;
  String nombreApellido$;
  String usuario$;
  String email$;
  String fechaCreacion$;
  String rol$;

  ObtenerEmpleados({
    required this.idUsuarios$,
    required this.cedula$,
    required this.nombreApellido$,
    required this.usuario$,
    required this.email$,
    required this.fechaCreacion$,
    required this.rol$,
  });

  factory ObtenerEmpleados.fromJson(Map<String, dynamic> json) {
    return ObtenerEmpleados(
      idUsuarios$: json['idUsuarios'],
      cedula$: json['cedula'],
      nombreApellido$: json['nombreApellido'],
      usuario$: json['usuario'],
      email$: json['email'],
      fechaCreacion$: json['fechaCreacion'],
      rol$: json['rol'],
    );
  }
}
*/