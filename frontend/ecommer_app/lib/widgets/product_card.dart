import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF26221F),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. IMAGEN DE LA BASE DE DATOS (product.imageUrl)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFF1F1B18),
                  child: product.imageUrl.isNotEmpty && product.imageUrl.startsWith('http')
                      ? Image.network(
                          product.imageUrl, // <-- Usamos imageUrl
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFC88D51),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.sell_rounded,
                              color: Color(0xFFC88D51),
                              size: 40,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.sell_rounded,
                            color: Color(0xFFC88D51),
                            size: 40,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              // 2. TÍTULO (product.title)
              Text(
                product.title, // <-- Usamos title
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 4),

              // 3. DESCRIPCIÓN (product.description)
              Text(
                product.description, // <-- Usamos description
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 12),

              // 4. PRECIO Y BOTÓN AGREGAR (product.price)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}', // <-- Usamos price
                    style: const TextStyle(
                      color: Color(0xFFF5E6D3),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  Material(
                    color: const Color(0xFFC88D51),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onAddTap,
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}