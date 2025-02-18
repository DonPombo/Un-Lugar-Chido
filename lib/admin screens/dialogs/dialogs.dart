import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/services.dart';
import '../../../models/producto.dart';

Future<void> mostrarDialogoEdicion({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  Producto? producto,
  required bool isLoading,
  required Function setLoading,
}) async {
  final nombreController = TextEditingController(text: producto?.nombre ?? '');
  final precioController =
      TextEditingController(text: producto?.precio.toString() ?? '');
  final descripcionController =
      TextEditingController(text: producto?.descripcion ?? '');

  final imageService = ImageService();
  final supabaseService = SupabaseService();
  dynamic imageFile;
  String imageUrl = producto?.imagen ?? '';

  // Valores por defecto más específicos
  String categoria = producto?.categoria ?? 'Menú';
  String subcategoria = producto?.subcategoria ?? 'Tacos';
  bool disponible = producto?.disponible ?? true;

  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        producto == null ? 'Nuevo Producto' : 'Editar Producto',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Campo de imagen
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.primaryColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: buildImagePreview(imageFile, imageUrl),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: FloatingActionButton.small(
                              onPressed: () async {
                                final pickedFile =
                                    await imageService.pickImage();
                                if (pickedFile != null) {
                                  setState(() => imageFile = pickedFile);
                                }
                              },
                              child: const Icon(Icons.camera_alt),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Campos de texto con estilo mejorado
                      TextFormField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del producto',
                          prefixIcon: const Icon(Icons.restaurant_menu),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: precioController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Precio',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Campo requerido';
                          if (double.tryParse(value!) == null) {
                            return 'Ingrese un número válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descripcionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      // Dropdowns con estilo mejorado
                      DropdownButtonFormField<String>(
                        value: categoria,
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['Menú', 'Barra'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            categoria = newValue!;
                            // Actualizar subcategorías según la categoría
                            subcategoria =
                                categoria == 'Menú' ? 'Tacos' : 'Bebidas';
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: subcategoria,
                        decoration: InputDecoration(
                          labelText: 'Subcategoría',
                          prefixIcon: const Icon(Icons.list),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: (categoria == 'Menú'
                                ? ['Tacos', 'Tortas', 'Quesadillas']
                                : ['Bebidas', 'Aguas frescas', 'Cervezas'])
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() => subcategoria = newValue!);
                        },
                      ),
                      const SizedBox(height: 12),
                      // Switch con estilo mejorado
                      SwitchListTile(
                        title: const Text('Disponible'),
                        value: disponible,
                        activeColor: theme.primaryColor,
                        onChanged: (bool value) {
                          setState(() => disponible = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _guardarProducto(
                                      context,
                                      producto,
                                      nombreController,
                                      precioController,
                                      descripcionController,
                                      categoria,
                                      subcategoria,
                                      disponible,
                                      imageFile,
                                      imageUrl,
                                      imageService,
                                      supabaseService,
                                      setLoading,
                                      formKey,
                                    ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text('Guardar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget buildImagePreview(dynamic imageFile, String imageUrl) {
  if (imageFile != null) {
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: (imageFile as XFile).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          }
          return const CircularProgressIndicator();
        },
      );
    }
    return Image.file(
      imageFile as File,
      fit: BoxFit.cover,
    );
  }
  if (imageUrl.isNotEmpty) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.image),
    );
  }
  return const Icon(Icons.add_a_photo, size: 40);
}

Future<void> _guardarProducto(
  BuildContext context,
  Producto? producto,
  TextEditingController nombreController,
  TextEditingController precioController,
  TextEditingController descripcionController,
  String categoria,
  String subcategoria,
  bool disponible,
  dynamic imageFile,
  String imageUrl,
  ImageService imageService,
  SupabaseService supabaseService,
  Function setLoading,
  GlobalKey<FormState> formKey,
) async {
  if (formKey.currentState!.validate()) {
    setLoading(true);
    try {
      String? newImageUrl;
      if (imageFile != null) {
        newImageUrl =
            await imageService.uploadImage(imageFile, 'productos_imagenes');
      }

      final nuevoProducto = Producto(
        id: producto?.id,
        nombre: nombreController.text,
        precio: double.parse(precioController.text),
        categoria: categoria,
        subcategoria: subcategoria,
        imagen: newImageUrl ?? imageUrl,
        descripcion: descripcionController.text,
        disponible: disponible,
      );

      if (producto == null) {
        await supabaseService.agregarProducto(nuevoProducto);
      } else {
        await supabaseService.actualizarProducto(nuevoProducto);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto guardado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el producto: $e')),
        );
      }
    } finally {
      setLoading(false);
    }
  }
}
