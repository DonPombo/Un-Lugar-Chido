import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../models/producto.dart';
import 'dialogs/dialogs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class PanelAdminScreen extends StatefulWidget {
  const PanelAdminScreen({super.key});

  @override
  PanelAdminScreenState createState() => PanelAdminScreenState();
}

class PanelAdminScreenState extends State<PanelAdminScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final String defaultImageUrl = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    _verificarAutenticacion();
  }

  void _verificarAutenticacion() async {
    if (_authService.usuarioActual == null && mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Administración'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await _authService.cerrarSesion();
                if (mounted) context.go('/login');
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Menú'),
              Tab(text: 'Barra'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProductList('Menú'),
            _buildProductList('Barra'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => mostrarDialogoEdicion(
            context: context,
            formKey: _formKey,
            isLoading: isLoading,
            setLoading: (bool value) => setState(() => isLoading = value),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildProductList(String categoria) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabaseService.getProductosStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final productos = snapshot.data!
            .map((doc) => Producto.fromMap(doc, doc['id']))
            .where((producto) => producto.categoria == categoria)
            .toList();

        return ListView.builder(
          itemCount: productos.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final producto = productos[index];
            return Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: producto.imagen.isNotEmpty
                        ? producto.imagen
                        : defaultImageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
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
                        await _supabaseService.actualizarDisponibilidad(
                            producto.id!, value);
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => mostrarDialogoEdicion(
                        context: context,
                        formKey: _formKey,
                        producto: producto,
                        isLoading: isLoading,
                        setLoading: (bool value) =>
                            setState(() => isLoading = value),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _confirmarEliminacion(producto),
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

  void _confirmarEliminacion(Producto producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar ${producto.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _supabaseService.eliminarProducto(producto.id!);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
