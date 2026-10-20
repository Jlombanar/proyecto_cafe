import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

/// Guarda el token JWT y los datos del usuario logueado en el dispositivo,
/// para que la sesión persista aunque se cierre la app.
class SessionService {
  static const _keyToken = 'auth_token';
  static const _keyUsuario = 'auth_usuario';

  static Future<void> guardarSesion(String token, Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUsuario, jsonEncode(usuario.toJson()));
  }

  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<Usuario?> obtenerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUsuario);
    if (data == null) return null;
    return Usuario.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  static Future<bool> haySesionActiva() async {
    final token = await obtenerToken();
    return token != null;
  }

  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUsuario);
  }
}
