import 'package:flutter/material.dart';
import 'package:ecommer_app/services/cart_service.dart';
import 'package:ecommer_app/services/sesion_service.dart';
import 'package:ecommer_app/pages/checkout.dart';
import 'package:ecommer_app/pages/login.dart';
import 'package:ecommer_app/utils/formato.dart';
import 'package:ecommer_app/widgets/product_thumbnail.dart';

/// Pestaña "Carrito" del menú inferior
class CartView extends StatelessWidget {
  final VoidCallback onSeguirComprando;

  const CartView({super.key, required this.onSeguirComprando});

  Future<void> _irACheckout(BuildContext context) async {
    final haySesion = await SessionService.haySesionActiva();
    if (!context.mounted) return;

    if (!haySesion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para finalizar tu compra. Tu carrito se conserva.')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage()));
  }

  Future<void> _confirmarVaciar(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF26221F),
        title: const Text('Vaciar carrito', style: TextStyle(color: Colors.white)),
        content: const Text('¿Quitar todos los productos del carrito?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Vaciar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmar == true) CartService.instance.vaciar();
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;

    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        if (cart.items.isEmpty) return _buildVacio();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Mi carrito',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmarVaciar(context),
                    icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white54, size: 20),
                    label: const Text('Vaciar', style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: cart.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildItem(cart.items[index]),
              ),
            ),
            _buildResumen(context, cart),
          ],
        );
      },
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega cafés desde el menú con el botón +',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onSeguirComprando,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC88D51),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('VER PRODUCTOS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(CartItem item) {
    final cart = CartService.instance;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF26221F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ProductThumbnail(imageUrl: item.product.imageUrl, size: 72),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  formatoPrecio(item.product.price),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _botonCantidad(Icons.remove_rounded, () => cart.cambiarCantidad(item.product.id, item.cantidad - 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.cantidad}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    _botonCantidad(Icons.add_rounded, () => cart.cambiarCantidad(item.product.id, item.cantidad + 1)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 20),
                onPressed: () => cart.eliminar(item.product.id),
              ),
              Text(
                formatoPrecio(item.subtotal),
                style: const TextStyle(color: Color(0xFFF5E6D3), fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonCantidad(IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xFF181513),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: const Color(0xFFC88D51), size: 18),
        ),
      ),
    );
  }

  Widget _buildResumen(BuildContext context, CartService cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1F1B18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${cart.cantidadTotal} ${cart.cantidadTotal == 1 ? 'producto' : 'productos'}',
                style: const TextStyle(color: Colors.white54),
              ),
              Text(
                formatoPrecio(cart.total),
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _irACheckout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC88D51),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'FINALIZAR COMPRA',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
