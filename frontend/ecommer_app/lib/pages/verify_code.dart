import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ecommer_app/services/auth_service.dart';
import 'package:ecommer_app/pages/login.dart';

class VerifyCodePage extends StatefulWidget {
  final String correo;

  const VerifyCodePage({super.key, required this.correo});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final _codigoController = TextEditingController();

  bool _verificando = false;
  bool _reenviando = false;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto.replaceFirst('Exception: ', '')),
        backgroundColor: error ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> _verificar() async {
    final codigo = _codigoController.text.trim();
    if (codigo.length != 6) {
      _mostrarMensaje('Ingresa el código de 6 dígitos', error: true);
      return;
    }

    setState(() => _verificando = true);

    try {
      final mensaje = await AuthService.verificarCodigo(
        correo: widget.correo,
        codigo: codigo,
      );

      if (!mounted) return;
      _mostrarMensaje(mensaje);
      // Ya verificada, el usuario inicia sesión normalmente
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      _mostrarMensaje(error.toString(), error: true);
    } finally {
      if (mounted) setState(() => _verificando = false);
    }
  }

  Future<void> _reenviar() async {
    setState(() => _reenviando = true);

    try {
      final mensaje = await AuthService.reenviarCodigo(correo: widget.correo);
      if (!mounted) return;
      _mostrarMensaje(mensaje);
    } catch (error) {
      if (!mounted) return;
      _mostrarMensaje(error.toString(), error: true);
    } finally {
      if (mounted) setState(() => _reenviando = false);
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 64, color: accentColor),
              const SizedBox(height: 16),
              const Text(
                'Verifica tu correo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFF5E6D3)),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa el código de 6 dígitos que enviamos a\n${widget.correo}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => _verificar(),
                style: const TextStyle(color: Colors.white, fontSize: 26, letterSpacing: 10, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 10),
                  filled: true,
                  fillColor: const Color(0xFF26221F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _verificando ? null : _verificar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _verificando
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('VERIFICAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _reenviando ? null : _reenviar,
                child: Text(
                  _reenviando ? 'Reenviando...' : '¿No te llegó? Reenviar código',
                  style: const TextStyle(color: accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
