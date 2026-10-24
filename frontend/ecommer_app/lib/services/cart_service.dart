import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int cantidad;

  CartItem({required this.product, this.cantidad = 1});

  double get subtotal => product.price * cantidad;

  Map<String, dynamic> toJson() => {'product': product.toJson(), 'cantidad': cantidad};

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        cantidad: json['cantidad'] as int? ?? 1,
      );
}

/// Carrito de compras compartido por toda la app.
/// Se guarda en el dispositivo para que no se pierda al cerrar la app.
/// Los widgets lo escuchan con ListenableBuilder(listenable: CartService.instance).
class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  static const _keyCarrito = 'carrito';
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get cantidadTotal => _items.fold(0, (suma, i) => suma + i.cantidad);
  double get total => _items.fold(0.0, (suma, i) => suma + i.subtotal);

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyCarrito);
    if (data == null) return;
    try {
      _items
        ..clear()
        ..addAll((jsonDecode(data) as List<dynamic>)
            .map((i) => CartItem.fromJson(i as Map<String, dynamic>)));
      notifyListeners();
    } catch (_) {
      await prefs.remove(_keyCarrito);
    }
  }

  void agregar(Product product) {
    final existente = _items.where((i) => i.product.id == product.id).firstOrNull;
    if (existente != null) {
      existente.cantidad++;
    } else {
      _items.add(CartItem(product: product));
    }
    _guardar();
  }

  void cambiarCantidad(String productId, int cantidad) {
    if (cantidad < 1) return eliminar(productId);
    final item = _items.where((i) => i.product.id == productId).firstOrNull;
    if (item == null) return;
    item.cantidad = cantidad;
    _guardar();
  }

  void eliminar(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    _guardar();
  }

  void vaciar() {
    _items.clear();
    _guardar();
  }

  Future<void> _guardar() async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCarrito, jsonEncode(_items.map((i) => i.toJson()).toList()));
  }
}
