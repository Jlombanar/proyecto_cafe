import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'api_config.dart';
import 'api_helper.dart';

/// Favoritos del usuario logueado (se guardan en el backend).
/// Mantiene en memoria los ids para pintar el corazón en las tarjetas.
class FavoritesService extends ChangeNotifier {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  final Set<String> _ids = {};

  bool esFavorito(String productId) => _ids.contains(productId);

  Future<List<Product>> obtenerFavoritos() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/favoritos'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(ApiHelper.mensajeError(response));
    }

    final productos = (jsonDecode(response.body) as List<dynamic>)
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
    _ids
      ..clear()
      ..addAll(productos.map((p) => p.id));
    notifyListeners();
    return productos;
  }

  /// Agrega o quita el producto de favoritos. Devuelve true si quedó como favorito.
  Future<bool> alternar(String productId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/favoritos/$productId'),
      headers: await ApiHelper.headers(),
    );
    if (response.statusCode != 200) {
      throw Exception(ApiHelper.mensajeError(response));
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _ids
      ..clear()
      ..addAll((data['favoritos'] as List<dynamic>).map((id) => id.toString()));
    notifyListeners();
    return data['esFavorito'] == true;
  }

  void limpiar() {
    _ids.clear();
    notifyListeners();
  }
}
