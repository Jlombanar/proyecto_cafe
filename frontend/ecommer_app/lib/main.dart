
import 'package:flutter/material.dart';
import 'package:ecommer_app/pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NOTA: antes aquí se llamaba a `SessionService.cerrarSesion()`, lo que cerraba
  // la sesión en CADA arranque (solo útil para pruebas). Se quita para que la
  // sesión persista entre aperturas de la app. Si quieres forzar el logout al
  // iniciar, vuelve a importar el servicio y llama a cerrarSesion() aquí.

  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Café Místico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF181513),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC88D51),
          brightness: Brightness.dark,
        ),
      ),
   
      home: const HomePages(),
    );
  }
}
 