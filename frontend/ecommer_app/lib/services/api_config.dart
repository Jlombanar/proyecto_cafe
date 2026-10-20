
import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;
 
class ApiConfig {
 
  static String get baseUrl {
    if (kIsWeb) {
      
      return 'http://localhost:3000/api';
    }
 
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Emulador de Android
      return 'http://10.0.2.2:3000/api';
    }
 
    // iOS, macOS, Windows, Linux
    return 'http://localhost:3000/api';
  }
}
 