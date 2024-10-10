import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:un_lugar_chido_app/services/image_service.dart';
import '../../models/producto.dart';
import '/services/firestore_service.dart';

import 'package:image_picker/image_picker.dart'; // Para seleccionar imágenes

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
  final TextEditingController descripcionController =
      TextEditingController(text: producto?.descripcion ?? '');

  final ImageService imageService = ImageService();
  File? imageFile; // Cambiado a tipo File
  String imageUrl = producto?.imagen ?? '';

  String categoria = producto?.categoria ?? 'Menú';
  String subcategoria = producto?.subcategoria ?? 'Tacos';
  bool disponible = producto?.disponible ?? true;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title:
                Text(producto == null ? 'Agregar Producto' : 'Editar Producto'),
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
                          return 'Por favor ingrese un nombre';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: precioController,
                      decoration: const InputDecoration(labelText: 'Precio'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un precio';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: descripcionController,
                      decoration:
                          const InputDecoration(labelText: 'Descripción'),
                      maxLines: 3,
                    ),
                    DropdownButtonFormField<String>(
                      value: categoria,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: ['Menú', 'Bebidas', 'Postres'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          categoria = newValue!;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: subcategoria,
                      decoration:
                          const InputDecoration(labelText: 'Subcategoría'),
                      items: [
                        'Tacos',
                        'Tortas',
                        'Quesadillas',
                        'Refrescos',
                        'Aguas frescas'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          subcategoria = newValue!;
                        });
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
                    ElevatedButton(
                      onPressed: () async {
                        final pickedFile =
                            await imageService.pickImage(ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            imageFile = kIsWeb
                                ? File('')
                                : File(pickedFile.path); // No usar File en Web
                            // Si estás en Web, puedes asignar pickedFile.path o manejarlo como un File en el servicio
                            imageUrl = kIsWeb
                                ? pickedFile.path
                                : imageUrl; // Asigna la URL de la imagen si estás en la web
                          });
                        }
                      },
                      child: const Text('Seleccionar Imagen'),
                    ),
                    if (imageFile != null && !kIsWeb)
                      Image.file(imageFile!,
                          height: 100,
                          width: 100) // Usando File solo en móviles
                    else if (imageUrl.isNotEmpty)
                      Image.network(imageUrl, height: 100, width: 100)
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
              ElevatedButton(
                child: const Text('Guardar'),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    setLoading(true);
                    try {
                      Producto nuevoProducto = Producto(
                        id: producto?.id,
                        nombre: nombreController.text,
                        precio: double.parse(precioController.text),
                        categoria: categoria,
                        subcategoria: subcategoria,
                        imagen: imageUrl,
                        descripcion: descripcionController.text,
                        disponible: disponible,
                      );

                      // Llama al servicio de firestore con la imagen seleccionada
                      if (producto == null) {
                        await firestoreService.agregarProducto(nuevoProducto,
                            imageFile); // Asegúrate de que el servicio acepte File
                      } else {
                        await firestoreService.actualizarProducto(nuevoProducto,
                            imageFile); // Asegúrate de que el servicio acepte File
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Producto guardado exitosamente')),
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error al guardar el producto: $e')),
                      );
                    } finally {
                      setLoading(false);
                    }
                  }
                },
              ),
            ],
          );
        },
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
