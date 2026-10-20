import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'api_config.dart';

class ProductService {
  // GET: Obtener todos los productos
  static Future<List<Product>> getProductos() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/productos'),
      // Cabeceras para evitar que la petición mantenga datos en caché
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar productos (Código: ${response.statusCode})');
    }
  }
}