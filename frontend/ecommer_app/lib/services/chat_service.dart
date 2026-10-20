import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommer_app/services/api_config.dart'; 

class ChatService {
  // Reutiliza la configuración global y apunta a la ruta /chat
  static String get _chatUrl => '${ApiConfig.baseUrl}/chat';

  static Future<String> enviarMensaje(String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse(_chatUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mensaje': mensaje}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['respuesta'] ?? 'No se recibió respuesta del barista.';
      } else {
        return 'El barista está ocupado en este momento. Intenta de nuevo.';
      }
    } catch (e) {
      return 'Error de conexión con la cafetería. Verifica tu red.';
    }
  }
}