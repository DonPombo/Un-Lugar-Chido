import 'package:flutter/material.dart';
import '../../models/producto.dart';
import '/services/firestore_service.dart';

Future<void> mostrarDialogoEdicion({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required FirestoreService firestoreService,
  Producto? producto,
  required bool isLoading,
  required Function setLoading,
}) async {
  final TextEditingController nombreController =
      TextEditingController(text: producto?.nombre ?? '');
  final TextEditingController precioController =
      TextEditingController(text: producto?.precio.toString() ?? '');
  final TextEditingController imagenController =
      TextEditingController(text: producto?.imagen ?? '');
  final TextEditingController descripcionController =
      TextEditingController(text: producto?.descripcion ?? '');
  String categoria = producto?.categoria ?? 'Menú';
  String subcategoria = producto?.subcategoria ?? 'Tacos';
  bool disponible = producto?.disponible ?? true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(producto == null ? 'Agregar Producto' : 'Editar Producto'),
        content: Form(
          key: formKey,
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
                // TODO : Agregar validación para el precio

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
                  items: ['Menú', 'Barra'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    categoria = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  validator: (value) {
                    if (value == null ||
                        (value != 'Menú' && value != 'Barra')) {
                      return 'Selecciona una opción válida para categoría';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: subcategoria,
                  items: [
                    'Tacos',
                    'Aguas, Jugos y Refrescos',
                    'Café',
                    'Leche y Batidos',
                    'Tapas',
                    'Cervezas',
                    'Cocteles',
                    'Vinos',
                    'Whisky y Rones',
                    'Tequilas y Vodkas',
                    'Pizzas y Spaghettis',
                    'Postres'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    subcategoria = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Subcategoría'),
                  validator: (value) {
                    if (value == null ||
                        ![
                          'Tacos',
                          'Aguas, Jugos y Refrescos',
                          'Café',
                          'Leche y Batidos',
                          'Tapas',
                          'Cervezas',
                          'Cocteles',
                          'Vinos',
                          'Whisky y Rones',
                          'Tequilas y Vodkas',
                          'Pizzas y Spaghettis',
                          'Postres'
                        ].contains(value)) {
                      return 'Selecciona una opción válida para Subcategoría';
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
                    disponible = value;
                  },
                ),
                const Text('seleccionar imagen'),
                // TODO : implementar la selección de imagen

                // TextFormField(
                //   controller: imagenController,
                //   decoration: const InputDecoration(labelText: 'URL de Imagen'),
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'La URL de la imagen no puede estar vacía';
                //     }
                //     return null;
                //   },
                // ),
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
          const SizedBox(
            height: 10,
          ),
          FilledButton(
            child: const Text('Guardar'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                setLoading(true);

                Producto nuevoProducto = Producto(
                  id: producto?.id,
                  nombre: nombreController.text,
                  precio: double.tryParse(precioController.text) ?? 0,
                  categoria: categoria,
                  subcategoria: subcategoria,
                  imagen: imagenController.text,
                  descripcion: descripcionController.text,
                  disponible: disponible,
                );

                try {
                  if (producto == null) {
                    await firestoreService.agregarProducto(nuevoProducto);
                  } else {
                    await firestoreService.actualizarProducto(nuevoProducto);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Producto guardado exitosamente')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al guardar el producto: $e')),
                  );
                }

                setLoading(false);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> mostrarDialogoEliminar({
  required BuildContext context,
  required FirestoreService firestoreService,
  required String productoId,
  required bool isLoading,
  required Function setLoading,
}) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Eliminar Producto'),
        content:
            const Text('¿Estás seguro de que quieres eliminar este producto?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FilledButton(
            child: const Text('Eliminar'),
            onPressed: () async {
              setLoading(true);

              try {
                await firestoreService.eliminarProducto(productoId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Producto eliminado exitosamente')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar el producto: $e')),
                );
              }

              setLoading(false);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
