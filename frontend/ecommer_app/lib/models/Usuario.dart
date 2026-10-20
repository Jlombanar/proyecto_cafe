class Usuario {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String rol;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['_id'] ?? '',
      nombre: json['Nombre'] ?? '',
      apellido: json['Apellido'] ?? '',
      correo: json['Correo_Electronico'] ?? '',
      telefono: json['telefono'] ?? '',
      rol: json['rol'] ?? 'APRENDIZ',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Nombre': nombre,
      'Apellido': apellido,
      'Correo_Electronico': correo,
      'telefono': telefono,
      'rol': rol,
    };
  }

  String get nombreCompleto => '$nombre $apellido';
}
