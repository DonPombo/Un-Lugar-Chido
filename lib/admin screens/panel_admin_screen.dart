import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:un_lugar_chido_app/Theme/theme_screen.dart';
import '../../models/producto.dart';
import '/services/firestore_service.dart';
import '/services/auth_service.dart';
import 'dialogs/dialogs.dart'; // Importamos los diálogos

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
          StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getProductosStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Producto> productos = snapshot.data!.docs
                  .map((doc) => Producto.fromMap(
                      doc.data() as Map<String, dynamic>, doc.id))
                  .toList();

              return ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  Producto producto = productos[index];
                  return ListTile(
                    title: Text(producto.nombre),
                    subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: producto.disponible,
                          onChanged: (bool value) async {
                            await _firestoreService.actualizarDisponibilidad(
                                producto.id!, value);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _mostrarDialogoEdicion(producto);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _mostrarDialogoEliminar(producto.id!);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      _mostrarDialogoEdicion(producto);
                    },
                  );
                },
              );
            },
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeData.colorScheme.secondary,
        onPressed: () {
          _mostrarDialogoEdicion(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Diálogo para agregar/editar producto
  void _mostrarDialogoEdicion(Producto? producto) {
    final TextEditingController nombreController =
        TextEditingController(text: producto?.nombre ?? '');
    final TextEditingController precioController =
        TextEditingController(text: producto?.precio.toString() ?? '');
    final TextEditingController imagenController =
        TextEditingController(text: producto?.imagen ?? '');
    final TextEditingController descripcionController =
        TextEditingController(text: producto?.descripcion ?? '');
    String categoria = producto?.categoria ?? 'menu';
    String subclase = producto?.subclase ?? 'opcion1';
    bool disponible = producto?.disponible ?? true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(producto == null ? 'Agregar Producto' : 'Editar Producto'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El precio no puede estar vacío';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: categoria,
                    items: ['menu', 'barra'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        categoria = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    validator: (value) {
                      if (value == null ||
                          (value != 'menu' && value != 'barra')) {
                        return 'Selecciona una opción válida para categoría';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: subclase,
                    items: [
                      'opcion1',
                      'opcion2',
                      'opcion3',
                      'opcion4',
                      'opcion5'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        subclase = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Subclase'),
                    validator: (value) {
                      if (value == null ||
                          ![
                            'opcion1',
                            'opcion2',
                            'opcion3',
                            'opcion4',
                            'opcion5'
                          ].contains(value)) {
                        return 'Selecciona una opción válida para subclase';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: imagenController,
                    decoration:
                        const InputDecoration(labelText: 'URL de Imagen'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La URL de la imagen no puede estar vacía';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La descripción no puede estar vacía';
                      }
                      return null;
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Disponible'),
                    value: disponible,
                    onChanged: (bool value) {
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isLoading = true;
                  });

                  Producto nuevoProducto = Producto(
                    id: producto?.id,
                    nombre: nombreController.text,
                    precio: double.tryParse(precioController.text) ?? 0,
                    categoria: categoria,
                    subclase: subclase,
                    imagen: imagenController.text,
                    descripcion: descripcionController.text,
                    disponible: disponible,
                  );

                  try {
                    if (producto == null) {
                      await _firestoreService.agregarProducto(nuevoProducto);
                    } else {
                      await _firestoreService.actualizarProducto(nuevoProducto);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Producto guardado exitosamente')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error al guardar el producto: $e')),
                    );
                  }

                  setState(() {
                    isLoading = false;
                  });

                  context.pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Diálogo para eliminar producto con confirmación
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });

                try {
                  await _firestoreService.eliminarProducto(productoId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Producto eliminado exitosamente')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error al eliminar el producto: $e')),
                  );
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
