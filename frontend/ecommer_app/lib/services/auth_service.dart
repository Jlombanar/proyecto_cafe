import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'api_config.dart';
import 'sesion_service.dart';
import '../models/usuario.dart';

class AuthService {
  static const String _clientId =
      '941062996232-1a5p710a19q68e895ma6htiokch286p4.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? _clientId : null,
    serverClientId: kIsWeb ? null : _clientId,
    scopes: ['email', 'profile'],
  );

  // Inicia sesión con Google, envía el token al backend y guarda la sesión
  static Future<Usuario?> loginWithGoogle() async {
    // 1. Abre el diálogo de cuentas de Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null;
    }

    // 2. Obtiene las credenciales de autenticación
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    // En Web idToken es null y entrega accessToken
    final String? tokenParaBackend = googleAuth.idToken ?? googleAuth.accessToken;

    if (tokenParaBackend == null) {
      throw Exception('No se pudo obtener el token de Google');
    }

    // 3. Envía el token a tu backend
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/usuarios/login-google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': tokenParaBackend}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final usuario = Usuario.fromJson(data['usuario']);
      await SessionService.guardarSesion(data['token'], usuario);
      return usuario;
    } else {
      throw Exception(data['message'] ?? data['msg'] ?? 'Error al autenticar con Google');
    }
  }

  // Inicia sesión tradicional con correo y contraseña
  static Future<Usuario> login({
    required String correo,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Correo_Electronico': correo,
        'passwords': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final usuario = Usuario.fromJson(data['usuario']);
      await SessionService.guardarSesion(data['token'], usuario);
      return usuario;
    } else {
      throw Exception(data['message'] ?? data['msg'] ?? 'Error al iniciar sesión');
    }
  }

  // Registra un usuario nuevo
  static Future<Usuario> registrar({
    required String nombre,
    required String apellido,
    required String telefono,
    required String correo,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/usuarios/registrar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Nombre': nombre,
        'Apellido': apellido,
        'telefono': telefono,
        'Correo_Electronico': correo,
        'passwords': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> usuarioMap = 
          (data['usuario'] as Map<String, dynamic>?) ?? data;

      final usuario = Usuario.fromJson(usuarioMap);

      if (data['token'] != null) {
        await SessionService.guardarSesion(data['token'], usuario);
      }
      return usuario;
    } else {
      throw Exception(data['message'] ?? data['msg'] ?? 'Error al registrarse');
    }
  }

  static Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await SessionService.cerrarSesion();
  }
}