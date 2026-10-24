class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final String? pedidoId;
  final bool leida;
  final DateTime fecha;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.pedidoId,
    required this.leida,
    required this.fecha,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: (json['_id'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      pedidoId: json['pedido']?.toString(),
      leida: json['leida'] == true,
      fecha: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
