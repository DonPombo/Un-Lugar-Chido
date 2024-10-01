class Producto {
  String? id;
  String nombre;
  double precio;
  String categoria;
  String subcategoria;
  String imagen ;
  String descripcion;
  bool disponible;

  Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    required this.subcategoria,
    this.imagen = '',
    required this.descripcion,
    required this.disponible,
  });

  factory Producto.fromMap(Map<String, dynamic> data, String id) {
    return Producto(
      id: id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      categoria: data['categoria'] ?? '',
      subcategoria: data['subcategoria'] ?? 'Tacos',
      imagen: data['imagen'],
      descripcion: data['descripcion'] ?? '',
      disponible: data['disponible'] ?? false,
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
