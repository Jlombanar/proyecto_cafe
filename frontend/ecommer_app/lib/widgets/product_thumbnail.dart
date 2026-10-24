import 'package:flutter/material.dart';

/// Imagen pequeña y cuadrada de un producto, con ícono de respaldo si no carga
class ProductThumbnail extends StatelessWidget {
  final String imageUrl;
  final double size;

  const ProductThumbnail({super.key, required this.imageUrl, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final respaldo = Icon(Icons.coffee_rounded, color: const Color(0xFFC88D51), size: size * 0.45);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFF1F1B18),
        child: imageUrl.startsWith('http')
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Center(child: respaldo),
              )
            : Center(child: respaldo),
      ),
    );
  }
}
