import 'package:flutter/material.dart';
import 'detalle_item_screen.dart';
import '/models/producto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CatalogoMenuScreen extends StatelessWidget {
  const CatalogoMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nuestro Menú'),
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.secondary,
            labelColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Todos'),
              Tab(text: 'Menú'),
              Tab(text: 'Barra'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildItemList(),
            _buildItemListByCategory('Menú'),
            _buildItemListByCategory('Barra'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream:
          Supabase.instance.client.from('productos').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Producto> productos = snapshot.data!
            .map((doc) => Producto.fromMap(doc, doc['id']))
            .toList();

        return _buildListView(productos);
      },
    );
  }

  Widget _buildItemListByCategory(String category) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('productos')
          .stream(primaryKey: ['id']).eq('categoria', category),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Producto> productos = snapshot.data!
            .map((doc) => Producto.fromMap(doc, doc['id']))
            .toList();

        return _buildListView(productos);
      },
    );
  }

  Widget _buildListView(List<Producto> productos) {
    String defaultImageUrl = '/assets/images/logoChido.png';
    return ListView.builder(
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return Card(
          child: ListTile(
            leading: Stack(
              children: [
                Image.network(
                  producto.imagen,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover, // Ajusta la imagen al contenedor
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(defaultImageUrl,
                        height: 80, width: 80);
                  },
                ),
                if (!producto.disponible)
                  Container(
                    width: 80,
                    height: 80,
                    color: Colors.black.withOpacity(0.6),
                    child: const Center(
                      child: Text(
                        'Agotado',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(producto.nombre),
            subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
            trailing: Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalleItemScreen(
                      item: producto), // Cambia esto a item.toMap()
                ),
              );
            },
          ),
        );
      },
    );
  }
}
