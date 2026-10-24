import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ecommer_app/widgets/top_bar.dart';
import 'package:ecommer_app/widgets/search_bar_with_filter.dart';
import 'package:ecommer_app/widgets/category_selector.dart';
import 'package:ecommer_app/widgets/product_card.dart';
import 'package:ecommer_app/models/product.dart';
import 'package:ecommer_app/models/usuario.dart';
import 'package:ecommer_app/services/product_service.dart';
import 'package:ecommer_app/services/sesion_service.dart';
import 'package:ecommer_app/services/cart_service.dart';
import 'package:ecommer_app/services/favorites_service.dart';
import 'package:ecommer_app/services/notification_service.dart';
import 'package:ecommer_app/pages/admin/admin_product_list_page.dart';
import 'package:ecommer_app/pages/profile.dart';
import 'package:ecommer_app/pages/login.dart';
import 'package:ecommer_app/pages/favorites.dart';
import 'package:ecommer_app/pages/cart.dart';
import 'package:ecommer_app/pages/notifications.dart';
import 'package:ecommer_app/widgets/chat_bottom_sheet.dart';

// Opciones de orden del botón de filtro
enum _Orden { relevancia, precioMenor, precioMayor, nombre }

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;
  late Future<List<Product>> _productsFuture;
  Usuario? _usuario;

  // Búsqueda y filtros del catálogo
  final _searchCtrl = TextEditingController();
  String _busqueda = '';
  String _categoria = 'Todos';
  _Orden _orden = _Orden.relevancia;

  // Revisa periódicamente si llegaron notificaciones nuevas
  Timer? _timerNotificaciones;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _cargarUsuario();
    _timerNotificaciones = Timer.periodic(
      const Duration(seconds: 30),
      (_) => NotificationService.instance.refrescar(),
    );
  }

  @override
  void dispose() {
    _timerNotificaciones?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  // Carga el usuario logueado (si hay sesión activa) para saber si es admin,
  // y sincroniza sus favoritos y notificaciones
  Future<void> _cargarUsuario() async {
    final usuario = await SessionService.obtenerUsuario();
    if (mounted) setState(() => _usuario = usuario);

    if (usuario != null) {
      FavoritesService.instance.obtenerFavoritos().catchError((_) => <Product>[]);
      NotificationService.instance.refrescar();
    } else {
      FavoritesService.instance.limpiar();
      NotificationService.instance.limpiar();
    }
  }

  // Método para volver a ejecutar la petición a MongoDB
  Future<void> _cargarProductos() async {
    setState(() {
      _productsFuture = ProductService.getProductos();
    });
  }

  // Maneja los toques del menú inferior.
  // Pestaña "Perfil": abre el perfil si hay sesión, si no lleva al login.
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

  Future<void> _abrirNotificaciones() async {
    if (_usuario == null) return _onNavTap(3);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsPage(esAdmin: _usuario!.rol == 'admin'),
      ),
    );
    NotificationService.instance.refrescar();
  }

  void _mostrarMensaje(String texto, {SnackBarAction? accion}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(texto),
        action: accion,
        duration: const Duration(seconds: 2),
      ));
  }

  void _agregarAlCarrito(Product product) {
    CartService.instance.agregar(product);
    _mostrarMensaje(
      '${product.title} agregado al carrito',
      accion: SnackBarAction(
        label: 'VER',
        textColor: const Color(0xFFC88D51),
        onPressed: () => setState(() => _selectedIndex = 2),
      ),
    );
  }

  Future<void> _alternarFavorito(Product product) async {
    if (_usuario == null) {
      _mostrarMensaje(
        'Inicia sesión para guardar favoritos',
        accion: SnackBarAction(
          label: 'INICIAR',
          textColor: const Color(0xFFC88D51),
          onPressed: () => _onNavTap(3),
        ),
      );
      return;
    }
    try {
      final esFavorito = await FavoritesService.instance.alternar(product.id);
      _mostrarMensaje(esFavorito ? 'Agregado a favoritos' : 'Eliminado de favoritos');
    } catch (e) {
      _mostrarMensaje('$e'.replaceAll('Exception: ', ''));
    }
  }

  // Aplica búsqueda, categoría y orden sobre los productos de la BD
  List<Product> _filtrar(List<Product> productos) {
    final busqueda = _busqueda.trim().toLowerCase();
    final categoria = _categoria.toLowerCase();

    final resultado = productos.where((p) {
      final texto = '${p.title} ${p.description}'.toLowerCase();
      final coincideBusqueda = busqueda.isEmpty || texto.contains(busqueda);
      final coincideCategoria = _categoria == 'Todos' || texto.contains(categoria);
      return coincideBusqueda && coincideCategoria;
    }).toList();

    switch (_orden) {
      case _Orden.precioMenor:
        resultado.sort((a, b) => a.price.compareTo(b.price));
      case _Orden.precioMayor:
        resultado.sort((a, b) => b.price.compareTo(a.price));
      case _Orden.nombre:
        resultado.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case _Orden.relevancia:
        break;
    }
    return resultado;
  }

  void _abrirFiltros() {
    const opciones = {
      _Orden.relevancia: 'Relevancia',
      _Orden.precioMenor: 'Precio: menor a mayor',
      _Orden.precioMayor: 'Precio: mayor a menor',
      _Orden.nombre: 'Nombre (A - Z)',
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF26221F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Ordenar por',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            for (final opcion in opciones.entries)
              ListTile(
                title: Text(opcion.value, style: const TextStyle(color: Colors.white)),
                trailing: _orden == opcion.key
                    ? const Icon(Icons.check_rounded, color: Color(0xFFC88D51))
                    : null,
                onTap: () {
                  setState(() => _orden = opcion.key);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
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
        child: switch (_selectedIndex) {
          1 => FavoritesView(haySesion: _usuario != null),
          2 => CartView(onSeguirComprando: () => setState(() => _selectedIndex = 0)),
          _ => _buildCatalogo(),
        },
      ),

      // BOTONES FLOTANTES: Chat del Barista + Admin (si aplica), solo en Inicio
      floatingActionButton: _selectedIndex != 0
          ? null
          : Row(
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
                      NotificationService.instance.refrescar();
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

      // El ícono del carrito muestra cuántos productos lleva
      bottomNavigationBar: ListenableBuilder(
        listenable: CartService.instance,
        builder: (context, _) {
          final enCarrito = CartService.instance.cantidadTotal;
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavTap,
            backgroundColor: const Color(0xFF1F1B18),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFFC88D51),
            unselectedItemColor: Colors.white.withValues(alpha: 0.35),
            showUnselectedLabels: false,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
              const BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Favoritos'),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: enCarrito > 0,
                  label: Text('$enCarrito'),
                  backgroundColor: const Color(0xFFC88D51),
                  child: const Icon(Icons.shopping_bag_rounded),
                ),
                label: 'Carrito',
              ),
              const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCatalogo() {
    // Permite deslizar hacia abajo para refrescar los datos de la BD
    return RefreshIndicator(
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
                children: [
                  TopBar(
                    onProfileTap: () => _onNavTap(3),
                    onNotificationsTap: _abrirNotificaciones,
                  ),
                  const SizedBox(height: 24),
                  SearchBarWithFilter(
                    controller: _searchCtrl,
                    onChanged: (texto) => setState(() => _busqueda = texto),
                    onFilterTap: _abrirFiltros,
                  ),
                  const SizedBox(height: 24),
                  CategorySelector(
                    onCategorySelected: (categoria) => setState(() => _categoria = categoria),
                  ),
                  const SizedBox(height: 12),
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
              final products = _filtrar(snapshot.data!);

              // Estado 5: Ningún producto coincide con la búsqueda / filtro
              if (products.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded, color: Colors.white24, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _busqueda.isEmpty
                              ? 'No hay productos en "$_categoria"'
                              : 'No encontramos resultados para "$_busqueda"',
                          style: const TextStyle(color: Color(0xFFF5E6D3)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                // Se redibuja cuando cambian los favoritos para actualizar los corazones
                sliver: ListenableBuilder(
                  listenable: FavoritesService.instance,
                  builder: (context, _) => SliverGrid(
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
                          isFavorite: FavoritesService.instance.esFavorito(product.id),
                          onFavoriteTap: () => _alternarFavorito(product),
                          onAddTap: () => _agregarAlCarrito(product),
                        );
                      },
                      childCount: products.length,
                    ),
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
    );
  }
}
