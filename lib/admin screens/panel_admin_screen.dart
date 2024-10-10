import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../models/producto.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import 'dialogs/dialogs.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PanelAdminScreen extends StatefulWidget {
  const PanelAdminScreen({Key? key}) : super(key: key);

  @override
  PanelAdminScreenState createState() => PanelAdminScreenState();
}

class PanelAdminScreenState extends State<PanelAdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final String defaultImageUrl = 
      'https://via.placeholder.com/150';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Cerrar sesión'),
            onPressed: () async {
              await _authService.cerrarSesion();
              context.go('/');
            },
          ),
        ],
      ),
      body: _buildProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductList() {
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
            .map((doc) => Producto.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        return ListView.builder(
          itemCount: productos.length,
          itemBuilder: (context, index) {
            Producto producto = productos[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: producto.imagen.isNotEmpty ? producto.imagen : defaultImageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
                title: Text(producto.nombre),
                subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: producto.disponible,
                      onChanged: (value) async {
                        await _firestoreService.actualizarDisponibilidad(producto.id!, value);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditProductDialog(context, producto),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmationDialog(context, producto),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddProductDialog(BuildContext context) {
    mostrarDialogoEdicion(
      context: context,
      formKey: _formKey,
      firestoreService: _firestoreService,
      isLoading: isLoading,
      setLoading: (bool value) {
        setState(() {
          isLoading = value;
        });
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Producto producto) {
    mostrarDialogoEdicion(
      context: context,
      formKey: _formKey,
      firestoreService: _firestoreService,
      producto: producto,
      isLoading: isLoading,
      setLoading: (bool value) {
        setState(() {
          isLoading = value;
        });
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Producto producto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar ${producto.nombre}?'),
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
                try {
                  await _firestoreService.eliminarProducto(producto.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto eliminado exitosamente')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar el producto: $e')),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}