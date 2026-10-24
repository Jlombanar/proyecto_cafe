import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/notificacion.dart';
import 'api_config.dart';
import 'api_helper.dart';
import 'sesion_service.dart';

/// Notificaciones del usuario logueado (pedidos recibidos, cambios de estado, etc.)
class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  List<Notificacion> _notificaciones = [];

  List<Notificacion> get notificaciones => List.unmodifiable(_notificaciones);
  int get noLeidas => _notificaciones.where((n) => !n.leida).length;

  Future<void> cargar() async {
    if (!await SessionService.haySesionActiva()) {
      limpiar();
      return;
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/notificaciones'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(ApiHelper.mensajeError(response));
    }

    _notificaciones = (jsonDecode(response.body) as List<dynamic>)
        .map((n) => Notificacion.fromJson(n as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  /// Igual que cargar() pero ignora errores (para refrescos en segundo plano)
  Future<void> refrescar() async {
    try {
      await cargar();
    } catch (_) {}
  }

  Future<void> marcarLeida(String id) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/notificaciones/$id/leida'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) await refrescar();
  }

  Future<void> marcarTodasLeidas() async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/notificaciones/leer-todas'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode == 200) await refrescar();
  }

  void limpiar() {
    _notificaciones = [];
    notifyListeners();
  }
}
