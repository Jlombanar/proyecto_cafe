import 'package:flutter/material.dart';
import 'package:ecommer_app/services/auth_service.dart';
import 'package:ecommer_app/pages/verify_code.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();

  // Nodos de foco para saltar entre campos desde el teclado
  final _apellidoFocus = FocusNode();
  final _telefonoFocus = FocusNode();
  final _correoFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmarFocus = FocusNode();

  bool _cargando = false;
  bool _verPassword = false;

  @override
  void dispose() {
    // Liberación eficiente de memoria
    for (final c in [
      _nombreController,
      _apellidoController,
      _telefonoController,
      _correoController,
      _passwordController,
      _confirmarController,
    ]) {
      c.dispose();
    }
    for (final f in [
      _apellidoFocus,
      _telefonoFocus,
      _correoFocus,
      _passwordFocus,
      _confirmarFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final correo = _correoController.text.trim().toLowerCase();
      final mensaje = await AuthService.registrar(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        correo: correo,
        password: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
      );
      // La cuenta queda pendiente hasta ingresar el código del correo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VerifyCodePage(correo: correo)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  InputDecoration _inputStyle(String label, String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      prefixIcon: Icon(icon, color: Colors.white38),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF26221F),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFC88D51);
    return Scaffold(
      backgroundColor: const Color(0xFF181513),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Crea tu cuenta',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFF5E6D3)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Regístrate para pedir tu café favorito',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 24),
                // Nombre
                TextFormField(
                  controller: _nombreController,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_apellidoFocus),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Nombre', 'Tu nombre', Icons.person_outline_rounded),
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 14),
                // Apellido
                TextFormField(
                  controller: _apellidoController,
                  focusNode: _apellidoFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_telefonoFocus),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Apellido', 'Tu apellido', Icons.person_outline_rounded),
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Ingresa tu apellido' : null,
                ),
                const SizedBox(height: 14),
                // Teléfono
                TextFormField(
                  controller: _telefonoController,
                  focusNode: _telefonoFocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_correoFocus),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Teléfono', '3001234567', Icons.phone_outlined),
                  validator: (v) => (v == null || v.trim().length < 7) ? 'Ingresa un teléfono válido' : null,
                ),
                const SizedBox(height: 14),
                // Correo
                TextFormField(
                  controller: _correoController,
                  focusNode: _correoFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Correo electrónico', 'correo@ejemplo.com', Icons.email_outlined),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Correo inválido' : null,
                ),
                const SizedBox(height: 14),
                // Contraseña
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: !_verPassword,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_confirmarFocus),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle(
                    'Contraseña',
                    'Mínimo 6 caracteres',
                    Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(_verPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white38),
                      onPressed: () => setState(() => _verPassword = !_verPassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 14),
                // Confirmar Contraseña
                TextFormField(
                  controller: _confirmarController,
                  focusNode: _confirmarFocus,
                  obscureText: !_verPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _registrar(),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Confirmar contraseña', 'Repite tu contraseña', Icons.lock_outline_rounded),
                  validator: (v) => (v != _passwordController.text) ? 'Las contraseñas no coinciden' : null,
                ),
                const SizedBox(height: 28),
                // Botón Registrarme
                ElevatedButton(
                  onPressed: _cargando ? null : _registrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _cargando
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('REGISTRARME', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
