import 'package:flutter/material.dart';
import 'package:ecommer_app/models/product.dart';
import 'package:ecommer_app/services/product_service.dart';
import 'package:ecommer_app/services/admin_product_service.dart';
import 'package:ecommer_app/services/sesion_service.dart';
import 'package:ecommer_app/services/api_config.dart';
import 'package:ecommer_app/widgets/admin_drawer.dart';
import 'package:ecommer_app/widgets/product_form_sheet.dart';
import 'package:ecommer_app/pages/admin/admin_orders_page.dart';

// Protegido contra valores null o vacíos
String _resolverUrl(String? url) {
  if (url == null || url.trim().isEmpty) return '';
  return url.startsWith('http') ? url : '${ApiConfig.baseUrl.replaceFirst('/api', '')}$url';
}

class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  late Future<List<Product>> _productosFuture;
  
  String _adminNombre = 'Cargando...';
  String _adminEmail = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _cargarDatosAdmin();
  }

  void _cargarProductos() {
    setState(() {
      _productosFuture = ProductService.getProductos();
    });
  }

  // Lee los datos reales del usuario logueado (guardados por SessionService en el login)
  Future<void> _cargarDatosAdmin() async {
    try {
      final usuario = await SessionService.obtenerUsuario();
      if (mounted) {
        setState(() {
          _adminNombre = usuario?.nombreCompleto ?? 'Administrador';
          _adminEmail = usuario?.correo ?? 'admin@correo.com';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _adminNombre = 'Administrador';
          _adminEmail = 'admin@correo.com';
        });
      }
    }
  }

  Future<void> _abrirFormulario({Product? producto}) async {
    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(
        producto: producto, 
        resolverUrl: (url) => _resolverUrl(url),
      ),
    );
    if (guardado == true) _cargarProductos();
  }

  Future<void> _eliminar(Product producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF26221F),
        title: const Text('Eliminar producto', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "${producto.title}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await AdminProductService.eliminarProducto(producto.id);
        _cargarProductos();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Widget _buildProductImage(String? rawUrl) {
    final url = _resolverUrl(rawUrl);
    if (url.isEmpty) {
      return const Icon(Icons.image_not_supported, color: Colors.white38, size: 30);
    }
    return Image.network(
      url,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white38, size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181513),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181513),
        foregroundColor: Colors.white,
        title: const Text('Panel de Administración'),
        actions: [
          IconButton(
            tooltip: 'Pedidos',
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminOrdersPage()),
            ),
          ),
        ],
      ),
      drawer: AdminDrawer(
        adminName: _adminNombre,
        adminEmail: _adminEmail,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC88D51),
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFC88D51),
        backgroundColor: const Color(0xFF1F1B18),
        onRefresh: () async => _cargarProductos(),
        child: FutureBuilder<List<Product>>(
          future: _productosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFC88D51)));
            }
            final productos = snapshot.data ?? [];
            if (snapshot.hasError || productos.isEmpty) {
              return Center(
                child: Text(
                  snapshot.hasError ? 'Error: ${snapshot.error}' : 'No hay productos registrados.',
                  style: const TextStyle(color: Colors.white54),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: productos.length,
              itemBuilder: (_, i) {
                final p = productos[i];
                return Card(
                  color: const Color(0xFF26221F),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: _buildProductImage(p.imageUrl),
                      ),
                    ),
                    title: Text(p.title.isEmpty ? 'Sin título' : p.title, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('\$${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white60)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.white70), onPressed: () => _abrirFormulario(producto: p)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _eliminar(p)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}