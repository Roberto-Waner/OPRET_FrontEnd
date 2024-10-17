class EstacionPorLinea {
  int idEstacion;
  String nombreLinea;
  String nombreEstacion;

  EstacionPorLinea({required this.idEstacion, required this.nombreLinea, required this.nombreEstacion});

  factory EstacionPorLinea.fromJson(Map<String, dynamic> json) {
    return EstacionPorLinea(
      idEstacion: json['idEstacion'],
      nombreLinea: json['nombreLinea'],
      nombreEstacion: json['nombreEstacion'],
    );
  }
}