import 'package:flutter/material.dart';
import 'package:ecommer_app/widgets/top_bar.dart'; 
import 'package:ecommer_app/widgets/search_bar_with_filter.dart'; 
import 'package:ecommer_app/widgets/category_selector.dart';
import 'package:ecommer_app/widgets/product_card.dart';
import 'package:ecommer_app/models/product.dart';
import 'package:ecommer_app/models/usuario.dart';
import 'package:ecommer_app/services/product_service.dart';
import 'package:ecommer_app/services/sesion_service.dart';
import 'package:ecommer_app/pages/admin/admin_product_list_page.dart';
import 'package:ecommer_app/pages/profile.dart';
import 'package:ecommer_app/pages/login.dart';
import 'package:ecommer_app/widgets/chat_bottom_sheet.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;
  late Future<List<Product>> _productsFuture;
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _cargarUsuario();
  }

  // Carga el usuario logueado (si hay sesión activa) para saber si es admin
  Future<void> _cargarUsuario() async {
    final usuario = await SessionService.obtenerUsuario();
    if (mounted) setState(() => _usuario = usuario);
  }

  // Método para volver a ejecutar la petición a MongoDB
  Future<void> _cargarProductos() async {
    setState(() {
      _productsFuture = ProductService.getProductos();
    });
  }

  // Maneja los toques del menú inferior.
  // Pestaña "Perfil": abre el perfil si hay sesión, si no lleva al login.
  // Las demás pestañas solo cambian el índice seleccionado por ahora.
  Future<void> _onNavTap(int index) async {
    if (index == 3) {
      final Widget destino =
          _usuario != null ? const ProfilePage() : const LoginPage();
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destino),
      );
      // Al volver, refrescamos por si el usuario inició o cerró sesión.
      _cargarUsuario();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  // Abre el modal inferior con el Barista Virtual
  void _abrirChatBarista() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181513),
      body: SafeArea(
        // Permite deslizar hacia abajo para refrescar los datos de la BD
        child: RefreshIndicator(
          color: const Color(0xFFC88D51),
          backgroundColor: const Color(0xFF1F1B18),
          onRefresh: _cargarProductos,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. ENCABEZADOS Y BÚSQUEDA
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      TopBar(),
                      SizedBox(height: 24),
                      SearchBarWithFilter(),
                      SizedBox(height: 24),
                      CategorySelector(),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // 2. GRILLA CONECTADA A LA BASE DE DATOS
              FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  // Estado 1: Cargando datos desde la Base de Datos
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC88D51),
                          ),
                        ),
                      ),
                    );
                  }

                  // Estado 2: Ocurrió un error al consultar la BD
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text(
                            'Error al obtener productos de la BD:\n${snapshot.error}',
                            style: const TextStyle(color: Color(0xFFF5E6D3)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }

                  // Estado 3: La BD no devolvió productos
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text(
                            'No hay productos registrados en la base de datos',
                            style: TextStyle(color: Color(0xFFF5E6D3)),
                          ),
                        ),
                      ),
                    );
                  }

                  // Estado 4: Productos cargados con éxito de la BD
                  final products = snapshot.data!;

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
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              // Navegar al detalle del producto
                            },
                            onAddTap: () {
                              // Agregar al carrito
                            },
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),

      // BOTONES FLOTANTES: Chat del Barista + Admin (si aplica)
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_usuario?.rol == 'admin') ...[
            FloatingActionButton.extended(
              heroTag: 'fab_btn_admin',
              backgroundColor: const Color(0xFFC88D51),
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.black),
              label: const Text(
                'Administrar',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminProductListPage()),
                );
                _cargarProductos();
              },
            ),
            const SizedBox(width: 12),
          ],

          // Botón cafetero siempre visible
          FloatingActionButton(
            heroTag: 'fab_btn_barista_chat',
            backgroundColor: const Color(0xFFC88D51),
            elevation: 4,
            shape: const CircleBorder(),
            tooltip: 'Consultar al Barista Virtual',
            onPressed: _abrirChatBarista,
            child: const Icon(
              Icons.coffee_rounded,
              color: Colors.black,
              size: 28,
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        backgroundColor: const Color(0xFF1F1B18),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFC88D51),
        unselectedItemColor: Colors.white.withValues(alpha: 0.35),
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_rounded), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}