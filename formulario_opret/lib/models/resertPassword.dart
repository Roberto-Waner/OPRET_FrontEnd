class Resertpassword {
  String? token; // Token de verificación
  String? newPassword; // Nueva contraseña

  Resertpassword({
    this.token,
    this.newPassword,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['newPassword'] = newPassword;
    return data;
  }
}

class Request {
  String? email; // Email del usuario

  Request({this.email});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    return data;
  }
}