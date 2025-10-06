import 'package:flutter/material.dart';
import '/models/producto.dart'; // Asegúrate de que la ruta sea correcta

class DetalleItemScreen extends StatelessWidget {
  final Producto item; // Cambia esto para que acepte un Producto

  const DetalleItemScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.nombre), // Accede a la propiedad nombre
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Image.network(
                  item.imagen, // Cambia a Image.network
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                if (!item.disponible)
                  Container(
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Agotado',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombre,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${item.precio.toStringAsFixed(2)}', // Cambia para mostrar el precio
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.descripcion,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Categoría: ${item.categoria}', // Cambia a item.categoria
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'subcategoría: ${item.subcategoria}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
