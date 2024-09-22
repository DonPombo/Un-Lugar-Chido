import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:un_lugar_chido_app/Theme/theme_screen.dart';
import '../../models/producto.dart';
import '/services/firestore_service.dart';

class PanelAdminScreen extends StatefulWidget {
  const PanelAdminScreen({super.key});

  @override
 
  PanelAdminScreenState createState() => PanelAdminScreenState();
}

class PanelAdminScreenState extends State<PanelAdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Producto> _productos = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    List<Producto> productos = await _firestoreService.getProductos();
    setState(() {
      _productos = productos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: themeData.primaryColor,
      ),
      body: ListView.builder(
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          Producto producto = _productos[index];
          return ListTile(
            title: Text(producto.nombre),
            subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
            trailing: Switch(
              value: producto.disponible,
              onChanged: (bool value) async {
                await _firestoreService.actualizarDisponibilidad(producto.id!, value);
                setState(() {
                  producto.disponible = value;
                });
              },
            ),
            onTap: () {
              _mostrarDialogoEdicion(producto);
            },
          );
        },
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

  void _mostrarDialogoEdicion(Producto? producto) {
    final esNuevoProducto = producto == null;
    final nombreController = TextEditingController(text: producto?.nombre ?? '');
    final precioController = TextEditingController(text: producto?.precio.toString() ?? '');
    final categoriaController = TextEditingController(text: producto?.categoria ?? '');
    final imagenController = TextEditingController(text: producto?.imagen ?? '');
    final descripcionController = TextEditingController(text: producto?.descripcion ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(esNuevoProducto ? 'Agregar Producto' : 'Editar Producto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: precioController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: categoriaController,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),
                TextField(
                  controller: imagenController,
                  decoration: const InputDecoration(labelText: 'URL de la imagen'),
                ),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: const Text('Guardar'),
              onPressed: () async {
                final nuevoProducto = Producto(
                  id: producto?.id,
                  nombre: nombreController.text,
                  precio: double.parse(precioController.text),
                  categoria: categoriaController.text,
                  imagen: imagenController.text,
                  descripcion: descripcionController.text,
                  disponible: producto?.disponible ?? true,
                );

                if (esNuevoProducto) {
                  await _firestoreService.agregarProducto(nuevoProducto);
                } else {
                  await _firestoreService.actualizarProducto(nuevoProducto);
                }

                // ignore: use_build_context_synchronously
                Future.microtask(() => context.pop());
                
              },
            ),
          ],
        );
      },
    );
  }
}