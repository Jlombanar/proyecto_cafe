
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'api_config.dart';
import 'sesion_service.dart';
 

class AdminProductService {

  static String _mensajeError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return (data['message'] ?? data['msg'] ?? 'Error del servidor (código ${response.statusCode})')
          .toString();
    } catch (_) {
      return 'El servidor no respondió con JSON válido (código ${response.statusCode}). '
          'Verifica que el backend esté corriendo y que la URL en api_config.dart sea correcta.';
    }
  }
 
  static Future<void> crearProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required XFile imagen,
  }) async {
    final token = await SessionService.obtenerToken();
 
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/productos'),
    );
 
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Nombre'] = nombre;
    request.fields['Descripcion'] = descripcion;
    request.fields['Precio'] = precio.toString();
    request.files.add(await _archivoImagen(imagen));
 
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
 
    if (response.statusCode != 201) {
      throw Exception(_mensajeError(response));
    }
  }
 
  // Lee los bytes del XFile (funciona igual en Android, iOS y Web) y arma
  // la parte "imagen" de la petición multipart con Content-Type explícito
  // a JPEG -- el filtro del backend rechaza el archivo si el Content-Type
  // no se reconoce como imagen (pasaba antes porque, en iOS, el archivo
  // temporal del picker no siempre trae extensión en el nombre).
  static Future<http.MultipartFile> _archivoImagen(XFile imagen) async {
    final bytes = await imagen.readAsBytes();
    return http.MultipartFile.fromBytes(
      'imagen',
      bytes,
      contentType: MediaType('image', 'jpeg'),
      filename: 'producto_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }
 
  static Future<void> actualizarProducto({
    required String id,
    required String nombre,
    required String descripcion,
    required double precio,
    XFile? imagen, // opcional: solo si el admin cambió la foto
  }) async {
    final token = await SessionService.obtenerToken();
 
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConfig.baseUrl}/productos/$id'),
    );
 
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Nombre'] = nombre;
    request.fields['Descripcion'] = descripcion;
    request.fields['Precio'] = precio.toString();
 
    if (imagen != null) {
      request.files.add(await _archivoImagen(imagen));
    }
 
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
 
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }
 
  static Future<void> eliminarProducto(String id) async {
    final token = await SessionService.obtenerToken();
 
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/productos/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
 
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }
}
 