import 'package:flutter/material.dart';
import 'package:ecommer_app/models/notificacion.dart';
import 'package:ecommer_app/services/notification_service.dart';
import 'package:ecommer_app/pages/my_orders.dart';
import 'package:ecommer_app/pages/admin/admin_orders_page.dart';
import 'package:ecommer_app/utils/formato.dart';

class NotificationsPage extends StatefulWidget {
  final bool esAdmin;

  const NotificationsPage({super.key, required this.esAdmin});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _service = NotificationService.instance;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      await _service.cargar();
      _error = null;
    } catch (e) {
      _error = '$e'.replaceAll('Exception: ', '');
    }
    if (mounted) setState(() => _cargando = false);
  }

  // Al tocar una notificación de pedido se abre la lista de pedidos correspondiente
  Future<void> _abrir(Notificacion notificacion) async {
    if (!notificacion.leida) _service.marcarLeida(notificacion.id);
    if (notificacion.pedidoId == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => widget.esAdmin ? const AdminOrdersPage() : const MyOrdersPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181513),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181513),
        foregroundColor: Colors.white,
        title: const Text('Notificaciones'),
        actions: [
          ListenableBuilder(
            listenable: _service,
            builder: (context, _) => _service.noLeidas == 0
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: _service.marcarTodasLeidas,
                    child: const Text('Marcar leídas', style: TextStyle(color: Color(0xFFC88D51))),
                  ),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC88D51)))
          : RefreshIndicator(
              color: const Color(0xFFC88D51),
              backgroundColor: const Color(0xFF1F1B18),
              onRefresh: _cargar,
              child: ListenableBuilder(
                listenable: _service,
                builder: (context, _) {
                  final notificaciones = _service.notificaciones;
                  if (_error != null || notificaciones.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 160),
                        const Icon(Icons.notifications_off_outlined, color: Colors.white24, size: 56),
                        const SizedBox(height: 12),
                        Text(
                          _error ?? 'No tienes notificaciones.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notificaciones.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _buildNotificacion(notificaciones[i]),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildNotificacion(Notificacion n) {
    return Material(
      color: n.leida ? const Color(0xFF1F1B18) : const Color(0xFF2E2620),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrir(n),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFC88D51).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFC88D51), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.titulo,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: n.leida ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(n.mensaje, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(formatoFecha(n.fecha), style: const TextStyle(color: Colors.white30, fontSize: 11)),
                  ],
                ),
              ),
              if (!n.leida)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(color: Color(0xFFC88D51), shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
