
class Producto {
  final String? id;
  final String nombre;
  final double precio;
  final String categoria;
  final String subcategoria;
  final String imagen;
  final String descripcion;
  final bool disponible;

  Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    required this.subcategoria,
    required this.imagen,
    required this.descripcion,
    required this.disponible,
  });

  factory Producto.fromMap(Map<String, dynamic> map, String? id) {
    return Producto(
      id: id,
      nombre: map['nombre'] ?? '',
      precio: (map['precio'] ?? 0.0).toDouble(),
      categoria: map['categoria'] ?? 'Menú',
      subcategoria: map['subcategoria'] ?? 'Tacos',
      imagen: map['imagen'] ?? '',
      descripcion: map['descripcion'] ?? '',
      disponible: map['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'subcategoria': subcategoria,
      'imagen': imagen,
      'descripcion': descripcion,
      'disponible': disponible,
    };
  }
}
