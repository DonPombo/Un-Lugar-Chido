class Producto {
  String? id;
  String nombre;
  double precio;
  String categoria;
  String subclase;
  String? imagen; // Ahora es opcional
  String descripcion;
  bool disponible;
  String? agregados; // Campo opcional para agregados

  Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    required this.subclase,
    this.imagen, // No requerido
    required this.descripcion,
    required this.disponible,
    this.agregados,
  });

  factory Producto.fromMap(Map<String, dynamic> data, String id) {
    return Producto(
      id: id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      categoria: data['categoria'] ?? '',
      subclase: data['subclase'] ?? 'opcion1',
      imagen: data['imagen'], // Puede ser nulo
      descripcion: data['descripcion'] ?? '',
      disponible: data['disponible'] ?? false,
      agregados: data['agregados'], // Puede ser nulo
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'subcategoria': subclase,
      'imagen': imagen, // Puede ser null
      'descripcion': descripcion,
      'disponible': disponible,
      'agregados': agregados, // Puede ser null
    };
  }
}
