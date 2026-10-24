import 'package:flutter/material.dart';
import 'package:ecommer_app/pages/login.dart';

/// Mensaje que se muestra en secciones que requieren haber iniciado sesión
class LoginRequired extends StatelessWidget {
  final IconData icon;
  final String mensaje;

  const LoginRequired({super.key, required this.icon, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white38, size: 56),
            const SizedBox(height: 16),
            const Text(
              'No has iniciado sesión',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC88D51),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('INICIAR SESIÓN', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
