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
                // ignore: use_build_context_synchronously
                context.go('/');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              )),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              return ListTile(
                title: Text(producto.nombre),
                subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
                trailing: Switch(
                  value: producto.disponible,
                  onChanged: (bool value) async {
                    await _firestoreService.actualizarDisponibilidad(
                        producto.id!, value);
                  },
                ),
                onTap: () {
                  _mostrarDialogoEdicion(producto);
                },
              );
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
    // ... (el resto del método permanece igual)
  }
}
