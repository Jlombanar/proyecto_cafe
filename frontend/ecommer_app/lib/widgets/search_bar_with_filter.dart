import 'package:flutter/material.dart';

class SearchBarWithFilter extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;

  const SearchBarWithFilter({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. CAMPO DE BÚSQUEDA
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF26221F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              // Centrado vertical automático y limpio sin forzar paddings
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Buscar café, postres...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 2. BOTÓN DE FILTRO
        Material(
          color: const Color(0xFFC88D51),
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias, // Mantiene el efecto ripple dentro del borde
          child: InkWell(
            onTap: onFilterTap,
            child: const SizedBox(
              height: 52,
              width: 52,
              child: Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}