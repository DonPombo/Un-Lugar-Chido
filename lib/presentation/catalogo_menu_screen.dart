import 'package:flutter/material.dart';
import 'package:un_lugar_chido_app/presentation/screens.dart';

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
      'category': 'Platos Principales',
      'image': 'assets/images/tacos.jpg'
    },
    {
      'name': 'Guacamole',
      'price': '\$30',
      'category': 'Entradas',
      'image': 'assets/images/guacamole.jpg'
    },
    {
      'name': 'Margarita',
      'price': '\$70',
      'category': 'Bebidas',
      'image': 'assets/images/margarita.jpg'
    },
    // Añadir más items aquí
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nuestro Menú'),
          bottom: TabBar(
            indicatorColor: themeData.colorScheme.secondary,
            labelColor: themeData.primaryColor,
            tabs: const [
              Tab(text: 'Todos'),
              Tab(text: 'Entradas'),
              Tab(text: 'Platos'),
              Tab(text: 'Bebidas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildItemList(items),
            _buildItemList(
                items.where((item) => item['category'] == 'Entradas').toList()),
            _buildItemList(items
                .where((item) => item['category'] == 'Platos Principales')
                .toList()),
            _buildItemList(
                items.where((item) => item['category'] == 'Bebidas').toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Image.asset(items[index]['image'],
                width: 80, height: 80, fit: BoxFit.cover),
            title: Text(items[index]['name']),
            subtitle: Text(items[index]['price']),
            trailing: Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor),
            onTap: () {
              // Implementar detalles del item
            },
          ),
        );
      },
    );
  }
}
