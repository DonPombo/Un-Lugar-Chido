import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'detalle_item_screen.dart';
import '/models/producto.dart'; // Asegúrate de que la ruta sea correcta

class CatalogoMenuScreen extends StatelessWidget {
  // Cambia a Stateless si no hay estado que manejar
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
            _buildItemListByCategory('menu'),
            _buildItemListByCategory('barra'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('productos').snapshots(),
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

        return _buildListView(productos);
      },
    );
  }

  Widget _buildItemListByCategory(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('productos')
          .where('categoria', isEqualTo: category)
          .snapshots(),
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

        return _buildListView(productos);
      },
    );
  }

  Widget _buildListView(List<Producto> productos) {
    return ListView.builder(
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final item = productos[index];
        return Card(
          child: ListTile(
            leading: Stack(
              children: [
                Image.network(item.imagen ?? 'assets/images/default_image.png',
                    width: 80, height: 80, fit: BoxFit.cover),
                if (!item.disponible)
                  Container(
                    width: 80,
                    height: 80,
                    color: Colors.black.withOpacity(0.6),
                    child: const Center(
                      child: Text(
                        'No disponible',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(item.nombre),
            subtitle: Text('\$${item.precio.toStringAsFixed(2)}'),
            trailing: Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalleItemScreen(
                      item: item), // Cambia esto a item.toMap()
                ),
              );
            },
          ),
        );
      },
    );
  }
}
