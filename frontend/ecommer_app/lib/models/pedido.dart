class ItemPedido {
  final String productoId;
  final String nombre;
  final double precio;
  final String imagen;
  final int cantidad;

  ItemPedido({
    required this.productoId,
    required this.nombre,
    required this.precio,
    required this.imagen,
    required this.cantidad,
  });

  double get subtotal => precio * cantidad;

  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      productoId: (json['producto'] ?? '').toString(),
      nombre: (json['Nombre'] ?? '').toString(),
      precio: double.tryParse(json['Precio'].toString()) ?? 0.0,
      imagen: (json['Image'] ?? '').toString(),
      cantidad: int.tryParse(json['cantidad'].toString()) ?? 1,
    );
  }
}

class Pedido {
  final String id;
  final List<ItemPedido> items;
  final double total;
  final String direccion;
  final String ciudad;
  final String telefono;
  final String notas;
  final String metodoPago;
  final String estado;
  final DateTime fecha;

  // Datos del cliente: solo vienen cuando el admin lista los pedidos
  final String clienteNombre;
  final String clienteCorreo;

  Pedido({
    required this.id,
    required this.items,
    required this.total,
    required this.direccion,
    required this.ciudad,
    required this.telefono,
    required this.notas,
    required this.metodoPago,
    required this.estado,
    required this.fecha,
    this.clienteNombre = '',
    this.clienteCorreo = '',
  });

  /// Código corto que se muestra al usuario y en los correos
  String get codigo => id.length >= 6 ? id.substring(id.length - 6).toUpperCase() : id.toUpperCase();

  String get metodoPagoTexto => metodoPago == 'transferencia' ? 'Transferencia' : 'Contra entrega';

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'];
    final cliente = usuario is Map<String, dynamic> ? usuario : const <String, dynamic>{};

    return Pedido(
      id: (json['_id'] ?? '').toString(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => ItemPedido.fromJson(i as Map<String, dynamic>))
          .toList(),
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      direccion: (json['direccion'] ?? '').toString(),
      ciudad: (json['ciudad'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      notas: (json['notas'] ?? '').toString(),
      metodoPago: (json['metodoPago'] ?? 'contraentrega').toString(),
      estado: (json['estado'] ?? 'pendiente').toString(),
      fecha: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      clienteNombre: '${cliente['Nombre'] ?? ''} ${cliente['Apellido'] ?? ''}'.trim(),
      clienteCorreo: (cliente['Correo_Electronico'] ?? '').toString(),
    );
  }
}
