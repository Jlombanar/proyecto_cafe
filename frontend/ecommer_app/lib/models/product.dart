class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // Soporta tanto _id de MongoDB como id
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      
      // Soporta mayúsculas y minúsculas de MongoDB/backend sin fallar en null
      title: (json['Nombre'] ?? json['nombre'] ?? json['title'] ?? '').toString(),
      description: (json['Descripcion'] ?? json['descripcion'] ?? json['description'] ?? '').toString(),
      
      // Conversión numérica segura (si viene String, int o null)
      price: (json['Precio'] != null)
          ? double.tryParse(json['Precio'].toString()) ?? 0.0
          : (json['precio'] != null)
              ? double.tryParse(json['precio'].toString()) ?? 0.0
              : (json['price'] != null)
                  ? double.tryParse(json['price'].toString()) ?? 0.0
                  : 0.0,
      
      // Soporta Image, imagen_url, imageUrl o imagen
      imageUrl: (json['Image'] ?? json['image'] ?? json['imagen_url'] ?? json['imageUrl'] ?? json['imagen'] ?? '').toString(),
    );
  }

  // Usa las mismas claves del backend para poder reconstruirlo con fromJson
  // (se usa para guardar el carrito en el dispositivo)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Nombre': title,
      'Descripcion': description,
      'Precio': price,
      'Image': imageUrl,
    };
  }
}
