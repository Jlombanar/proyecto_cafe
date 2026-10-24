import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sesion_service.dart';

/// Utilidades comunes para las peticiones que requieren sesión
class ApiHelper {
  static Future<Map<String, String>> headers() async {
    final token = await SessionService.obtenerToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String mensajeError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return (data['message'] ?? data['msg'] ?? 'Error del servidor (código ${response.statusCode})')
          .toString();
    } catch (_) {
      return 'El servidor no respondió correctamente (código ${response.statusCode}).';
    }
  }
}
