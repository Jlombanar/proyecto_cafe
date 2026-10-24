import 'package:flutter/material.dart';
import 'package:ecommer_app/models/pedido.dart';
import 'package:ecommer_app/utils/formato.dart';
import 'package:ecommer_app/widgets/order_status_chip.dart';
import 'package:ecommer_app/widgets/product_thumbnail.dart';

/// Tarjeta con el detalle de un pedido. La usan "Mis pedidos" y el panel admin.
class OrderCard extends StatelessWidget {
  final Pedido pedido;
  final bool mostrarCliente;
  final Widget? accion;

  const OrderCard({super.key, required this.pedido, this.mostrarCliente = false, this.accion});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF26221F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${pedido.codigo}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(formatoFecha(pedido.fecha), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              OrderStatusChip(estado: pedido.estado),
            ],
          ),
          if (mostrarCliente) ...[
            const SizedBox(height: 12),
            _dato(Icons.person_outline, pedido.clienteNombre.isEmpty ? 'Cliente eliminado' : pedido.clienteNombre),
            if (pedido.clienteCorreo.isNotEmpty) _dato(Icons.mail_outline, pedido.clienteCorreo),
          ],
          const SizedBox(height: 8),
          _dato(Icons.location_on_outlined, '${pedido.direccion}, ${pedido.ciudad}'),
          _dato(Icons.phone_outlined, pedido.telefono),
          _dato(Icons.payments_outlined, pedido.metodoPagoTexto),
          if (pedido.notas.isNotEmpty) _dato(Icons.notes_outlined, pedido.notas),
          const Divider(color: Colors.white12, height: 24),
          for (final item in pedido.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ProductThumbnail(imageUrl: item.imagen, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${item.cantidad} x ${item.nombre}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  Text(formatoPrecio(item.subtotal), style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              ?accion,
              const Spacer(),
              const Text('Total  ', style: TextStyle(color: Colors.white54)),
              Text(
                formatoPrecio(pedido.total),
                style: const TextStyle(color: Color(0xFFC88D51), fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dato(IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }
}
