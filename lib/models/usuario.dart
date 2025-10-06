class Usuario {
  String? id;
  String email;
  String nombre;
  String password;

  Usuario({
    this.id,
    required this.email,
    required this.nombre,
    required this.password,
  });

  factory Usuario.fromMap(Map<String, dynamic> data, String id) {
    return Usuario(
      id: id,
      email: data['email'] ?? '',
      nombre: data['nombre'] ?? '',
      password: data['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'password': password,
    };
  }
}
