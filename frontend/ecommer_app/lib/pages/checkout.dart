import 'package:flutter/material.dart';
import 'package:ecommer_app/services/cart_service.dart';
import 'package:ecommer_app/services/order_service.dart';
import 'package:ecommer_app/services/sesion_service.dart';
import 'package:ecommer_app/services/notification_service.dart';
import 'package:ecommer_app/pages/my_orders.dart';
import 'package:ecommer_app/utils/formato.dart';

/// Checkout: el usuario confirma sus datos de entrega y realiza la compra
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _direccionCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  String _metodoPago = 'contraentrega';
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _precargarTelefono();
  }

  Future<void> _precargarTelefono() async {
    final usuario = await SessionService.obtenerUsuario();
    if (mounted && usuario != null && _telefonoCtrl.text.isEmpty) {
      _telefonoCtrl.text = usuario.telefono;
    }
  }

  @override
  void dispose() {
    _direccionCtrl.dispose();
    _ciudadCtrl.dispose();
    _telefonoCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmarCompra() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = CartService.instance;
    if (cart.items.isEmpty) return;

    setState(() => _enviando = true);
    try {
      final pedido = await OrderService.crearPedido(
        items: cart.items,
        direccion: _direccionCtrl.text.trim(),
        ciudad: _ciudadCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        notas: _notasCtrl.text.trim(),
        metodoPago: _metodoPago,
      );

      cart.vaciar();
      NotificationService.instance.refrescar();
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF26221F),
          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF6DBE7A), size: 56),
          title: const Text('¡Compra realizada!', style: TextStyle(color: Colors.white)),
          content: Text(
            'Tu pedido #${pedido.codigo} por ${formatoPrecio(pedido.total)} quedó pendiente de confirmación.\n\n'
            'Te enviamos un correo con el detalle y te avisaremos cuando cambie de estado.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('VER MIS PEDIDOS', style: TextStyle(color: Color(0xFFC88D51))),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyOrdersPage()));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF181513),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181513),
        foregroundColor: Colors.white,
        title: const Text('Finalizar compra'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _titulo('Datos de entrega'),
              _campo(_direccionCtrl, 'Dirección', Icons.home_outlined),
              _campo(_ciudadCtrl, 'Ciudad', Icons.location_city_outlined),
              _campo(_telefonoCtrl, 'Teléfono de contacto', Icons.phone_outlined, teclado: TextInputType.phone),
              _campo(_notasCtrl, 'Notas para la entrega (opcional)', Icons.notes_outlined, obligatorio: false, lineas: 2),
              const SizedBox(height: 8),
              _titulo('Método de pago'),
              _opcionPago('contraentrega', 'Contra entrega', 'Pagas en efectivo al recibir', Icons.payments_outlined),
              const SizedBox(height: 10),
              _opcionPago('transferencia', 'Transferencia', 'Te enviaremos los datos por correo', Icons.account_balance_outlined),
              const SizedBox(height: 24),
              _titulo('Resumen del pedido'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF26221F),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    for (final item in cart.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.cantidad} x ${item.product.title}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            Text(formatoPrecio(item.subtotal), style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    const Divider(color: Colors.white12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          formatoPrecio(cart.total),
                          style: const TextStyle(color: Color(0xFFC88D51), fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _enviando ? null : _confirmarCompra,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC88D51),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _enviando
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('CONFIRMAR COMPRA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(texto, style: const TextStyle(color: Color(0xFFF5E6D3), fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _campo(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obligatorio = true,
    int lineas = 1,
    TextInputType teclado = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: lineas,
        keyboardType: teclado,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFC88D51)),
          filled: true,
          fillColor: const Color(0xFF26221F),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
        validator: (v) => obligatorio && (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
      ),
    );
  }

  Widget _opcionPago(String valor, String titulo, String subtitulo, IconData icon) {
    final seleccionado = _metodoPago == valor;
    return Material(
      color: const Color(0xFF26221F),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _metodoPago = valor),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: seleccionado ? const Color(0xFFC88D51) : Colors.transparent, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFC88D51)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(subtitulo, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Icon(
                seleccionado ? Icons.radio_button_checked : Icons.radio_button_off,
                color: seleccionado ? const Color(0xFFC88D51) : Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
