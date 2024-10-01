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
            onPressed: () async {
              await _authService.cerrarSesion();
              context.go('/');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
      body: _stackView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeData.colorScheme.secondary,
        onPressed: () {
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
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Stack _stackView() {
    return Stack(
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
                  leading: producto.imagen.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                              30.0), // Borde redondeado para la imagen
                          child: Image.network(
                            producto.imagen,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover, // Ajusta la imagen al contenedor
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported,
                                  size: 60);
                            },
                          ),
                        )
                      : const Icon(Icons.image_not_supported, size: 60),
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
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          mostrarDialogoEliminar(
                            context: context,
                            firestoreService: _firestoreService,
                            productoId: producto.id!,
                            isLoading: isLoading,
                            setLoading: (bool value) {
                              setState(() {
                                isLoading = value;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
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
    );
  }
}
