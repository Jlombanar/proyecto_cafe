import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommer_app/pages/login.dart';
import 'package:ecommer_app/pages/admin/admin_product_list_page.dart';

class AdminDrawer extends StatelessWidget {
  final String adminName;
  final String adminEmail;

  const AdminDrawer({
    super.key,
    required this.adminName,
    required this.adminEmail,
  });

  Future<void> _cerrarSesion(BuildContext context) async {
    // 1. Limpiar datos de sesión guardados en el dispositivo
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    // 2. Redirigir al usuario a la página de inicio de sesión y eliminar el historial de navegación
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF181513),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: const BoxDecoration(
                    color: Color(0xFF26221F),
                  ),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Color(0xFFC88D51),
                    child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 36),
                  ),
                  accountName: Text(
                    adminName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  accountEmail: Text(
                    adminEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Opción Productos
                _drawerItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Productos',
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminProductListPage(),
                      ),
                    );
                  },
                ),
                // Opción Usuarios
                _drawerItem(
                  icon: Icons.people_alt_outlined,
                  title: 'Usuarios',
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                    // Navigator.pushNamed(context, '/admin/usuarios');
                  },
                ),
                // Opción Pedidos
                _drawerItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Pedidos',
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                    // Navigator.pushNamed(context, '/admin/pedidos');
                  },
                ),
              ],
            ),
          ),
          
          // Separador visual
          const Divider(color: Colors.white12, height: 1),
          
          // Botón Cerrar Sesión en la parte inferior
          _drawerItem(
            icon: Icons.logout_rounded,
            title: 'Cerrar Sesión',
            color: Colors.redAccent,
            onTap: () => _cerrarSesion(context),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFFC88D51)),
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}