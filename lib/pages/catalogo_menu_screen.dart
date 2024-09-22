import 'package:flutter/material.dart';
import 'detalle_item_screen.dart';

class CatalogoMenuScreen extends StatefulWidget {
  const CatalogoMenuScreen({super.key});

  @override
  State<CatalogoMenuScreen> createState() => _CatalogoMenuScreenState();
}

class _CatalogoMenuScreenState extends State<CatalogoMenuScreen> {
  final List<Map<String, dynamic>> items = [
    {
      'name': 'Tacos al Pastor',
      'price': '\$50',
      'category': 'Menú',
      'image': 'assets/images/tacos.jpg',
      'description': 'Deliciosos tacos de carne de cerdo marinada con piña.',
      'available': true,
    },
    {
      'name': 'Guacamole',
      'price': '\$30',
      'category': 'Menú',
      'image': 'assets/images/guacamole.jpg',
      'description': 'Cremoso guacamole hecho con aguacates frescos.',
      'available': true,
    },
    {
      'name': 'Margarita',
      'price': '\$80',
      'category': 'Barra',
      'image': 'assets/images/margarita.jpg',
      'description': 'Clásico coctel mexicano con tequila y limón.',
      'available': false,
    },
  ];

  List<Map<String, dynamic>> _sortItems(List<Map<String, dynamic>> items) {
    items.sort((a, b) {
      if (a['available'] == b['available']) {
        return 0;
      }
      return a['available'] ? -1 : 1;
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
            _buildItemList(_sortItems(items)),
            _buildItemList(_sortItems(
                items.where((item) => item['category'] == 'Menú').toList())),
            _buildItemList(_sortItems(
                items.where((item) => item['category'] == 'Barra').toList())),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            leading: Stack(
              children: [
                Image.asset(item['image'],
                    width: 80, height: 80, fit: BoxFit.cover),
                if (!item['available'])
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
            title: Text(item['name']),
            subtitle: Text(item['price']),
            trailing: Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalleItemScreen(item: item),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
