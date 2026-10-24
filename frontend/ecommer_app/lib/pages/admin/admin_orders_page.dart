import 'package:flutter/material.dart';
import 'package:ecommer_app/models/pedido.dart';
import 'package:ecommer_app/services/order_service.dart';
import 'package:ecommer_app/widgets/order_card.dart';
import 'package:ecommer_app/widgets/order_status_chip.dart';

/// Panel admin: lista de pedidos (por defecto los pendientes) y cambio de estado
class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  // null = todos los estados
  String? _filtro = 'pendiente';
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _pedidosFuture = OrderService.listarPedidos(estado: _filtro);
    });
  }

  Future<void> _cambiarEstado(Pedido pedido, String estado) async {
    try {
      await OrderService.cambiarEstado(pedido.id, estado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido #${pedido.codigo}: ${etiquetaEstado(estado)}. Se notificó al cliente.')),
      );
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
        title: const Text('Pedidos'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _chipFiltro(null, 'Todos'),
                for (final estado in estadosPedido) _chipFiltro(estado, etiquetaEstado(estado)),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
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
                    return ListView(
                      children: [
                        const SizedBox(height: 140),
                        const Icon(Icons.inbox_outlined, color: Colors.white24, size: 56),
                        const SizedBox(height: 12),
                        Text(
                          snapshot.hasError
                              ? '${snapshot.error}'.replaceAll('Exception: ', '')
                              : 'No hay pedidos ${_filtro == null ? '' : etiquetaEstado(_filtro!).toLowerCase()}.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: pedidos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final pedido = pedidos[i];
                      return OrderCard(
                        pedido: pedido,
                        mostrarCliente: true,
                        accion: _menuEstado(pedido),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipFiltro(String? estado, String texto) {
    final seleccionado = _filtro == estado;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: seleccionado,
        showCheckmark: false,
        selectedColor: const Color(0xFFC88D51),
        backgroundColor: const Color(0xFF26221F),
        labelStyle: TextStyle(color: seleccionado ? Colors.white : Colors.white70),
        side: BorderSide.none,
        onSelected: (_) {
          _filtro = estado;
          _cargar();
        },
      ),
    );
  }

  Widget _menuEstado(Pedido pedido) {
    return PopupMenuButton<String>(
      color: const Color(0xFF26221F),
      tooltip: 'Cambiar estado',
      onSelected: (estado) => _cambiarEstado(pedido, estado),
      itemBuilder: (_) => [
        for (final estado in estadosPedido)
          PopupMenuItem(
            value: estado,
            enabled: estado != pedido.estado,
            child: Row(
              children: [
                Icon(Icons.circle, size: 10, color: colorEstado(estado)),
                const SizedBox(width: 10),
                Text(etiquetaEstado(estado), style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFC88D51)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync_alt_rounded, color: Color(0xFFC88D51), size: 16),
            SizedBox(width: 6),
            Text('Cambiar estado', style: TextStyle(color: Color(0xFFC88D51), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
