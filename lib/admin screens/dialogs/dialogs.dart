import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../models/producto.dart';
import '/services/firestore_service.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart'; // Para seleccionar imágenes

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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

  // Variables para la imagen
  File? image; // Para móviles
  Uint8List? webImage; // Para web

  // URL de imagen por defecto
  String defaultImageUrl =
      '/assets/images/logoChido.png'; // URL de imagen por defecto

  // Imagen por defecto o imagen existente
  String imageUrl = producto?.imagen ?? defaultImageUrl;

  // Función para seleccionar imagen desde móvil o web
  Future<void> pickImage() async {
    setLoading(
        false); // Se indica que la operación de selección de imagen está en progreso
    if (kIsWeb) {
      final input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.click();

      input.onChange.listen((e) async {
        final files = input.files;
        if (files!.isEmpty) {
          setLoading(false);
          return;
        }

        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((e) {
          webImage = reader.result as Uint8List;
          setLoading(false); // Finaliza la operación
        });
      });
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        image = File(pickedFile.path);
      }
    }
    setLoading(false); // Finaliza la operación de carga
  }

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
                // TODO : Agregar validación para el precio #
                TextFormField(
                  controller: precioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El precio no puede estar vacío';
                    }
                    final n = double.tryParse(value);
                    if (n == null) {
                      return 'Ingresa un número válido';
                    }
                    if (n <= 0) {
                      return 'El precio debe ser mayor que 0';
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

                // TODO :  implementar la URL correcta  para subir la imagen

                // Botón para seleccionar imagen
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text('Seleccionar Imagen'),
                ),

                // Mostrar la imagen seleccionada (móvil o web) o la imagen por defecto
                if (image != null)
                  Image.file(image!, height: 80, width: 80)
                else if (webImage != null)
                  Image.memory(webImage!, height: 80, width: 80)
                else if (imageUrl.isNotEmpty)
                  Image.network(imageUrl, height: 80, width: 80)
                else
                  Image.network(defaultImageUrl, height: 80, width: 80),
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
                setLoading(true); // Muestra un indicador de carga

                try {
                  // Subir imagen si fue seleccionada
                  if (image != null || webImage != null) {
                    // Determina el nombre del archivo
                    String fileName = image !=
                            null // Para el nombre del archivo seleccionado en web
                        ? basename(image!
                            .path) // Obtiene el nombre del archivo en Android
                        : 'producto_${DateTime.now().millisecondsSinceEpoch}'; // Nombre de la imagen

                    // Llama a la función subirImagen y guarda la URL de descarga
                    imageUrl = await firestoreService.subirImagen(
                      image != null ? image! : webImage!,
                      isWeb: kIsWeb,
                      fileName: fileName,
                    );
                    producto?.imagen = imageUrl;
                  }

                  // Crea un nuevo producto con los datos ingresados
                  Producto nuevoProducto = Producto(
                    id: producto?.id,
                    nombre: nombreController.text,
                    precio: double.tryParse(precioController.text) ?? 0,
                    categoria: categoria,
                    subcategoria: subcategoria,
                    imagen: imageUrl, // Guardar la URL de la imagen
                    descripcion: descripcionController.text,
                    disponible: disponible,
                  );

                  // Guardar el producto en Firestore
                  if (producto == null) {
                    await firestoreService.agregarProducto(nuevoProducto);
                  } else {
                    await firestoreService.actualizarProducto(nuevoProducto);
                  }

                  // Muestra un mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Producto guardado exitosamente')),
                  );
                } catch (e) {
                  // Manejo de errores al guardar el producto
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al guardar el producto: $e')),
                  );
                } finally {
                  setLoading(false); // Oculta el indicador de carga
                }

                Navigator.of(context)
                    .pop(); // Cierra el diálogo o pantalla actual
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
