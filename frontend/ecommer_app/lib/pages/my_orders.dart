import 'package:flutter/material.dart';
import 'package:ecommer_app/models/pedido.dart';
import 'package:ecommer_app/services/order_service.dart';
import 'package:ecommer_app/widgets/order_card.dart';

/// Historial de compras del usuario logueado
class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _pedidosFuture = OrderService.misPedidos();
    });
  }

  Future<void> _cancelar(Pedido pedido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF26221F),
        title: const Text('Cancelar pedido', style: TextStyle(color: Colors.white)),
        content: Text('¿Cancelar el pedido #${pedido.codigo}?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await OrderService.cancelarPedido(pedido.id);
      _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181513),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181513),
        foregroundColor: Colors.white,
        title: const Text('Mis pedidos'),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFC88D51),
        backgroundColor: const Color(0xFF1F1B18),
        onRefresh: _cargar,
        child: FutureBuilder<List<Pedido>>(
          future: _pedidosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFC88D51)));
            }
            final pedidos = snapshot.data ?? [];
            if (snapshot.hasError || pedidos.isEmpty) {
              // ListView para que el "deslizar para refrescar" funcione también aquí
              return ListView(
                children: [
                  const SizedBox(height: 160),
                  Icon(
                    snapshot.hasError ? Icons.error_outline : Icons.receipt_long_outlined,
                    color: Colors.white24,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.hasError
                        ? '${snapshot.error}'.replaceAll('Exception: ', '')
                        : 'Aún no has realizado compras.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: pedidos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final pedido = pedidos[i];
                return OrderCard(
                  pedido: pedido,
                  accion: pedido.estado == 'pendiente'
                      ? TextButton(
                          onPressed: () => _cancelar(pedido),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
                        )
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
