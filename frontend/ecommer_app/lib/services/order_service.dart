import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido.dart';
import 'api_config.dart';
import 'api_helper.dart';
import 'cart_service.dart';

class OrderService {
  // ---------- Cliente ----------

  static Future<Pedido> crearPedido({
    required List<CartItem> items,
    required String direccion,
    required String ciudad,
    required String telefono,
    required String notas,
    required String metodoPago,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/pedidos'),
      headers: await ApiHelper.headers(),
      body: jsonEncode({
        // Solo se envía id y cantidad: el backend toma los precios de la BD
        'items': items.map((i) => {'productoId': i.product.id, 'cantidad': i.cantidad}).toList(),
        'direccion': direccion,
        'ciudad': ciudad,
        'telefono': telefono,
        'notas': notas,
        'metodoPago': metodoPago,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(ApiHelper.mensajeError(response));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Pedido.fromJson(data['pedido'] as Map<String, dynamic>);
  }

  static Future<List<Pedido>> misPedidos() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/pedidos/mis-pedidos'),
      headers: await ApiHelper.headers(),
    );
    return _listaPedidos(response);
  }

  static Future<void> cancelarPedido(String id) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/pedidos/$id/cancelar'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(ApiHelper.mensajeError(response));
    }
  }

  // ---------- Administrador ----------

  static Future<List<Pedido>> listarPedidos({String? estado}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/pedidos').replace(
      queryParameters: estado != null ? {'estado': estado} : null,
    );
    final response = await http.get(uri, headers: await ApiHelper.headers());
    return _listaPedidos(response);
  }

  static Future<void> cambiarEstado(String id, String estado) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/pedidos/$id/estado'),
      headers: await ApiHelper.headers(),
      body: jsonEncode({'estado': estado}),
    );
    if (response.statusCode != 200) {
      throw Exception(ApiHelper.mensajeError(response));
    }
  }

  static List<Pedido> _listaPedidos(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception(ApiHelper.mensajeError(response));
    }
    return (jsonDecode(response.body) as List<dynamic>)
        .map((p) => Pedido.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}
