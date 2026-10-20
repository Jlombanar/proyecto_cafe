import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;

class ApiConfig {
  // Cambia a false cuando quieras volver a probar con tu servidor Node.js local
  static const bool useRemote = true;

  // URL de tu backend desplegado en Render
  static const String _remoteUrl = 'https://proyecto-cafe-ktx5.onrender.com/api';

  static String get baseUrl {
    if (useRemote) {
      return _remoteUrl;
    }

    // Configuración para desarrollo local
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Emulador de Android apuntando al host local
      return 'http://10.0.2.2:3000/api';
    }

    // iOS, macOS, Windows, Linux local
    return 'http://localhost:3000/api';
  }
}