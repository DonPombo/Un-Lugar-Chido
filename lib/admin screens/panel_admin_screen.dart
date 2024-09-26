import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:un_lugar_chido_app/Theme/theme_screen.dart';
import '../../models/producto.dart';
import '/services/firestore_service.dart';
import '/services/auth_service.dart';

class PanelAdminScreen extends StatefulWidget {
  const PanelAdminScreen({super.key});

  @override
  PanelAdminScreenState createState() => PanelAdminScreenState();
}

class PanelAdminScreenState extends State<PanelAdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Imagen por defecto
  final String _defaultImageUrl = '/assets/images/logoChido.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: themeData.primaryColor,
        actions: [
          TextButton.icon(
            label: const Text('Cerrar sesión'),
            icon: const Icon(Icons.exit_to_app),
            onPressed: _cerrarSesion,
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _productosStreamBuilder(),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeData.colorScheme.secondary,
        onPressed: () => _mostrarDialogoEdicion(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    await _authService.cerrarSesion();
    context.go('/');
  }

  Widget _productosStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getProductosStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Producto> productos = snapshot.data!.docs
            .map((doc) =>
                Producto.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        return ListView.builder(
          itemCount: productos.length,
          itemBuilder: (context, index) {
            Producto producto = productos[index];
            return _productoListTile(producto);
          },
        );
      },
    );
  }

  Widget _productoListTile(Producto producto) {
    return ListTile(
      leading: ClipRRect(
        borderRadius:
            BorderRadius.circular(8.0), // Redondear los bordes de la imagen
        child: Image.network(
          producto.imagen != null && producto.imagen!.isNotEmpty
              ? producto.imagen!
              : _defaultImageUrl, // Si la imagen no está, usa la imagen por defecto
          width: 80, // Tamaño específico de la imagen
          height: 80,
          fit: BoxFit.cover, // Ajusta la imagen al contenedor
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              _defaultImageUrl, // En caso de error, usa imagen por defecto
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
      title: Text(producto.nombre),
      subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: producto.disponible,
            onChanged: (value) => _actualizarDisponibilidad(producto, value),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _mostrarDialogoEdicion(producto),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _mostrarDialogoEliminar(producto.id!),
          ),
        ],
      ),
      onTap: () => _mostrarDialogoEdicion(producto),
    );
  }

  Future<void> _actualizarDisponibilidad(Producto producto, bool value) async {
    await _firestoreService.actualizarDisponibilidad(producto.id!, value);
  }

  void _mostrarDialogoEdicion(Producto? producto) {
    final nombreController =
        TextEditingController(text: producto?.nombre ?? '');
    final precioController =
        TextEditingController(text: producto?.precio.toString() ?? '');
    final imagenController =
        TextEditingController(text: producto?.imagen ?? '');
    final descripcionController =
        TextEditingController(text: producto?.descripcion ?? '');
    final agregadosController = TextEditingController();
    String categoria = producto?.categoria ?? 'menu';
    String subcategoria = producto?.subclase ?? 'Aguas, Jugos y Refrescos';
    bool disponible = producto?.disponible ?? true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                  producto == null ? 'Agregar Producto' : 'Editar Producto'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _crearTextFormField(nombreController, 'Nombre'),
                      _crearTextFormField(precioController, 'Precio',
                          isNumeric: true),
                      _crearDropdown(categoria, 'Categoría', ['menu', 'barra'],
                          (value) {
                        setState(() {
                          categoria = value!;
                        });
                      }),
                      _crearDropdown(
                        subcategoria,
                        'Subcategoría',
                        [
                          'Aguas, Jugos y Refrescos',
                          'Leche y Batidos',
                          'Café',
                          'Tapas',
                          'Tacos',
                          'Cervezas',
                          'Cóteles',
                          'Vinos',
                          'Whisky y Rones',
                          'Tequilas y vodkas',
                          'Postres',
                          'Pizzas y Spaghettis'
                        ],
                        (value) {
                          setState(() {
                            subcategoria = value!;
                          });
                        },
                      ),
                      if (subcategoria == 'Postres' ||
                          subcategoria == 'Pizzas y Spaghettis')
                        _crearTextFormField(agregadosController, 'Agregados'),
                      _crearTextFormField(
                          imagenController, 'URL de Imagen (opcional)'),
                      _crearTextFormField(descripcionController, 'Descripción'),
                      SwitchListTile(
                        title: const Text('Disponible'),
                        value: disponible,
                        onChanged: (value) {
                          setState(() {
                            disponible = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Guardar'),
                  onPressed: () => _guardarProducto(
                      producto,
                      nombreController,
                      precioController,
                      imagenController,
                      descripcionController,
                      categoria,
                      subcategoria,
                      disponible,
                      agregadosController.text),
                ),
              ],
            );
          },
        );
      },
    );
  }

  TextFormField _crearTextFormField(
      TextEditingController controller, String label,
      {bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      // Validación solo para los campos que NO son 'URL de Imagen'
      validator: (value) {
        if (label != 'URL de Imagen (opcional)' &&
            (value == null || value.isEmpty)) {
          return 'El $label no puede estar vacío';
        }
        // Para 'URL de Imagen', no se aplicará validación.
        return null;
      },
    );
  }

  DropdownButtonFormField<String> _crearDropdown(String value, String label,
      List<String> options, void Function(String?)? onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || !options.contains(value)) {
          return 'Selecciona una opción válida para $label';
        }
        return null;
      },
    );
  }

  Future<void> _guardarProducto(
      Producto? producto,
      TextEditingController nombreController,
      TextEditingController precioController,
      TextEditingController imagenController,
      TextEditingController descripcionController,
      String categoria,
      String subcategoria,
      bool disponible,
      String agregados) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Si la URL de la imagen está vacía, usar imagen por defecto
      String imagenUrl = imagenController.text.isEmpty
          ? _defaultImageUrl
          : imagenController.text;

      Producto nuevoProducto = Producto(
        id: producto?.id,
        nombre: nombreController.text,
        precio: double.tryParse(precioController.text) ?? 0,
        categoria: categoria,
        subclase: subcategoria,
        imagen: imagenUrl, // Asignar imagen por defecto si no hay
        descripcion: descripcionController.text,
        disponible: disponible,
        agregados:
            subcategoria == 'Postres' || subcategoria == 'Pizzas y Spaghettis'
                ? agregados
                : null,
      );

      try {
        if (producto == null) {
          await _firestoreService.agregarProducto(nuevoProducto);
        } else {
          await _firestoreService.actualizarProducto(nuevoProducto);
        }
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto guardado exitosamente')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar el producto: $e')));
      }

      setState(() {
        isLoading = false;
      });

      context.pop();
    }
  }

  void _mostrarDialogoEliminar(String productoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: const Text(
              '¿Estás seguro de que quieres eliminar este producto?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });

                try {
                  await _firestoreService.eliminarProducto(productoId);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Producto eliminado exitosamente')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error al eliminar el producto: $e')));
                }

                setState(() {
                  isLoading = false;
                });

                context.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
