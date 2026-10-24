import 'package:flutter/material.dart';

/// Estados posibles de un pedido (deben coincidir con el backend)
const List<String> estadosPedido = [
  'pendiente',
  'confirmado',
  'preparando',
  'enviado',
  'entregado',
  'cancelado',
];

String etiquetaEstado(String estado) {
  switch (estado) {
    case 'pendiente':
      return 'Pendiente';
    case 'confirmado':
      return 'Confirmado';
    case 'preparando':
      return 'En preparación';
    case 'enviado':
      return 'Enviado';
    case 'entregado':
      return 'Entregado';
    case 'cancelado':
      return 'Cancelado';
    default:
      return estado;
  }
}

Color colorEstado(String estado) {
  switch (estado) {
    case 'pendiente':
      return const Color(0xFFE0A84F);
    case 'confirmado':
      return const Color(0xFF6FA8DC);
    case 'preparando':
      return const Color(0xFFC88D51);
    case 'enviado':
      return const Color(0xFF9B7FD1);
    case 'entregado':
      return const Color(0xFF6DBE7A);
    case 'cancelado':
      return Colors.redAccent;
    default:
      return Colors.white54;
  }
}

class OrderStatusChip extends StatelessWidget {
  final String estado;

  const OrderStatusChip({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final color = colorEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        etiquetaEstado(estado),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
