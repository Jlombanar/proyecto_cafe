import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:ecommer_app/models/product.dart';
import 'package:ecommer_app/services/admin_product_service.dart';

class ProductFormSheet extends StatefulWidget {
  final Product? producto;
  final String Function(String) resolverUrl;

  const ProductFormSheet({super.key, this.producto, required this.resolverUrl});

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nombreCtrl = TextEditingController(text: widget.producto?.title ?? '');
  late final _descCtrl = TextEditingController(text: widget.producto?.description ?? '');
  late final _precioCtrl = TextEditingController(text: widget.producto?.price.toString() ?? '');

  XFile? _imagen;
  Uint8List? _imagenBytes;
  bool _arrastrando = false;
  bool _guardando = false;
  bool get _esEdicion => widget.producto != null;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _usarArchivo(XFile archivo) async {
    final ext = archivo.name.split('.').last.toLowerCase();
    if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(ext)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formato no soportado. Usa JPG, PNG o WEBP.')),
      );
      return;
    }
    final bytes = await archivo.readAsBytes();
    if (mounted) setState(() { _imagen = archivo; _imagenBytes = bytes; });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_esEdicion && _imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una imagen')));
      return;
    }

    setState(() => _guardando = true);
    try {
      final p = double.parse(_precioCtrl.text);
      if (_esEdicion) {
        await AdminProductService.actualizarProducto(
          id: widget.producto!.id,
          nombre: _nombreCtrl.text.trim(),
          descripcion: _descCtrl.text.trim(),
          precio: p,
          imagen: _imagen,
        );
      } else {
        await AdminProductService.crearProducto(
          nombre: _nombreCtrl.text.trim(),
          descripcion: _descCtrl.text.trim(),
          precio: p,
          imagen: _imagen!,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'.replaceAll('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Widget _buildField(TextEditingController ctrl, String label, {int maxLines = 1, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(labelText: label),
        validator: (v) => (v == null || v.isEmpty) ? 'Campo obligatorio' : (isNumber && double.tryParse(v) == null ? 'Ingresa un número válido' : null),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imagenBytes != null) return Image.memory(_imagenBytes!, fit: BoxFit.cover);
    if (_esEdicion && widget.producto!.imageUrl.isNotEmpty) {
      return Image.network(widget.resolverUrl(widget.producto!.imageUrl), fit: BoxFit.cover);
    }
    return Center(
      child: Icon(Icons.add_a_photo_rounded, color: _arrastrando ? const Color(0xFFC88D51) : Colors.white38, size: 40),
    );
  }

  bool get _tieneCamara =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _seleccionarImagen() async {
    ImageSource? origen = ImageSource.gallery;
    if (_tieneCamara) {
      origen = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: const Color(0xFF26221F),
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded, color: Color(0xFFC88D51)),
                title: const Text('Tomar foto', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Color(0xFFC88D51)),
                title: const Text('Elegir de la galería', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    }
    if (origen == null) return;
    final archivo = await ImagePicker().pickImage(source: origen, imageQuality: 80);
    if (archivo != null) await _usarArchivo(archivo);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: const BoxDecoration(
          color: Color(0xFF181513),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _esEdicion ? 'Editar producto' : 'Nuevo producto',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropTarget(
                  onDragEntered: (_) => setState(() => _arrastrando = true),
                  onDragExited: (_) => setState(() => _arrastrando = false),
                  onDragDone: (d) => d.files.isNotEmpty ? _usarArchivo(d.files.first) : null,
                  child: GestureDetector(
                    onTap: _seleccionarImagen,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26221F),
                        borderRadius: BorderRadius.circular(16),
                        border: _arrastrando ? Border.all(color: const Color(0xFFC88D51), width: 2) : null,
                      ),
                      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: _buildImagePreview()),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(_nombreCtrl, 'Nombre del producto'),
                _buildField(_descCtrl, 'Descripción', maxLines: 2),
                _buildField(_precioCtrl, 'Precio', isNumber: true),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC88D51),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _guardando
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_esEdicion ? 'GUARDAR CAMBIOS' : 'CREAR PRODUCTO'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}