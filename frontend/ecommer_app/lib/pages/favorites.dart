import 'package:flutter/material.dart';
import 'package:ecommer_app/models/product.dart';
import 'package:ecommer_app/services/favorites_service.dart';
import 'package:ecommer_app/services/cart_service.dart';
import 'package:ecommer_app/widgets/product_card.dart';
import 'package:ecommer_app/widgets/login_required.dart';

/// Pestaña "Favoritos" del menú inferior
class FavoritesView extends StatefulWidget {
  final bool haySesion;

  const FavoritesView({super.key, required this.haySesion});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  Future<List<Product>>? _favoritosFuture;

  @override
  void initState() {
    super.initState();
    if (widget.haySesion) _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _favoritosFuture = FavoritesService.instance.obtenerFavoritos();
    });
  }

  Future<void> _quitar(Product product) async {
    try {
      await FavoritesService.instance.alternar(product.id);
      _cargar();
    } catch (e) {
      _mostrarMensaje('$e'.replaceAll('Exception: ', ''));
    }
  }

  void _agregarAlCarrito(Product product) {
    CartService.instance.agregar(product);
    _mostrarMensaje('${product.title} agregado al carrito');
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.haySesion) {
      return const LoginRequired(
        icon: Icons.favorite_border_rounded,
        mensaje: 'Inicia sesión para guardar tus cafés favoritos.',
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFC88D51),
      backgroundColor: const Color(0xFF1F1B18),
      onRefresh: _cargar,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Mis favoritos',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          FutureBuilder<List<Product>>(
            future: _favoritosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Color(0xFFC88D51))),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      '${snapshot.error}'.replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                );
              }

              final favoritos = snapshot.data ?? [];
              if (favoritos.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border_rounded, color: Colors.white24, size: 56),
                        SizedBox(height: 12),
                        Text(
                          'Aún no tienes favoritos.\nToca el corazón de un producto para guardarlo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: 0.60,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = favoritos[index];
                      return ProductCard(
                        product: product,
                        isFavorite: true,
                        onFavoriteTap: () => _quitar(product),
                        onAddTap: () => _agregarAlCarrito(product),
                      );
                    },
                    childCount: favoritos.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
